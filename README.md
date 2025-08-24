# bisoflutter

A new Flutter project.

## CI secrets for iOS TestFlight (Fastlane)

Add these repository secrets in GitHub for the iOS pipeline to work with Fastlane:

- `IOS_CERTIFICATE_P12_BASE64`: Base64-encoded .p12 distribution certificate
- `IOS_CERTIFICATE_PASSWORD`: Password for the .p12
- `IOS_PROVISIONING_PROFILE_BASE64`: Base64-encoded App Store provisioning profile
- `APPLE_API_KEY_ID`: App Store Connect API key ID
- `APPLE_API_ISSUER_ID`: App Store Connect API issuer ID
- `APPLE_API_PRIVATE_KEY`: Contents of the App Store Connect API private key (the .p8 file text)
- `APPLE_ID` (optional when API key is present): Apple ID email
- `APP_STORE_CONNECT_TEAM_ID` (optional): App Store Connect team ID

The iOS GitHub Actions workflow installs the certificate and provisioning profile into a temporary keychain and then runs `fastlane beta` to build and upload the IPA to TestFlight.