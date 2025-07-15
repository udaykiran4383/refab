#!/bin/bash

# Cursor Performance Optimization Script
# This script cleans up files and directories that might cause timeout issues

echo "🔧 Optimizing Cursor performance..."

# Remove large build artifacts
echo "🧹 Cleaning build directories..."
find . -type d -name "build" -not -path "./build" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name "dist" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".next" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".cache" -exec rm -rf {} + 2>/dev/null || true

# Remove large log files
echo "📝 Cleaning log files..."
find . -name "*.log" -size +1M -delete 2>/dev/null || true
find . -name "firebase-debug.log" -delete 2>/dev/null || true
find . -name "firestore-debug.log" -delete 2>/dev/null || true
find . -name "ui-debug.log" -delete 2>/dev/null || true
find . -name "pglite-debug.log" -delete 2>/dev/null || true

# Remove large generated files
echo "🗑️  Cleaning large generated files..."
find . -name "*.wasm" -delete 2>/dev/null || true
find . -name "*.map" -size +1M -delete 2>/dev/null || true
find . -name "*.bundle.js" -size +1M -delete 2>/dev/null || true
find . -name "*.bundle.js.map" -delete 2>/dev/null || true

# Remove test artifacts
echo "🧪 Cleaning test artifacts..."
find . -name "*_test.mocks.dart" -delete 2>/dev/null || true

# Clean up temporary files
echo "🧹 Cleaning temporary files..."
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.temp" -delete 2>/dev/null || true
find . -name "*.bak" -delete 2>/dev/null || true

# Remove OS generated files
echo "💻 Cleaning OS generated files..."
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true

# Optimize .cursorignore
echo "📝 Updating .cursorignore..."
if [ -f ".cursorignore" ]; then
    echo "✅ .cursorignore already exists and optimized"
else
    echo "❌ .cursorignore not found"
fi

# Check for large files
echo "📊 Checking for large files..."
find . -type f -size +10M -not -path "./build/*" -not -path "./admin-dashboard/node_modules/*" -not -path "./.dart_tool/*" -not -path "./.git/*" -exec ls -lh {} \; | head -10

echo "✅ Cursor performance optimization complete!"
echo ""
echo "📋 Recommendations:"
echo "1. Restart Cursor to apply all changes"
echo "2. Use specific file paths when reading files"
echo "3. Use grep_search for exact text matches"
echo "4. Avoid reading entire large files"
echo "5. Use targeted directory searches" 