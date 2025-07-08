#!/bin/bash

echo "🚀 Starting Firebase Emulators (Simple Mode)..."

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed or not in PATH"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
echo "📦 Node.js version: $(node -v)"

if [ "$NODE_VERSION" -lt 20 ]; then
    echo "⚠️  Warning: Node.js version is below 20. Firebase CLI may not work properly."
    echo "💡 Consider upgrading Node.js: nvm install 20 && nvm use 20"
fi

# Try to start emulators using different methods
echo "🔄 Attempting to start Firebase emulators..."

# Method 1: Try with npx
if command -v npx &> /dev/null; then
    echo "📦 Trying with npx..."
    npx firebase emulators:start --only auth,firestore,storage --import=./firebase-data --export-on-exit=./firebase-data &
    EMULATOR_PID=$!
    sleep 10
    
    # Check if emulators are running
    if curl -s http://localhost:4000 > /dev/null 2>&1; then
        echo "✅ Emulators started successfully with npx!"
        echo "🌐 Emulator UI: http://localhost:4000"
        echo "🔥 Auth: http://localhost:9099"
        echo "📚 Firestore: http://localhost:8080"
        echo "📦 Storage: http://localhost:9199"
        echo "🔄 Process ID: $EMULATOR_PID"
        echo "🛑 To stop emulators: kill $EMULATOR_PID"
        exit 0
    else
        echo "❌ npx method failed"
        kill $EMULATOR_PID 2>/dev/null
    fi
fi

# Method 2: Try with direct firebase command
if command -v firebase &> /dev/null; then
    echo "🔥 Trying with direct firebase command..."
    firebase emulators:start --only auth,firestore,storage --import=./firebase-data --export-on-exit=./firebase-data &
    EMULATOR_PID=$!
    sleep 10
    
    # Check if emulators are running
    if curl -s http://localhost:4000 > /dev/null 2>&1; then
        echo "✅ Emulators started successfully with firebase command!"
        echo "🌐 Emulator UI: http://localhost:4000"
        echo "🔥 Auth: http://localhost:9099"
        echo "📚 Firestore: http://localhost:8080"
        echo "📦 Storage: http://localhost:9199"
        echo "🔄 Process ID: $EMULATOR_PID"
        echo "🛑 To stop emulators: kill $EMULATOR_PID"
        exit 0
    else
        echo "❌ Direct firebase command failed"
        kill $EMULATOR_PID 2>/dev/null
    fi
fi

# Method 3: Manual setup instructions
echo "❌ Could not start emulators automatically"
echo ""
echo "🔧 Manual Setup Instructions:"
echo "1. Upgrade Node.js to version 20 or higher:"
echo "   nvm install 20 && nvm use 20"
echo ""
echo "2. Install Firebase CLI globally:"
echo "   npm install -g firebase-tools"
echo ""
echo "3. Start emulators manually:"
echo "   firebase emulators:start --only auth,firestore,storage"
echo ""
echo "4. Or use the Flutter Firebase emulator:"
echo "   flutterfire configure"
echo "   flutterfire emulators:start"
echo ""
echo "📚 For more information, see: https://firebase.google.com/docs/emulator-suite"

exit 1 