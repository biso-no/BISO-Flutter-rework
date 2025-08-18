Awesome — thanks for the code + architecture detail. Below is an updated, production-ready plan that **uses 24SevenOffice as the source of truth** via your existing `verify_membership` Appwrite Function, and layers on the **rotating QR token** verification flow, **strict request/response contracts**, and **Cursor-ready prompts**.

I’m keeping this tight but complete so you can hand it straight to your devs.

---

# BISO Membership Verification — Final Spec (24SevenOffice + Rotating QR)

## System Overview

* **Source of truth:** 24SevenOffice (via your `verify_membership` Appwrite Function).
* **Appwrite database (`memberships` collection):** *catalog of options only* (used for mapping 24SevenOffice category → membership option + expiryDate ordering).
* **Member app (Student ID screen):** shows animated “ID card” with a **QR code that rotates every 30s**. The QR contains a **short-lived signed token** (no PII).
* **Controller app (Controller Mode):** scans QR → sends token to a **dedicated verification function** which:

  1. Validates the token (signature, `exp`, replay check).
  2. Extracts `studentId` from the token.
  3. Calls **your existing `verify_membership`** with `studentId`.
  4. Returns a minimal, privacy-preserving answer (valid/invalid + limited profile).

---

## Functions & Contracts

### 1) `verify_membership` (Existing) — **Contract (proposed tightening)**

Your current function accepts a raw body (student number), queries 24SevenOffice for category IDs, sorts membership options by `expiryDate`, and returns the **latest matching** membership.

**Request (JSON)**

```ts
// Content-Type: application/json
type VerifyMembershipRequest = {
  studentId: number | string;  // clean to digits server-side
};
```

> Backward compatible: still support raw numeric/string body, but prefer the JSON shape above. In the handler, normalize:
>
> * Extract `studentId` from `req.body.studentId ?? req.body`
> * `cleaned = String(studentId).replace(/\D/g,'')`

**Response (JSON)**

```ts
type MembershipDoc = {
  $id: string;
  membership_id: string;
  name: string;          // e.g., "BISO Semester"
  price: number;         // 350
  category: string;      // stringified 24SO category ID
  status: boolean;       // true = available option
  expiryDate: string;    // ISO8601; used for sorting latest
};

type VerifyMembershipSuccess = {
  ok: true;
  membership: MembershipDoc;     // latest matching active membership
};

type VerifyMembershipError = {
  ok: false;
  error: string;                 // e.g., "No active membership found for this user"
  code?: "NO_ACTIVE_MEMBERSHIP" | "24SO_AUTH_FAILED" | "24SO_LOOKUP_FAILED" | "DB_EMPTY" | "BAD_REQUEST";
};

type VerifyMembershipResponse = VerifyMembershipSuccess | VerifyMembershipError;
```

**Status codes**

* `200` with `{ ok: true }` for success.
* `404` with `{ ok: false, code: "NO_ACTIVE_MEMBERSHIP" }` when no match.
* `401`/`403` for 24SO auth issues.
* `400` for malformed body.
* `500` for unexpected failures.

> Your current code returns `{ membership }` or `{ error }`. Recommend migrating to the `ok/err` shape (while keeping compatibility).

---

### 2) `issue_pass_token` (NEW) — **For the Member App (Student ID screen)**

Purpose: Mint a **short-lived signed token** embedded in the QR. The token carries **no truth** and minimal PII.

**Token payload (JWT)**

```ts
type PassTokenPayload = {
  iss: "biso";           // issuer
  aud: "biso:verify";    // audience
  jti: string;           // random UUID for replay prevention
  sub: string;           // Appwrite userId
  sid: string;           // studentId (digits only)
  iat: number;           // issued at (epoch)
  exp: number;           // now + 30s (or 45-60s if needed)
  ver: 1;                // schema version for future-proofing
};
```

**Request**

```ts
type IssuePassTokenRequest = {
  // authenticated call (Appwrite JWT/cookie). No body required.
};
```

**Response**

```ts
type IssuePassTokenResponse = {
  ok: true;
  token: string;         // JWT
  ttlSeconds: number;    // 30
  serverTime: string;    // ISO (for UI sync/animation timing)
} | {
  ok: false;
  error: string;
  code?: "UNAUTHENTICATED" | "NO_STUDENT_ID" | "INTERNAL";
};
```

**Notes**

* Require user auth. Get `userId` from session.
* Resolve `studentId` from your user profile record (created at BI OAuth link).
* Sign with **server secret** (Appwrite function env).
* Store `jti` in a short-TTL cache (e.g., Redis/Upstash) *only when verified* (see below), or simply validate `jti` uniqueness upon verification to prevent rapid replay.

---

### 3) `verify_pass_token` (NEW) — **For Controller App scanning QR**

Purpose: Validate the token and call `verify_membership`.

**Request**

```ts
type VerifyPassTokenRequest = {
  token: string;  // the QR payload, raw JWT or deep-link param
  context?: {
    scannerUserId?: string;   // Appwrite userId of controller (for audit)
    deviceId?: string;        // optional device fingerprint
    locationHint?: string;    // venue code or GPS bucket (non-PII)
  };
};
```

**Response**

```ts
type VerifyPassTokenSuccess = {
  ok: true;
  result: "VALID" | "INVALID";
  member?: {
    displayName: string;       // from profile; NOT email
    photoUrl?: string;         // optional
    membershipName: string;    // from MembershipDoc.name
    expiresAt?: string;        // if you track this; else omit
  };
  meta: {
    checkedAt: string;         // ISO
    tokenExp: string;          // ISO
    jti: string;
  };
};

type VerifyPassTokenError = {
  ok: false;
  error: string;
  code:
    | "UNAUTHORIZED_SCANNER"
    | "TOKEN_EXPIRED"
    | "TOKEN_INVALID"
    | "REPLAY_DETECTED"
    | "NO_ACTIVE_MEMBERSHIP"
    | "INTERNAL";
};

type VerifyPassTokenResponse = VerifyPassTokenSuccess | VerifyPassTokenError;
```

**Behavior**

1. **AuthZ**: Only users in Appwrite Team `controllers` can call this.
2. Verify JWT: signature, `aud`, `iss`, `exp`, `sub`, `sid`, `ver`.
3. **Replay protection**: check `jti` not seen before within token TTL (+ small grace). If unseen, mark as used for the TTL window.
4. Call `verify_membership({ studentId: sid })`.
5. Map result to **minimal**, privacy-preserving response.

**Status codes**

* `200` with `{ ok: true }` on valid.
* `403` if scanner is not in `controllers`.
* `401` if scanner unauthenticated.
* `400` token malformed.
* `409` for replay detected.
* `404` for `NO_ACTIVE_MEMBERSHIP`.

---

## QR Content & App Links

**QR payload** (recommended):

```
bisoapp://verify?token=<JWT>
```

* For web fallback at gates without controller app, you can also support:

```
https://app.biso.no/verify?token=<JWT>
```

…but only show a **controller-only UI** after auth (team check).

---

## UI/UX & Anti-Forgery

**Student ID (Member App)**

* Card layout: avatar, name, membership name, subtle expiry hint.
* **Animated background** (pulsing BISO gradient).
* **Live watermark**: BISO logo moves/warps every 10s (synced to `serverTime` modulo).
* **QR auto-refresh**: every 30s; show radial countdown ring.
* **Visual “now” glyph**: A tiny, changing shape (e.g., triangle → circle → square) tied to `(floor(serverUnix/10) % 3)`. Screenshots go stale visibly.

**Controller App**

* Big result panel:

  * ✅ VALID: name, photo, membership name.
  * ❌ INVALID/EXPIRED: short reason.
* Haptic + color feedback.
* Show **“Checked at HH\:MM\:ss”** and “Token exp at HH\:MM\:ss”.

---

## Security & Ops

* **RBAC**: Appwrite Team `controllers` enforced on `verify_pass_token`.
* **Rate limiting**: Per scanner device/IP and per subject `sid`.
* **Replay cache**: store `jti` for at least `exp + 15s`.
* **TLS only**. No PII in QR.
* **Audit logs** (append-only):

  * `scannerUserId`, `sid`, `jti`, result, timestamp, venue (if present).
* **Clock sync**: rely on server `serverTime` in UI (don’t trust device clock).
* **Grace window**: 2–5s skew allowed on `exp`.

---

## Implementation Notes / Snippets

### Tighten `verify_membership` handler (parsing + shape)

```ts
// Pseudocode adjustments inside your existing function
const body = req.body ?? {};
const rawSid = typeof body === 'object' && 'studentId' in body ? body.studentId : body;
const cleaned = String(rawSid).replace(/\D/g, '');
if (!cleaned) return res.status(400).json({ ok:false, code:"BAD_REQUEST", error:"Missing studentId" });

const studentId = parseInt(cleaned, 10);

// ...existing logic...

if (latestMembership) {
  return res.status(200).json({ ok: true, membership: latestMembership });
}

return res.status(404).json({ ok:false, code:"NO_ACTIVE_MEMBERSHIP", error:"No active membership found for this user" });
```

### `issue_pass_token` (sketch)

```ts
// Node/Appwrite Function
import jwt from "jsonwebtoken";
import { randomUUID } from "crypto";

export default async ({ req, res, log, error }) => {
  // require user auth (e.g., Appwrite JWT introspection) -> get userId
  const userId = req.headers["x-appwrite-user-id"]; // example; use proper SDK/introspection
  if (!userId) return res.status(401).json({ ok:false, error:"Unauthenticated", code:"UNAUTHENTICATED" });

  // lookup profile for studentId
  const studentId = await getStudentIdForUser(userId);
  if (!studentId) return res.status(400).json({ ok:false, error:"No studentId", code:"NO_STUDENT_ID" });

  const ttlSeconds = 30;
  const now = Math.floor(Date.now()/1000);
  const payload = {
    iss: "biso",
    aud: "biso:verify",
    jti: randomUUID(),
    sub: userId,
    sid: String(studentId),
    iat: now,
    exp: now + ttlSeconds,
    ver: 1,
  };

  const token = jwt.sign(payload, process.env.PASS_TOKEN_SECRET, { algorithm: "HS256" });
  return res.json({ ok:true, token, ttlSeconds, serverTime: new Date().toISOString() });
};
```

### `verify_pass_token` (sketch)

```ts
import jwt from "jsonwebtoken";

export default async ({ req, res, log, error }) => {
  // authZ: only controllers
  const scannerUserId = req.headers["x-appwrite-user-id"];
  if (!await isUserInTeam(scannerUserId, "controllers")) {
    return res.status(403).json({ ok:false, error:"Unauthorized", code:"UNAUTHORIZED_SCANNER" });
  }

  const { token, context } = req.body ?? {};
  if (!token) return res.status(400).json({ ok:false, error:"Missing token", code:"TOKEN_INVALID" });

  let payload;
  try {
    payload = jwt.verify(token, process.env.PASS_TOKEN_SECRET, { algorithms: ["HS256"], audience: "biso:verify", issuer: "biso" });
  } catch (e:any) {
    const code = e.name === "TokenExpiredError" ? "TOKEN_EXPIRED" : "TOKEN_INVALID";
    return res.status(code === "TOKEN_EXPIRED" ? 401 : 400).json({ ok:false, error:e.message, code });
  }

  // replay protection
  const seen = await jtiCacheHas(payload.jti);
  if (seen) {
    return res.status(409).json({ ok:false, error:"Replay detected", code:"REPLAY_DETECTED" });
  }
  await jtiCacheSet(payload.jti, true, /* ttl= */ (payload.exp - Math.floor(Date.now()/1000)) + 10);

  // call existing verify_membership
  const vm = await callVerifyMembership({ studentId: payload.sid });
  if (!vm.ok) {
    const status = vm.code === "NO_ACTIVE_MEMBERSHIP" ? 404 : 500;
    return res.status(status).json({ ok:false, error: vm.error, code: vm.code ?? "INTERNAL" });
  }

  // success (minimal fields)
  return res.status(200).json({
    ok: true,
    result: "VALID",
    member: {
      displayName: await getDisplayName(payload.sub),
      photoUrl: await getPhotoUrl(payload.sub),
      membershipName: vm.membership.name,
      // expiresAt: optional if you track it elsewhere
    },
    meta: {
      checkedAt: new Date().toISOString(),
      tokenExp: new Date(payload.exp * 1000).toISOString(),
      jti: payload.jti,
    }
  });
};
```

---

## Cursor Hand-Off Prompt (Dev Brief)

> **Task:** Implement rotating QR verification for BISO using Appwrite + 24SevenOffice.
>
> **Functions to create:**
>
> 1. `issue_pass_token`
>
>    * Auth required.
>    * Returns `{ ok, token, ttlSeconds, serverTime }`.
>    * Token payload: `iss:"biso"`, `aud:"biso:verify"`, `jti`, `sub:userId`, `sid:studentId`, `iat`, `exp`, `ver:1`.
>    * Sign with `PASS_TOKEN_SECRET` (HS256).
> 2. `verify_pass_token`
>
>    * Auth required; user must be in Appwrite Team `controllers`.
>    * Body: `{ token, context? }`.
>    * Validate JWT (issuer, audience, expiry).
>    * Replay protection with `jti` (cache).
>    * Call existing `verify_membership({ studentId })`.
>    * Respond `{ ok:true, result:"VALID", member:{displayName, photoUrl?, membershipName}, meta:{checkedAt, tokenExp, jti} }` or `{ ok:false, code }`.
>
> **Existing function to align:** `verify_membership`
>
> * Prefer input: `{ studentId }` (JSON).
> * Output shape: `{ ok:true, membership }` or `{ ok:false, code, error }`.
> * Keep backward compatibility with current raw body.
>
> **Flutter (Member app):**
>
> * Call `issue_pass_token` every 30s (with jitter).
> * Render QR of `bisoapp://verify?token=<JWT>`.
> * Animated BISO gradient background, moving watermark, radial countdown ring.
> * Show user `displayName`, avatar, membership name.
>
> **Flutter (Controller mode):**
>
> * Scan QR, extract `token`, POST to `verify_pass_token`.
> * Large result panel with ✅/❌, haptics, and minimal member info.
> * Log failures clearly (expired, replay, invalid).
>
> **Design tokens:**
>
> * Rounded corners (12–16), soft shadows, BISO color palette, subtle motion.
> * Accessibility: high-contrast mode fallback; large QR option.
>
> **Ops/Sec:**
>
> * Rate limit per scanner and per `sid`.
> * Strict TLS, no PII in QR.
> * Audit log entries with `scannerUserId`, `sid`, `jti`, result, timestamp.
>
> **Deliverables:**
>
> * TypeScript functions (Appwrite).
> * Flutter UI for Student ID + Controller Mode.
> * Unit tests for token validation and replay.
> * E2E: happy path, expired token, replay, no membership.

---

## Quick Checklist

* [ ] `verify_membership` accepts `{ studentId }` and returns `{ ok }` shape.
* [ ] `issue_pass_token` issues 30s JWT with `sid` + `jti`.
* [ ] `verify_pass_token` enforces controller RBAC, validates token, replay-protects, calls `verify_membership`.
* [ ] Member app rotates QR + live animations tied to `serverTime`.
* [ ] Controller app shows clear VALID/INVALID, logs audits.
* [ ] Rate limits & telemetry in place.

If you want, I can also produce **typed interfaces** as `.d.ts` files and a **minimal Flutter widget** for the animated QR + countdown ring to jumpstart implementation.
