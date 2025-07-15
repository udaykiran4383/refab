# Cursor Setup Guide for New Developer

## 🎯 Cursor Configuration for ReFab Project

This guide helps the new developer set up Cursor IDE optimally for the ReFab project.

## 📋 Prerequisites

1. **Install Cursor IDE** from https://cursor.sh/
2. **Install Flutter SDK** and add to PATH
3. **Install Node.js** (v16+)
4. **Install Firebase CLI**: `npm install -g firebase-tools`

## 🔧 Cursor Extensions Setup

### Essential Extensions
Install these extensions in Cursor:

1. **Flutter & Dart**
   - `Dart-Code.dart-code`
   - `Dart-Code.flutter`

2. **Firebase**
   - `firebase.firebase-vscode`

3. **Git & GitHub**
   - `GitHub.vscode-pull-request-github`
   - `eamodio.gitlens`

4. **JavaScript/TypeScript**
   - `ms-vscode.vscode-typescript-next`
   - `bradlc.vscode-tailwindcss`

5. **General Development**
   - `ms-vscode.vscode-json`
   - `redhat.vscode-yaml`
   - `ms-vscode.vscode-eslint`

## ⚙️ Cursor Settings

### Workspace Settings
Create `.vscode/settings.json` in the project root:

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "files.exclude": {
    "**/.dart_tool": true,
    "**/.flutter-plugins": true,
    "**/.flutter-plugins-dependencies": true,
    "**/build": true,
    "**/node_modules": true,
    "**/.env.local": false
  },
  "search.exclude": {
    "**/build": true,
    "**/node_modules": true,
    "**/.dart_tool": true
  },
  "emmet.includeLanguages": {
    "dart": "html"
  }
}
```

### Cursor AI Configuration
Create `.cursorrules` in the project root:

```markdown
# ReFab Project Cursor Rules

## Project Context
This is a Flutter-based textile recycling platform with Firebase backend and Next.js admin dashboard.

## Code Style
- Use feature-based architecture for Flutter
- Follow Flutter/Dart conventions
- Use Riverpod for state management
- Implement proper error handling
- Add comprehensive logging

## File Organization
- Keep features in separate directories
- Use proper naming conventions
- Separate UI, business logic, and data layers
- Follow the existing project structure

## Firebase Integration
- Use Firestore for data storage
- Implement proper security rules
- Handle authentication properly
- Use real-time listeners where appropriate

## Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for workflows
- Maintain test coverage

## Performance
- Optimize Firebase queries
- Use proper caching strategies
- Minimize widget rebuilds
- Handle large datasets efficiently

## Security
- Validate all user inputs
- Implement proper authentication
- Use secure Firebase rules
- Handle sensitive data properly
```

## 🚀 Quick Start Commands

### Terminal Commands for Cursor
Open Cursor's integrated terminal and run:

```bash
# Flutter setup
flutter doctor
flutter pub get
flutter run

# Admin dashboard setup
cd admin-dashboard
npm install
npm run dev

# Firebase setup
firebase login
firebase init
```

## 📁 Key Files to Familiarize With

### Flutter Core Files
- `lib/main.dart` - App entry point
- `lib/app/app.dart` - Router configuration
- `lib/features/auth/` - Authentication system
- `lib/features/dashboard/` - Main dashboard
- `pubspec.yaml` - Dependencies

### Admin Dashboard Files
- `admin-dashboard/package.json` - Dependencies
- `admin-dashboard/app/page.js` - Main dashboard
- `admin-dashboard/components/` - UI components

### Configuration Files
- `firebase.json` - Firebase configuration
- `firestore.indexes.json` - Database indexes
- `.env.local` - Environment variables
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config

## 🔍 Debugging Setup

### Flutter Debugging
1. Set breakpoints in Dart files
2. Use `print()` statements for logging
3. Check Flutter Inspector for widget debugging
4. Use Firebase Console for backend debugging

### Admin Dashboard Debugging
1. Use browser DevTools
2. Check Network tab for API calls
3. Use console.log for JavaScript debugging
4. Check Firebase Console for data

## 📚 Useful Cursor Shortcuts

### General
- `Cmd/Ctrl + P` - Quick file open
- `Cmd/Ctrl + Shift + P` - Command palette
- `Cmd/Ctrl + B` - Toggle sidebar
- `Cmd/Ctrl + J` - Toggle terminal

### Flutter/Dart
- `F5` - Start debugging
- `Cmd/Ctrl + F5` - Run without debugging
- `Cmd/Ctrl + Shift + F5` - Hot reload
- `Cmd/Ctrl + .` - Quick fixes

### Git
- `Cmd/Ctrl + Shift + G` - Git panel
- `Cmd/Ctrl + Enter` - Commit changes

## 🧪 Testing in Cursor

### Flutter Tests
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/unit/auth_test.dart

# Run with coverage
flutter test --coverage
```

### Admin Dashboard Tests
```bash
cd admin-dashboard
npm test
npm run test:watch
```

## 🔧 Common Issues and Solutions

### Flutter Issues
1. **Hot reload not working**: Restart the app
2. **Dependencies issues**: Run `flutter clean && flutter pub get`
3. **Build errors**: Check Flutter version compatibility

### Firebase Issues
1. **Connection errors**: Check Firebase configuration files
2. **Permission errors**: Verify Firestore rules
3. **Authentication issues**: Check Firebase project settings

### Cursor Issues
1. **Extensions not working**: Reload Cursor window
2. **IntelliSense issues**: Restart language server
3. **Performance issues**: Check file exclusions

## 📞 Support Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Next.js Documentation](https://nextjs.org/docs)

### Project-Specific
- `PROJECT_HANDOVER_GUIDE.md` - Complete project overview
- `REGISTRATION_ROUTING_FIX.md` - Recent fixes
- `docs/` - Additional documentation

### Community
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Cursor Discord](https://discord.gg/cursor)

---

**Happy coding! 🚀**

*Remember to update this guide as you discover new tips and tricks.* 