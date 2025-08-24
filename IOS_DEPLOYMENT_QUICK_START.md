# iOS Deployment Quick Start Guide

## 🚀 Quick Setup (15-30 minutes)

This guide helps you set up fully automated iOS deployment for your Flutter project.

## Prerequisites Checklist

- [ ] Apple Developer Account with App Store Connect access
- [ ] GitHub repository for your Flutter project  
- [ ] macOS machine (for initial setup)
- [ ] App created in App Store Connect

## Step-by-Step Setup

### 1️⃣ App Store Connect API (5 min)

1. Visit [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Keys
2. Create new API key with **App Manager** access
3. Download `.p8` file (⚠️ one-time download!)
4. Note your **Key ID** and **Issuer ID**

### 2️⃣ Certificates Repository (2 min)

1. Create a new **private** GitHub repository named `ios-certificates`
2. Keep this repository empty for now

### 3️⃣ Run Setup Script (10 min)

```bash
# On macOS
cd ios
chmod +x ../scripts/setup_ios_deployment.sh
../scripts/setup_ios_deployment.sh
```

The script will guide you through:
- Installing fastlane
- Setting up Match for code signing
- Generating SSH keys
- Creating environment variables

### 4️⃣ Configure GitHub Secrets (5 min)

Go to your repository → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Where to Find It |
|------------|------------------|
| `APP_STORE_CONNECT_API_KEY_ID` | From step 1 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | From step 1 |
| `APP_STORE_CONNECT_API_KEY` | Base64 encoded .p8 file content |
| `MATCH_PASSWORD` | Password you created during setup |
| `MATCH_SSH_KEY` | From `.env.ios_deployment` file |

### 5️⃣ Add Deploy Key (2 min)

1. Go to your `ios-certificates` repository
2. Settings → Deploy keys → Add deploy key
3. Add the public SSH key (shown during setup)
4. ✅ Enable **write access**

### 6️⃣ Test & Deploy (5 min)

**Test locally:**
```bash
cd ios
bundle exec fastlane validate  # Check configuration
bundle exec fastlane beta      # Test deployment
```

**Deploy via GitHub:**
```bash
git add .
git commit -m "Setup iOS automated deployment"
git push origin main  # Triggers automatic deployment
```

## 🎯 How It Works

### Automatic Triggers

- **Push to `main`** → Deploys to TestFlight
- **Push to `release/*`** → Deploys to App Store
- **Manual trigger** → Choose deployment target

### What Happens

1. GitHub Actions starts on macOS runner
2. Installs Flutter and dependencies
3. Fetches signing certificates via Match
4. Builds the iOS app
5. Uploads to TestFlight/App Store
6. No manual intervention needed! 🎉

## 📋 Common Commands

```bash
# Validate setup
cd ios && bundle exec fastlane validate

# Deploy to TestFlight
cd ios && bundle exec fastlane beta

# Deploy to App Store
cd ios && bundle exec fastlane release

# Update certificates
cd ios && bundle exec fastlane sync_certificates

# Clean build artifacts
cd ios && bundle exec fastlane clean
```

## 🔧 Troubleshooting

### "Match password incorrect"
- Verify `MATCH_PASSWORD` in GitHub Secrets matches what you set during setup

### "No certificate found"
- Run `fastlane sync_certificates` to regenerate
- Check deploy key has write access on certificates repo

### "API authentication failed"
- Verify App Store Connect API key is valid
- Check base64 encoding of .p8 file is correct

### "Build number already exists"
- The workflow auto-increments using GitHub run number
- For manual builds, specify: `BUILD_NUMBER=123 fastlane beta`

## 📊 Build Status

Add this badge to your README:
```markdown
![iOS Deployment](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ios-deploy.yml/badge.svg)
```

## 🔐 Security Notes

- **Never commit** `.p8` files, passwords, or private keys
- Use GitHub Secrets for all sensitive data
- Rotate API keys periodically
- Keep certificates repository private

## 📚 Resources

- [Full Documentation](./IOS_DEPLOYMENT_AUTOMATION_GUIDE.md)
- [Fastlane Docs](https://docs.fastlane.tools/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

## ✅ Success Indicators

You know it's working when:
- ✅ GitHub Actions shows green checkmark
- ✅ Build appears in TestFlight within 10-15 minutes
- ✅ No 2FA prompts during deployment
- ✅ Build number auto-increments

## 💡 Pro Tips

1. **Test locally first** before pushing to GitHub
2. **Use branch protection** to prevent accidental releases
3. **Set up notifications** for deployment status
4. **Cache dependencies** to speed up builds (already configured)
5. **Monitor App Store Connect** for processing status

---

**Need help?** Check the [troubleshooting guide](./IOS_DEPLOYMENT_AUTOMATION_GUIDE.md#troubleshooting) or create an issue.
