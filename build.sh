#!/bin/bash

# Ensure we are in the project root
cd "$(dirname "$0")"

# Function to setup Flutter
setup_flutter() {
    # Check if flutter is already in PATH
    if ! command -v flutter &> /dev/null; then
        echo "Flutter not found in PATH, checking local installation..."
        
        # Check if we already cloned it to $HOME (Vercel style)
        if [ -d "$HOME/flutter" ]; then
            export PATH="$PATH:$HOME/flutter/bin"
        # Check if we cloned it locally
        elif [ -d "$(pwd)/flutter" ]; then
            export PATH="$PATH:$(pwd)/flutter/bin"
        else
            echo "Installing Flutter SDK..."
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
    
    # Pre-download binaries
    flutter precache --web
    
    # Get dependencies
    echo "Getting dependencies..."
    flutter pub get
}

# Function to build
build_app() {
    # Ensure flutter is in PATH if it was installed in setup phase
    if [ -d "$HOME/flutter" ]; then
        export PATH="$PATH:$HOME/flutter/bin"
    elif [ -d "$(pwd)/flutter" ]; then
        export PATH="$PATH:$(pwd)/flutter/bin"
    fi

    echo "Starting Web Build..."
    # Using HTML renderer for faster builds and better compatibility on Vercel
    # --no-wasm-dry-run is needed for some CI environments
    flutter build web --release --base-href /
    
    if [ $? -eq 0 ]; then
        echo "Build complete! Output in build/web"
    else
        echo "Error: Flutter build failed."
        exit 1
    fi
}

# Run based on argument
if [ "$1" == "setup" ]; then
    setup_flutter
elif [ "$1" == "build" ]; then
    build_app
else
    # Default: do everything (local use)
    setup_flutter
    build_app
fi
