#!/bin/bash

# Ensure we are in the project root
cd "$(dirname "$0")"

# Function to setup Flutter
setup_flutter() {
    echo "--- SETUP PHASE ---"
    
    # Check if flutter is already in PATH
    if ! command -v flutter &> /dev/null; then
        echo "Flutter not found in PATH, checking local installation..."
        
        # Check if we already cloned it to $HOME (Vercel style)
        if [ -d "$HOME/flutter" ]; then
            echo "Found Flutter in $HOME/flutter"
            export PATH="$PATH:$HOME/flutter/bin"
        # Check if we cloned it locally
        elif [ -d "$(pwd)/flutter" ]; then
            echo "Found Flutter in $(pwd)/flutter"
            export PATH="$PATH:$(pwd)/flutter/bin"
        else
            echo "Installing Flutter SDK (stable branch)..."
            # Clone to a specific directory to avoid conflicts
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
    
    # Pre-download binaries for web
    echo "Downloading web SDK binaries..."
    flutter precache --web
    
    # Get dependencies
    echo "Installing dependencies..."
    flutter pub get
}

# Function to build
build_app() {
    echo "--- BUILD PHASE ---"
    
    # Ensure flutter is in PATH
    if [ -d "$HOME/flutter" ]; then
        export PATH="$PATH:$HOME/flutter/bin"
    elif [ -d "$(pwd)/flutter" ]; then
        export PATH="$PATH:$(pwd)/flutter/bin"
    fi

    # Check if flutter is available
    if ! command -v flutter &> /dev/null; then
        echo "Error: Flutter not found in PATH for build phase."
        exit 1
    fi

    echo "Starting Web Build (PWA enabled)..."
    
    # Explicitly using canvaskit for PWA premium feel, but fallback to auto
    # We remove --web-renderer html as it might be older or causing issues
    # We keep it simple to avoid tool crashes
    flutter build web --release --base-href / --pwa-strategy offline-first
    
    if [ $? -eq 0 ]; then
        echo "Build complete! Output in build/web"
        # Optional: Print size of build
        du -sh build/web
    else
        echo "Error: Flutter build failed."
        exit 1
    fi
}

# Run based on argument
case "$1" in
    "setup")
        setup_flutter
        ;;
    "build")
        build_app
        ;;
    *)
        # Default: Setup then Build
        setup_flutter
        build_app
        ;;
esac
