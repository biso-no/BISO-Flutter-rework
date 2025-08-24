#!/bin/sh

# Fail this script if any subcommand fails
set -e

# The default execution directory of this script is the ci_scripts directory
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo

# Install Flutter using git
echo "📱 Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Disable analytics and crash reporting on the CI server
flutter config --no-analytics

# Enable web and desktop support (optional)
# flutter config --enable-web
# flutter config --enable-macos-desktop

# Display Flutter doctor to verify setup
echo "🔍 Running Flutter doctor..."
flutter doctor

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Clean and build iOS pods
echo "🧹 Cleaning and installing iOS pods..."
cd ios
pod install --clean-install
cd ..

echo "✅ Flutter setup complete!"