#!/bin/bash

# iOS Deployment Setup Script
# This script helps set up the automated iOS deployment pipeline

set -e

echo "🚀 iOS Deployment Setup for Flutter Project"
echo "==========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "ℹ️  $1"; }

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_warning "This script is designed for macOS. Some features may not work on other systems."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check prerequisites
echo ""
echo "Step 1: Checking prerequisites..."
echo "---------------------------------"

# Check for Flutter
if command_exists flutter; then
    print_success "Flutter is installed"
    flutter --version | head -n 1
else
    print_error "Flutter is not installed"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check for Ruby
if command_exists ruby; then
    print_success "Ruby is installed"
    ruby --version
else
    print_error "Ruby is not installed"
    echo "Please install Ruby (recommended via rbenv or rvm)"
    exit 1
fi

# Check for Bundler
if command_exists bundle; then
    print_success "Bundler is installed"
else
    print_warning "Bundler is not installed. Installing..."
    gem install bundler
fi

# Check for Git
if command_exists git; then
    print_success "Git is installed"
else
    print_error "Git is not installed"
    exit 1
fi

# Step 2: Install fastlane
echo ""
echo "Step 2: Installing fastlane..."
echo "------------------------------"

cd ios
if [ -f "Gemfile" ]; then
    print_info "Installing gems from Gemfile..."
    bundle install
    print_success "Fastlane installed via Bundler"
else
    print_error "Gemfile not found in ios directory"
    exit 1
fi

# Step 3: App Store Connect API Setup
echo ""
echo "Step 3: App Store Connect API Setup"
echo "-----------------------------------"
echo ""
print_info "To set up App Store Connect API:"
print_info "1. Go to https://appstoreconnect.apple.com"
print_info "2. Navigate to Users and Access > Keys"
print_info "3. Create a new API key with 'App Manager' access"
print_info "4. Download the .p8 file (you can only download it once!)"
echo ""
read -p "Have you created an App Store Connect API key? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter your Key ID (e.g., ABC123DEF4): " KEY_ID
    read -p "Enter your Issuer ID (UUID format): " ISSUER_ID
    read -p "Enter the path to your .p8 file: " P8_PATH
    
    if [ -f "$P8_PATH" ]; then
        # Base64 encode the P8 file
        P8_CONTENT=$(base64 < "$P8_PATH")
        print_success "API key file encoded"
        
        # Save to temporary file for GitHub secrets
        echo "APP_STORE_CONNECT_API_KEY_ID=$KEY_ID" > .env.ios_deployment
        echo "APP_STORE_CONNECT_API_ISSUER_ID=$ISSUER_ID" >> .env.ios_deployment
        echo "APP_STORE_CONNECT_API_KEY=$P8_CONTENT" >> .env.ios_deployment
        
        print_success "API credentials saved to .env.ios_deployment (add these to GitHub Secrets)"
        print_warning "Remember to delete .env.ios_deployment after adding to GitHub Secrets!"
    else
        print_error "P8 file not found at $P8_PATH"
    fi
else
    print_warning "Skipping API setup. You'll need to set this up later."
fi

# Step 4: Fastlane Match Setup
echo ""
echo "Step 4: Fastlane Match Setup"
echo "----------------------------"
echo ""
print_info "Match requires a private Git repository to store certificates."
print_info "Create a new private repository (e.g., 'ios-certificates') on GitHub."
echo ""
read -p "Have you created a private certificates repository? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter the HTTPS URL of your certificates repository: " CERT_REPO_URL
    
    # Update Matchfile
    if [ -f "fastlane/Matchfile" ]; then
        # Use perl for cross-platform sed compatibility
        perl -pi -e "s|https://github.com/YOUR_GITHUB_USERNAME/ios-certificates|$CERT_REPO_URL|g" fastlane/Matchfile
        print_success "Updated Matchfile with repository URL"
    fi
    
    read -p "Enter your Apple ID email: " APPLE_ID
    if [ -f "fastlane/Matchfile" ]; then
        perl -pi -e "s|YOUR_APPLE_ID@example.com|$APPLE_ID|g" fastlane/Matchfile
        print_success "Updated Matchfile with Apple ID"
    fi
    
    echo ""
    print_info "Now we'll set up Match. You'll be asked to create a password to encrypt certificates."
    print_warning "Remember this password! You'll need it for GitHub Secrets."
    echo ""
    read -p "Ready to run 'fastlane match appstore'? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bundle exec fastlane match appstore
        print_success "Match certificates created successfully!"
        
        echo ""
        read -sp "Enter the Match password you just created (for GitHub Secrets): " MATCH_PASSWORD
        echo
        echo "MATCH_PASSWORD=$MATCH_PASSWORD" >> .env.ios_deployment
        print_success "Match password saved to .env.ios_deployment"
    fi
else
    print_warning "Skipping Match setup. You'll need to set this up later."
fi

# Step 5: Generate SSH key for GitHub Actions
echo ""
echo "Step 5: SSH Key for GitHub Actions"
echo "----------------------------------"
echo ""
print_info "GitHub Actions needs SSH access to your certificates repository."
read -p "Generate SSH key for GitHub Actions? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SSH_KEY_PATH="$HOME/.ssh/github_actions_ios_deploy"
    
    # Generate SSH key
    ssh-keygen -t ed25519 -C "github-actions-ios" -f "$SSH_KEY_PATH" -N ""
    
    print_success "SSH key generated at $SSH_KEY_PATH"
    
    # Base64 encode the private key
    SSH_KEY_CONTENT=$(base64 < "$SSH_KEY_PATH")
    echo "MATCH_SSH_KEY=$SSH_KEY_CONTENT" >> .env.ios_deployment
    
    print_success "SSH private key encoded and saved"
    print_info "Public key content (add this as a Deploy Key to your certificates repo):"
    echo ""
    cat "${SSH_KEY_PATH}.pub"
    echo ""
    print_warning "Add the above public key to your certificates repository as a Deploy Key with write access!"
fi

# Step 6: Validate setup
echo ""
echo "Step 6: Validating Setup"
echo "------------------------"
echo ""
print_info "Running validation..."

if [ -f ".env.ios_deployment" ]; then
    # Source the env file for validation
    set -a
    source .env.ios_deployment
    set +a
    
    bundle exec fastlane validate
fi

# Step 7: Summary
echo ""
echo "========================================="
echo "Setup Summary"
echo "========================================="
echo ""

if [ -f ".env.ios_deployment" ]; then
    print_success "Environment file created: ios/.env.ios_deployment"
    echo ""
    print_warning "IMPORTANT NEXT STEPS:"
    echo "1. Add these secrets to your GitHub repository (Settings > Secrets > Actions):"
    echo "   - APP_STORE_CONNECT_API_KEY_ID"
    echo "   - APP_STORE_CONNECT_API_ISSUER_ID"
    echo "   - APP_STORE_CONNECT_API_KEY"
    echo "   - MATCH_PASSWORD"
    echo "   - MATCH_SSH_KEY"
    echo ""
    echo "2. Add the SSH public key as a Deploy Key to your certificates repository"
    echo "   - Go to certificates repo > Settings > Deploy keys"
    echo "   - Add the public key with write access"
    echo ""
    echo "3. Delete the .env.ios_deployment file after adding secrets to GitHub"
    echo ""
    echo "4. Test the setup locally:"
    echo "   cd ios && bundle exec fastlane beta"
    echo ""
    echo "5. Push your changes and the GitHub Action will run automatically"
else
    print_warning "Setup incomplete. Please run this script again to complete setup."
fi

print_success "Setup script completed!"
