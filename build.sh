#!/bin/bash

# Install Flutter if not already installed
if [ ! -d "$HOME/flutter" ]; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Update Flutter
flutter upgrade

# Get dependencies
flutter pub get

# Build for web
flutter build web --release

echo "Build complete! Output in build/web"
