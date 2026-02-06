#!/bin/bash

# Ensure we are in the project root
cd "$(dirname "$0")"

# Check if flutter is already in PATH
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found in PATH, checking local installation..."
    
    # Check if we already cloned it to $HOME (Vercel style)
    if [ -d "$HOME/flutter" ]; then
        export PATH="$PATH:$HOME/flutter/bin"
    # Check if we cloned it locally
    elif [ -d "./flutter" ]; then
        export PATH="$PATH:$(pwd)/flutter/bin"
    else
        echo "Installing Flutter..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 ./flutter
        export PATH="$PATH:$(pwd)/flutter/bin"
    fi
fi

# Verify flutter command
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter command still not found. Exit code 127"
    exit 127
fi

echo "Using Flutter version:"
flutter --version

# Get dependencies
flutter pub get

# Build for web
echo "Building for web..."
flutter build web --release --no-wasm-dry-run

echo "Build complete! Output in build/web"
