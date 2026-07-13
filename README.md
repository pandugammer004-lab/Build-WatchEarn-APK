# WatchEarn Setup Guide

## Prerequisites
- Flutter SDK 3.19+
- Firebase account
- Android Studio / VS Code
- Google AdMob account

## Step 1: Firebase Setup
1. Create Firebase project
2. Add Android app (com.watchearn.app)
3. Add iOS app
4. Download `google-services.json` → `android/app/`
5. Download `GoogleService-Info.plist` → `ios/Runner/`
6. Enable Authentication (Email + Google)
7. Create Firestore database
8. Enable Firebase Storage
9. Enable Firebase Messaging

## Step 2: AdMob Setup
1. Create AdMob account
2. Create Android app in AdMob
3. Create iOS app in AdMob
4. Create ad units:
   - Banner
   - Interstitial
   - Rewarded
5. Replace test IDs in `ad_ids.dart`

## Step 3: Google Sign In
1. Add SHA-1 fingerprint to Firebase
2. Download updated `google-services.json`

## Step 4: Initial Data Setup
Run this in Firebase Console:

Collections to create:
- `appConfig` (document: config)
- `categories` (10 default categories)
- `videos` (add your YouTube videos)

## Step 5: Admin Panel
1. Set admin email in `admin_login.dart`
2. Deploy to Firebase Hosting:
   ```bash
   flutter build web
   firebase deploy --only hosting
   ```

## Step 6: First Video Setup
1. Upload video to YouTube
2. Copy YouTube video ID
3. Login to Admin Panel
4. Go to Videos → Add New Video
5. Paste YouTube ID
6. Fill details
7. Save

## Step 7: Publishing
Android:
- `flutter build apk --release`
- `flutter build appbundle --release`
- Upload to Play Store

iOS:
- `flutter build ios --release`
- Upload to App Store

## Ad Revenue Optimization
- US/Europe users = $15-45 RPM
- Use AppLovin MAX for higher RPM
- Enable mediation in AdMob
