#!/bin/bash

echo "🚀 Starting Firebase Emulators for Testing..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Start Firebase emulators
echo "🔥 Starting Firebase emulators..."
firebase emulators:start --only auth,firestore,storage

echo "✅ Firebase emulators started!"
echo "📊 Emulator UI: http://localhost:4000"
echo "🔥 Firestore: localhost:8080"
echo "🔐 Auth: localhost:9099"
echo "📦 Storage: localhost:9199" 