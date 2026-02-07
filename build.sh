#!/bin/bash

# Ensure we are in the project root
cd "$(dirname "$0")"

# Function to setup Flutter
setup_flutter() {
    echo "--- SETUP PHASE ---"
    
    # In Vercel, we need to ensure Flutter is installed
    if ! command -v flutter &> /dev/null; then
        if [ -d "$HOME/flutter" ]; then
            export PATH="$PATH:$HOME/flutter/bin"
        elif [ -d "$(pwd)/flutter" ]; then
            export PATH="$PATH:$(pwd)/flutter/bin"
        else
            echo "Installing Flutter..."
            git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
            export PATH="$PATH:$HOME/flutter/bin"
        fi
    fi

    # Handle .env for Vercel (Injecting Environment Variables)
    if [ ! -f .env ]; then
        echo "Creating .env file from environment variables..."
        touch .env
        
        # List of variables to inject if they exist in the environment
        vars=("STRIPE_KEY" "STRIPE_SECRET" "OPENWEATHER_API_KEY" "GOOGLE_CLIENT_ID_WEB" "GOOGLE_CLIENT_ID_IOS" "API_BASE_URL")
        
        for var in "${vars[@]}"; do
            if [ ! -z "${!var}" ]; then
                echo "$var=${!var}" >> .env
            fi
        done
        echo ".env file created for build."
    else
        echo ".env file already exists."
    fi

    flutter --version
    flutter precache --web
    flutter pub get
}

# Function to build
build_app() {
    echo "--- BUILD PHASE ---"
    
    # Re-verify path for build phase
    if [ -d "$HOME/flutter" ]; then
        export PATH="$PATH:$HOME/flutter/bin"
    fi

    # Check if flutter is available
    if ! command -v flutter &> /dev/null; then
        echo "Error: Flutter not found. Attempting emergency setup..."
        setup_flutter
    fi

    echo "Building Flutter Web..."
    # We use --no-wasm-dry-run to stop the tool from exiting with warnings on some environments
    flutter build web --release --base-href / --pwa-strategy offline-first --no-wasm-dry-run
    
    if [ $? -eq 0 ]; then
        echo "Build successful."
    else
        echo "Build failed."
        exit 1
    fi
}

case "$1" in
    "setup")
        setup_flutter
        ;;
    "build")
        build_app
        ;;
    *)
        setup_flutter
        build_app
        ;;
esac
