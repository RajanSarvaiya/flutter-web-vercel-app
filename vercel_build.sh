#!/bin/bash

# 1. Clone Flutter SDK (Shallow clone for speed)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# 2. Set explicit Flutter path
FLUTTER_BIN="$(pwd)/flutter/bin/flutter"

# 3. Enable Web Support
echo "Setting up Flutter..."
$FLUTTER_BIN config --enable-web

# 4. Build the Web App
echo "Starting build..."
$FLUTTER_BIN build web --release
