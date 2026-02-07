# Legendary Motors PWA & Web Optimization

This document outlines the premium optimizations and PWA features implemented for the Legendary Motors web application.

## 🎨 Premium Aesthetics
- **Splash Screen**: A custom high-fidelity loader (Red circular ring) matching the brand palette (#E30613) with a deep black background (#0A0A0A) for a premium "first-launch" experience.
- **Glassmorphism**: Hand-crafted CSS overlays on the web entry point to ensure a seamless transition from browser to app.
- **Responsive Typography**: Integrated Google Fonts (Outfit and Inter) via optimized web loading.

## 📱 PWA Features
- **Offline Strategy**: Implemented `offline-first` strategy via Flutter build flags.
- **Installability**:
  - Custom `manifest.json` with high-resolution maskable icons.
  - Native-feel status bar configuration (`black-translucent`).
  - Home-screen shortcut branding ("Legendary Motors").
- **Asset Buffering**: Service worker optimized for quick loading of high-resolution car imagery.

## 🚀 Vercel Deployment Optimization
- **Build Automation**: Custom `build.sh` script to handle Flutter environment setup, `.env` injection, and PWA compilation.
- **Environment Safety**: 
  - Isolated mobile-only dependencies (`sqflite`, `dart:io`) using conditional exports.
  - Automatic `.env` generation from Vercel's secret management.
- **Platform Resilience**: Integrated `--no-wasm-dry-run` to ensure CI stability across all Vercel build nodes.

## 🛠 Web Compatibility
- **Auth Flow**: Dynamic Client ID detection (Web vs iOS) to prevent Google OAuth 400 errors.
- **Storage**: Stubbed SQLite layers to provide graceful no-op behavior on browsers while maintaining full functionality on mobile.
