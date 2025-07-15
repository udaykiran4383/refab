# Environment Setup Template

## 🔐 Environment Files to Create

### 1. Root `.env.local`
Create this file in the project root:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id-here
FIREBASE_API_KEY=your-api-key-here
FIREBASE_APP_ID=your-app-id-here
FIREBASE_MESSAGING_SENDER_ID=your-sender-id-here
FIREBASE_STORAGE_BUCKET=your-storage-bucket-here

# Development Configuration
NODE_ENV=development
FLUTTER_ENV=development

# Optional: Analytics
FIREBASE_ANALYTICS_ENABLED=true
```

### 2. Admin Dashboard `.env.local`
Create this file in `admin-dashboard/.env.local`:

```env
# Firebase Admin SDK
FIREBASE_PROJECT_ID=your-project-id-here
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account-email@your-project.iam.gserviceaccount.com

# Next.js Public Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=your-api-key-here
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id-here
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your-sender-id-here
NEXT_PUBLIC_FIREBASE_APP_ID=your-app-id-here

# Development Configuration
NODE_ENV=development
NEXT_PUBLIC_ENVIRONMENT=development
```

## 📱 Firebase Configuration Files

### 1. Android Configuration
File: `android/app/google-services.json`
```json
{
  "project_info": {
    "project_number": "your-project-number",
    "project_id": "your-project-id",
    "storage_bucket": "your-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "your-app-id",
        "android_client_info": {
          "package_name": "com.example.refabapp5"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "your-api-key"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ]
}
```

### 2. iOS Configuration
File: `ios/Runner/GoogleService-Info.plist`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>your-api-key</string>
    <key>GCM_SENDER_ID</key>
    <string>your-sender-id</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.example.refabapp5</string>
    <key>PROJECT_ID</key>
    <string>your-project-id</string>
    <key>STORAGE_BUCKET</key>
    <string>your-project-id.appspot.com</string>
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
    <string>your-app-id</string>
</dict>
</plist>
```

### 3. macOS Configuration
File: `macos/Runner/GoogleService-Info.plist`
(Same content as iOS configuration)

## 🔑 How to Get Firebase Configuration

### 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to Project Settings (gear icon)
4. Add your app (Android/iOS/Web)

### 2. Get Configuration Values
- **Project ID**: Found in project settings
- **API Key**: Found in project settings > General tab
- **App ID**: Found in project settings > General tab
- **Sender ID**: Found in project settings > Cloud Messaging tab
- **Storage Bucket**: Found in project settings > General tab

### 3. Service Account (for Admin SDK)
1. Go to Project Settings > Service Accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Extract the values for the admin dashboard `.env.local`

## 🚨 Security Notes

### DO NOT COMMIT
- `.env.local` files
- `google-services.json`
- `GoogleService-Info.plist`
- Service account private keys
- Any files containing API keys or secrets

### DO COMMIT
- `.env.example` files (templates)
- `firebase_options.dart` (generated file)
- `firebase.json`
- `firestore.indexes.json`

## 📋 Setup Checklist

- [ ] Create `.env.local` in project root
- [ ] Create `admin-dashboard/.env.local`
- [ ] Add `google-services.json` to Android folder
- [ ] Add `GoogleService-Info.plist` to iOS folder
- [ ] Add `GoogleService-Info.plist` to macOS folder
- [ ] Verify Firebase project is active
- [ ] Test Flutter app connection
- [ ] Test admin dashboard connection
- [ ] Verify all environment variables are set

## 🔧 Troubleshooting

### Common Issues
1. **"Firebase not initialized"**: Check configuration files
2. **"Permission denied"**: Check Firestore security rules
3. **"API key invalid"**: Verify API key in Firebase console
4. **"Project not found"**: Check project ID spelling

### Verification Commands
```bash
# Test Flutter Firebase connection
flutter run --verbose

# Test admin dashboard
cd admin-dashboard
npm run dev

# Test Firebase CLI
firebase projects:list
```

---

**Remember**: Never share or commit actual API keys and secrets! 