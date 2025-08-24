# iOS Deployment Automation Guide for Flutter

This guide provides a comprehensive setup for fully automated iOS deployment using fastlane and GitHub Actions.

## Overview

The automated pipeline will:
- Automatically trigger on pushes to specific branches
- Handle all code signing without manual intervention
- Build the Flutter iOS app
- Upload to TestFlight or App Store
- Avoid 2FA issues by using App Store Connect API

## Prerequisites

- Apple Developer Account with App Store Connect access
- GitHub repository
- Flutter project with iOS support
- macOS for local testing (optional)

## Step 1: App Store Connect API Setup

### 1.1 Create API Key
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Keys**
3. Click **+** to create a new key
4. Name: `GitHub Actions CI/CD`
5. Access: **App Manager** (minimum required for deployment)
6. Download the `.p8` file (you can only download it once!)
7. Note the following values:
   - **Key ID** (e.g., `ABC123DEF4`)
   - **Issuer ID** (e.g., `12345678-1234-1234-1234-123456789012`)

### 1.2 Prepare API Key for CI
```bash
# Base64 encode the .p8 file for GitHub Secrets
base64 -i AuthKey_ABC123DEF4.p8 | pbcopy  # macOS
# or
base64 AuthKey_ABC123DEF4.p8 -w 0 | xclip -selection clipboard  # Linux
```

## Step 2: Fastlane Match Setup for Code Signing

### 2.1 Create a Private Repository for Certificates
1. Create a new **private** GitHub repository (e.g., `ios-certificates`)
2. This will store encrypted certificates and provisioning profiles

### 2.2 Initialize Match
```bash
cd ios
fastlane match init
```

Choose:
- Storage: `git`
- URL: Your private certificates repo URL (e.g., `https://github.com/yourusername/ios-certificates`)

### 2.3 Generate Certificates and Profiles
```bash
# For App Store deployment
fastlane match appstore

# For development (optional)
fastlane match development

# For AdHoc distribution (optional)
fastlane match adhoc
```

**Important**: You'll be prompted to create a password. This encrypts your certificates. Save this password securely!

### 2.4 Create Matchfile
Create `ios/fastlane/Matchfile`:
```ruby
git_url("https://github.com/yourusername/ios-certificates")
storage_mode("git")

type("appstore") # Default type

app_identifier(["com.biso.no"])
username("your-apple-id@example.com") # Your Apple ID

# For CI environments
readonly(true) # Only use existing profiles, don't create new ones

# Optional: specify team if you have multiple
# team_id("YOUR_TEAM_ID")
```

## Step 3: GitHub Repository Setup

### 3.1 Generate SSH Key for Certificate Repository Access
```bash
# Generate SSH key without passphrase
ssh-keygen -t ed25519 -C "github-actions" -f ./github_actions_key -N ""

# Base64 encode the private key
base64 -i github_actions_key | pbcopy  # macOS
# or
base64 github_actions_key -w 0 | xclip -selection clipboard  # Linux
```

### 3.2 Add Deploy Key to Certificates Repository
1. Go to your certificates repository settings
2. Navigate to **Settings** → **Deploy keys**
3. Add the **public** key (`github_actions_key.pub`)
4. Enable **write access** (required for match to update certificates)

### 3.3 Configure GitHub Secrets
In your main Flutter repository:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following repository secrets:

| Secret Name | Value | Description |
|------------|-------|-------------|
| `APP_STORE_CONNECT_API_KEY_ID` | Your Key ID | From Step 1.1 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Your Issuer ID | From Step 1.1 |
| `APP_STORE_CONNECT_API_KEY` | Base64 encoded .p8 content | From Step 1.2 |
| `MATCH_PASSWORD` | Your match password | From Step 2.3 |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 of `username:PAT` | GitHub username:personal_access_token |
| `MATCH_SSH_KEY` | Base64 encoded private key | From Step 3.1 |
| `APPLE_TEAM_ID` | Your Team ID | Found in Apple Developer Portal |

## Step 4: Update Fastfile

Update `ios/fastlane/Fastfile`:
```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    # Setup CI environment
    setup_ci if is_ci

    # Increment build number
    build_number = ENV["GITHUB_RUN_NUMBER"] || Time.now.strftime("%Y%m%d%H%M")
    increment_build_number(build_number: build_number)

    # Sync certificates using match
    if ENV["MATCH_SSH_KEY"]
      # CI environment with SSH key
      match(
        type: "appstore",
        readonly: is_ci,
        git_private_key: ENV["MATCH_SSH_KEY"]
      )
    else
      # Local development
      match(type: "appstore")
    end

    # Build the Flutter app
    sh("cd ../.. && flutter build ipa --release --build-number=#{build_number}")

    # Upload to TestFlight using API key
    api_key = app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
      key_content: ENV["APP_STORE_CONNECT_API_KEY"],
      is_key_content_base64: true
    )

    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: true,
      ipa: "../build/ios/ipa/*.ipa"
    )
  end

  desc "Build and release to App Store"
  lane :release do
    # Similar to beta but with app store release
    setup_ci if is_ci

    match(
      type: "appstore",
      readonly: is_ci,
      git_private_key: ENV["MATCH_SSH_KEY"]
    )

    build_number = ENV["GITHUB_RUN_NUMBER"] || latest_testflight_build_number + 1
    increment_build_number(build_number: build_number)

    sh("cd ../.. && flutter build ipa --release --build-number=#{build_number}")

    api_key = app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
      key_content: ENV["APP_STORE_CONNECT_API_KEY"],
      is_key_content_base64: true
    )

    upload_to_app_store(
      api_key: api_key,
      force: true,
      skip_screenshots: true,
      skip_metadata: false,
      ipa: "../build/ios/ipa/*.ipa"
    )
  end

  desc "Sync certificates and profiles"
  lane :sync_certificates do
    match(type: "development", force_for_new_devices: true)
    match(type: "appstore")
  end
end
```

## Step 5: GitHub Actions Workflow

Create `.github/workflows/ios-deploy.yml`:
```yaml
name: iOS Deployment

on:
  push:
    branches:
      - main  # Deploy to TestFlight on main branch
      - release/*  # Deploy to App Store on release branches
  workflow_dispatch:
    inputs:
      lane:
        description: 'Fastlane lane to run'
        required: true
        default: 'beta'
        type: choice
        options:
          - beta
          - release

jobs:
  deploy:
    name: Build and Deploy iOS App
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for version tags

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'  # Match your local version
          channel: 'stable'
          cache: true

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: ios

      - name: Cache Flutter dependencies
        uses: actions/cache@v3
        with:
          path: |
            ~/.pub-cache
            .flutter-plugins
            .flutter-plugin-dependencies
          key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-flutter-

      - name: Cache CocoaPods
        uses: actions/cache@v3
        with:
          path: ios/Pods
          key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
          restore-keys: |
            ${{ runner.os }}-pods-

      - name: Install Flutter dependencies
        run: flutter pub get

      - name: Install iOS dependencies
        working-directory: ios
        run: |
          pod repo update
          pod install

      - name: Setup SSH for Match
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.MATCH_SSH_KEY }}" | base64 -d > ~/.ssh/id_ed25519
          chmod 600 ~/.ssh/id_ed25519
          ssh-keyscan github.com >> ~/.ssh/known_hosts

      - name: Determine deployment lane
        id: deployment
        run: |
          if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
            echo "lane=${{ github.event.inputs.lane }}" >> $GITHUB_OUTPUT
          elif [[ "${{ github.ref }}" == refs/heads/main ]]; then
            echo "lane=beta" >> $GITHUB_OUTPUT
          elif [[ "${{ github.ref }}" == refs/heads/release/* ]]; then
            echo "lane=release" >> $GITHUB_OUTPUT
          else
            echo "lane=beta" >> $GITHUB_OUTPUT
          fi

      - name: Run Fastlane
        working-directory: ios
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_SSH_KEY: ${{ secrets.MATCH_SSH_KEY }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
          GITHUB_RUN_NUMBER: ${{ github.run_number }}
        run: |
          bundle exec fastlane ${{ steps.deployment.outputs.lane }}

      - name: Upload IPA artifact
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: ios-build
          path: build/ios/ipa/*.ipa
          retention-days: 30

      - name: Clean up SSH
        if: always()
        run: |
          rm -f ~/.ssh/id_ed25519
```

## Step 6: Local Testing

### Test locally before pushing:
```bash
cd ios

# Test match setup
fastlane match appstore --readonly

# Test build without upload
fastlane run build_app skip_codesigning:true

# Test full beta deployment
fastlane beta
```

## Troubleshooting

### Common Issues and Solutions

1. **Match asks for password repeatedly**
   - Ensure `MATCH_PASSWORD` is set correctly
   - Check keychain access on CI

2. **Code signing fails**
   - Verify provisioning profiles match bundle ID
   - Ensure Xcode project uses "Manual" signing
   - Check that match certificates are valid

3. **API authentication fails**
   - Verify API key has correct permissions
   - Check base64 encoding is correct
   - Ensure key hasn't expired

4. **Build number conflicts**
   - Use `latest_testflight_build_number` to get current number
   - Ensure build numbers always increment

### Security Best Practices

1. **Never commit sensitive data**
   - Use GitHub Secrets for all credentials
   - Add `.env` files to `.gitignore`

2. **Rotate credentials regularly**
   - Regenerate API keys periodically
   - Update match password if compromised

3. **Limit access**
   - Use read-only match in CI
   - Restrict repository access
   - Use branch protection rules

4. **Audit logs**
   - Monitor App Store Connect activity
   - Review GitHub Actions logs
   - Track certificate usage

## Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane Match Guide](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/deployment/deploying-xcode-applications/installing-an-apple-certificate-on-macos-runners-for-xcode-development)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

## Next Steps

1. Set up App Store Connect API key
2. Create certificates repository and initialize match
3. Configure GitHub Secrets
4. Test locally with fastlane
5. Push workflow to trigger automated deployment

This setup provides a robust, secure, and fully automated iOS deployment pipeline that requires no manual intervention once configured.
