# Legendary Motors - PWA Testing Guide

## ✅ PWA Build Successful!

Your app has been built as a Progressive Web App. Here's what works and how to test it:

## Hardware Features Support:

### ✅ **GPS/Location** - FULL SUPPORT
- Browser will prompt "Allow location access"
- Works on both desktop (using WiFi triangulation) and mobile (using GPS)
- Your blue dot and real-time tracking will work!

### ✅ **Camera** - FULL SUPPORT  
- Browser will prompt for camera permission
- Works for capturing photos

### ⚠️ **Tilt/Parallax Sensors** - LIMITED SUPPORT
- May not work on desktop browsers
- Works on mobile browsers with device orientation API
- The TiltParallax effect might be disabled on web

## How to Test:

### Option 1: Local Testing (Current Running Server)
The app is now running at `http://localhost:PORT` in Chrome.

1. Open Chrome DevTools (F12)
2. Click the mobile device icon (toggle device toolbar)
3. Select a mobile device (e.g., iPhone 14 Pro)
4. Test GPS by clicking "Allow" when prompted

### Option 2: Deploy for Mobile Testing
To test on your actual phone:

1. **Using ngrok** (easiest):
   ```bash
   # Install ngrok first: brew install ngrok
   cd build/web
   python3 -m http.server 8000 &
   ngrok http 8000
   ```
   Then open the ngrok URL on your phone!

2. **Using Firebase Hosting** (recommended for sharing):
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init hosting  # Choose build/web as public directory
   firebase deploy
   ```
   You'll get a permanent URL like `legendary-motors-xxxxx.web.app`

### Option 3: Test Locally on Phone (Same WiFi)
```bash
cd build/web
python3 -m http.server 8000
```
Then on your phone, go to `http://YOUR_COMPUTER_IP:8000`

## PWA Installation:
When you open the web app in a mobile browser (Chrome/Safari), you'll see an "Add to Home Screen" prompt. This makes it look and feel like a native app!

## Notes:
- The build is in `build/web/` directory
- All network requests, maps, and routing will work
- Performance might be slightly slower than native app
