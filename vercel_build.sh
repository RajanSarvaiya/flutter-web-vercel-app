#!/bin/bash

# 1. Clone Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable Web Support
flutter config --enable-web

# 4. Build the Web App
flutter build web --release
