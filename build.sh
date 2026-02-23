#!/bin/bash
set -e

# Detect if Flutter is installed; if not, download and install Flutter SDK automatically
if [ ! -d "$HOME/flutter" ]; then
  echo "Flutter SDK not found. Installing..."
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter --depth 1
fi

# Add Flutter to the PATH
export PATH="$PATH:$HOME/flutter/bin"

# Verify Flutter installation
flutter --version

# Enable web support (if not already enabled)
flutter config --enable-web

# Run flutter pub get
echo "Running flutter pub get..."
flutter pub get

# Run flutter build web --release
echo "Building Flutter web app..."
flutter build web --release

# Built files are already in build/web by default
echo "Build complete. Output directory: build/web"
