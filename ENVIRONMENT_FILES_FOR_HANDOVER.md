# Environment Files for Project Handover

## 🔐 **SECURE HANDOVER - DO NOT COMMIT TO GIT**

This file contains all the environment configurations needed for the ReFab project. Share this securely with the new developer.

---

## 1. Root `.env.local`

Create this file in the project root:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=refab-app
FIREBASE_API_KEY=AIzaSyDlePAsvJ0L3IwAMh7dalBGKFa7czfqxDQ
FIREBASE_APP_ID=1:924684180668:web:4aea87a38556d3e0f144b9
FIREBASE_MESSAGING_SENDER_ID=924684180668
FIREBASE_STORAGE_BUCKET=refab-app.firebasestorage.app

# Development Configuration
NODE_ENV=development
FLUTTER_ENV=development

# Optional: Analytics
FIREBASE_ANALYTICS_ENABLED=true
```

---

## 2. Admin Dashboard `.env.local`

Create this file in `admin-dashboard/.env.local`:

```env
# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyDlePAsvJ0L3IwAMh7dalBGKFa7czfqxDQ
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=refab-app.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=refab-app
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=refab-app.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=924684180668
NEXT_PUBLIC_FIREBASE_APP_ID=1:924684180668:web:4aea87a38556d3e0f144b9

# Development Configuration
NODE_ENV=development
NEXT_PUBLIC_ENVIRONMENT=development
```

**Note**: You'll also need to add Firebase Admin SDK credentials. Go to Firebase Console > Project Settings > Service Accounts > Generate new private key, and add:

```env
# Firebase Admin SDK (Add these after getting the service account key)
FIREBASE_PROJECT_ID=refab-app
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account-email@refab-app.iam.gserviceaccount.com
```

---

## 3. Android Configuration

File: `android/app/google-services.json`

```json
{
  "project_info": {
    "project_number": "924684180668",
    "project_id": "refab-app",
    "storage_bucket": "refab-app.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:924684180668:android:17fa4d73fe37b981f144b9",
        "android_client_info": {
          "package_name": "com.refab.app"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyDlePAsvJ0L3IwAMh7dalBGKFa7czfqxDQ"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

---

## 4. iOS Configuration

File: `ios/Runner/GoogleService-Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>API_KEY</key>
        <string>AIzaSyCz_VzoofmMvUjN6kbXkf26F3C6fNVI9so</string>
        <key>GCM_SENDER_ID</key>
        <string>924684180668</string>
        <key>PLIST_VERSION</key>
        <string>1</string>
        <key>BUNDLE_ID</key>
        <string>com.refab.refabApp</string>
        <key>PROJECT_ID</key>
        <string>refab-app</string>
        <key>STORAGE_BUCKET</key>
        <string>refab-app.firebasestorage.app</string>
        <key>IS_ADS_ENABLED</key>
        <false></false>
        <key>IS_ANALYTICS_ENABLED</key>
        <false></false>
        <key>IS_APPINVITE_ENABLED</key>
        <true></true>
        <key>IS_GCM_ENABLED</key>
        <true></true>
        <key>IS_SIGNIN_ENABLED</key>
        <true></true>
        <key>GOOGLE_APP_ID</key>
        <string>1:924684180668:ios:8295a911d356674bf144b9</string>
</dict>
</plist>
```

---

## 5. macOS Configuration

File: `macos/Runner/GoogleService-Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>API_KEY</key>
        <string>AIzaSyCz_VzoofmMvUjN6kbXkf26F3C6fNVI9so</string>
        <key>GCM_SENDER_ID</key>
        <string>924684180668</string>
        <key>PLIST_VERSION</key>
        <string>1</string>
        <key>BUNDLE_ID</key>
        <string>com.refab.refabApp</string>
        <key>PROJECT_ID</key>
        <string>refab-app</string>
        <key>STORAGE_BUCKET</key>
        <string>refab-app.firebasestorage.app</string>
        <key>IS_ADS_ENABLED</key>
        <false></false>
        <key>IS_ANALYTICS_ENABLED</key>
        <false></false>
        <key>IS_APPINVITE_ENABLED</key>
        <true></true>
        <key>IS_GCM_ENABLED</key>
        <true></true>
        <key>IS_SIGNIN_ENABLED</key>
        <true></true>
        <key>GOOGLE_APP_ID</key>
        <string>1:924684180668:ios:8295a911d356674bf144b9</string>
</dict>
</plist>
```

---

## 🔑 Firebase Project Information

### Project Details
- **Project ID**: `refab-app`
- **Project Number**: `924684180668`
- **Storage Bucket**: `refab-app.firebasestorage.app`
- **Auth Domain**: `refab-app.firebaseapp.com`

### App IDs
- **Web App**: `1:924684180668:web:4aea87a38556d3e0f144b9`
- **Android App**: `1:924684180668:android:17fa4d73fe37b981f144b9`
- **iOS App**: `1:924684180668:ios:8295a911d356674bf144b9`

### API Keys
- **Web/Android API Key**: `AIzaSyDlePAsvJ0L3IwAMh7dalBGKFa7czfqxDQ`
- **iOS/macOS API Key**: `AIzaSyCz_VzoofmMvUjN6kbXkf26F3C6fNVI9so`

---

## 📋 Setup Instructions for New Developer

### 1. Create Environment Files
1. Create `.env.local` in project root with the content above
2. Create `admin-dashboard/.env.local` with the content above

### 2. Add Firebase Configuration Files
1. Create `android/app/google-services.json` with the JSON content above
2. Create `ios/Runner/GoogleService-Info.plist` with the XML content above
3. Create `macos/Runner/GoogleService-Info.plist` with the XML content above

### 3. Get Firebase Admin SDK (Additional Step)
1. Go to [Firebase Console](https://console.firebase.google.com/project/refab-app)
2. Navigate to Project Settings > Service Accounts
3. Click "Generate new private key"
4. Download the JSON file
5. Extract the values and add to `admin-dashboard/.env.local`:
   ```env
   FIREBASE_PROJECT_ID=refab-app
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=your-service-account-email@refab-app.iam.gserviceaccount.com
   ```

### 4. Test Setup
```bash
# Test Flutter app
flutter run

# Test admin dashboard
cd admin-dashboard
npm run dev
```

---

## 🚨 Security Notes

### DO NOT COMMIT
- `.env.local` files
- `google-services.json`
- `GoogleService-Info.plist` files
- Service account private keys
- This file (ENVIRONMENT_FILES_FOR_HANDOVER.md)

### DO COMMIT
- `.env.example` files (templates)
- `firebase_options.dart` (generated file)
- `firebase.json`
- `firestore.indexes.json`

---

## 📞 Additional Access Needed

### Firebase Console Access
- Add the new developer as a project member in Firebase Console
- Grant appropriate permissions (Editor or Owner)

### Repository Access
- Grant access to the Git repository
- Set up branch protection rules if needed

### Service Account Access
- Generate new service account keys for the new developer
- Ensure proper IAM permissions

---

**Remember**: Keep these credentials secure and never share them publicly! 