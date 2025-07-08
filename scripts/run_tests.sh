#!/bin/bash

echo "🧪 Running ReFab App Tests with Firebase Emulator..."

# Check if Firebase emulators are running
if ! curl -s http://localhost:4000 > /dev/null; then
    echo "🔥 Starting Firebase emulators..."
    ./scripts/start_emulators.sh &
    EMULATOR_PID=$!
    
    # Wait for emulators to start
    echo "⏳ Waiting for emulators to start..."
    sleep 15
    
    # Check if emulators started successfully
    if ! curl -s http://localhost:4000 > /dev/null; then
        echo "❌ Failed to start Firebase emulators"
        exit 1
    fi
    echo "✅ Firebase emulators started successfully"
else
    echo "✅ Firebase emulators already running"
fi

# Run Flutter tests
echo "🚀 Running Flutter tests..."
flutter test --reporter=compact

# Store test exit code
TEST_EXIT_CODE=$?

# Clean up
if [ ! -z "$EMULATOR_PID" ]; then
    echo "🛑 Stopping Firebase emulators..."
    kill $EMULATOR_PID
fi

echo "🧪 Tests completed with exit code: $TEST_EXIT_CODE"
exit $TEST_EXIT_CODE 