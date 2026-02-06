# Deploying to Vercel

This Flutter web app is configured for deployment to Vercel.

## Prerequisites

- A Vercel account (sign up at [vercel.com](https://vercel.com))
- Access to this GitHub repository

## Deployment Steps

### Option 1: Deploy via Vercel Dashboard (Recommended)

1. **Go to Vercel Dashboard**
   - Visit [vercel.com/new](https://vercel.com/new)
   - Sign in with your GitHub account

2. **Import Your Repository**
   - Click "Add New Project"
   - Select your `LegendaryMotors-App` repository
   - Click "Import"

3. **Configure Project**
   - **Framework Preset**: Select "Other"
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: Leave default or use:
     ```bash
     git clone -b stable https://github.com/flutter/flutter.git $HOME/flutter && export PATH="$PATH:$HOME/flutter/bin" && flutter pub get
     ```

4. **Environment Variables**
   Add your environment variables in the Vercel dashboard:
   - `API_BASE_URL`: Your backend API URL
   - `STRIPE_PUBLISHABLE_KEY`: Your Stripe key (if needed)
   - Any other secrets from your `.env` file

5. **Deploy**
   - Click "Deploy"
   - Wait for the build to complete (~2-5 minutes)
   - Your app will be live at `https://your-project.vercel.app`

### Option 2: Deploy via Vercel CLI

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy**
   ```bash
   vercel
   ```

4. **Deploy to Production**
   ```bash
   vercel --prod
   ```

## Configuration Files

- **`vercel.json`**: Vercel configuration with routing and headers
- **`.vercelignore`**: Files to exclude from deployment
- **`build.sh`**: Build script (optional)

## Important Notes

### 1. Environment Variables
Make sure to add your `.env` variables to Vercel:
- Go to Project Settings → Environment Variables
- Add each variable from your local `.env` file

### 2. CORS Configuration
The `vercel.json` includes CORS headers for:
- Cross-Origin-Embedder-Policy
- Cross-Origin-Opener-Policy

Adjust these if you encounter CORS issues with your backend.

### 3. Routing
The app uses client-side routing (GoRouter). The `vercel.json` configuration ensures all routes redirect to `index.html` for proper SPA behavior.

### 4. Build Output
The Flutter web build is located in `build/web/` and includes:
- `index.html`
- `flutter.js`
- `main.dart.js`
- `assets/` directory
- Other compiled files

## Automatic Deployments

Once connected to Vercel:
- **Every push to `master`** triggers a production deployment
- **Every pull request** gets a preview deployment
- You can view deployment logs in the Vercel dashboard

## Custom Domain

To add a custom domain:
1. Go to Project Settings → Domains
2. Add your domain
3. Follow Vercel's DNS configuration instructions

## Troubleshooting

### Build Fails
- Check that all dependencies in `pubspec.yaml` are compatible with web
- View build logs in Vercel dashboard for specific errors
- Ensure environment variables are set correctly

### App Doesn't Load
- Check browser console for errors
- Verify API endpoints are accessible from the deployed URL
- Check CORS configuration on your backend

### Routing Issues
- Ensure `vercel.json` routes are configured correctly
- Test with direct URL navigation

## Local Testing

To test the production build locally:
```bash
flutter build web --release
cd build/web
python3 -m http.server 8000
```

Then visit `http://localhost:8000`

## Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
