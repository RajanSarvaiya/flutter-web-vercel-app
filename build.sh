#!/bin/bash
set -e

# Detect if Flutter is installed in the current directory
if [ ! -d "./flutter" ]; then
  echo "Flutter SDK not found locally. Installing..."
  git clone https://github.com/flutter/flutter.git -b stable ./flutter --depth 1
fi

# Add Flutter to the PATH (using local directory)
export PATH="$PATH:$(pwd)/flutter/bin"

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
