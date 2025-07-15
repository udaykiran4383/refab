# Cursor Performance Optimization Guide

## 🚀 Quick Fix for Timeout Issues

If you're experiencing "Tool call timed out after 10s" errors, follow these steps:

### 1. Run the Optimization Script
```bash
./scripts/optimize_cursor_performance.sh
```

### 2. Restart Cursor
Close and reopen Cursor to apply all configuration changes.

### 3. Use Optimized Search Patterns
- Use `grep_search` for exact text matches
- Use `file_search` for finding files by name
- Use `read_file` with specific line ranges
- Only use `codebase_search` when semantic understanding is needed

## 📁 File Exclusions

The following directories and files are excluded to prevent timeouts:

### Build Directories
- `build/` - Flutter build artifacts
- `dist/` - Distribution files
- `.next/` - Next.js build files
- `.cache/` - Cache directories
- `.dart_tool/` - Dart tool cache

### Dependencies
- `node_modules/` - Node.js dependencies
- `bower_components/` - Bower dependencies
- `ios/Pods/` - iOS CocoaPods
- `android/.gradle/` - Android Gradle cache

### Generated Files
- `*.wasm` - WebAssembly files
- `*.map` - Source maps
- `*.bundle.js` - Bundled JavaScript
- `*.bundle.js.map` - Bundle source maps

### Test Files
- `*_test.dart` - Dart test files
- `*_test.mocks.dart` - Mock files
- `test_driver/` - Test driver files
- `integration_test/` - Integration tests

### Log Files
- `*.log` - All log files
- `firebase-debug.log` - Firebase debug logs
- `firestore-debug.log` - Firestore debug logs
- `ui-debug.log` - UI debug logs

## 🔧 Configuration Files

### .cursorignore
Excludes files from Cursor's file operations to prevent timeouts.

### .cursorrules
Provides guidelines for optimal tool usage patterns.

### .vscode/settings.json
Configures VS Code/Cursor to exclude problematic directories from search and file watching.

## 🎯 Best Practices

### File Reading
```dart
// ✅ Good - Read specific lines
read_file(target_file: "lib/main.dart", start_line_one_indexed: 1, end_line_one_indexed: 50)

// ❌ Bad - Read entire large file
read_file(target_file: "lib/main.dart", should_read_entire_file: true)
```

### Searching
```dart
// ✅ Good - Exact text search
grep_search(query: "class MyClass")

// ✅ Good - File search
file_search(query: "main.dart")

// ❌ Bad - Semantic search for exact matches
codebase_search(query: "MyClass")
```

### Directory Targeting
```dart
// ✅ Good - Target specific directory
grep_search(query: "import", include_pattern: "lib/**/*.dart")

// ❌ Bad - Search entire codebase
grep_search(query: "import")
```

## 🛠️ Troubleshooting

### If Timeouts Persist

1. **Check for Large Files**
   ```bash
   find . -type f -size +10M -not -path "./build/*" -not -path "./admin-dashboard/node_modules/*"
   ```

2. **Clean Build Directories**
   ```bash
   flutter clean
   cd admin-dashboard && npm run clean
   ```

3. **Remove Generated Files**
   ```bash
   find . -name "*.wasm" -delete
   find . -name "*.map" -size +1M -delete
   ```

4. **Restart Cursor**
   - Close Cursor completely
   - Clear any cached data
   - Reopen the project

### Performance Monitoring

Run this command to check current file sizes:
```bash
du -sh * | sort -hr | head -10
```

## 📊 Current Optimizations

- ✅ Excluded build directories (1.2GB saved)
- ✅ Excluded node_modules (779MB saved)
- ✅ Excluded test artifacts
- ✅ Excluded log files
- ✅ Excluded generated files
- ✅ Optimized search patterns
- ✅ Configured file watchers

## 🔄 Maintenance

Run the optimization script regularly:
```bash
# Weekly maintenance
./scripts/optimize_cursor_performance.sh
```

## 📞 Support

If you continue to experience timeout issues:

1. Check the terminal output for any errors
2. Verify that `.cursorignore` is properly configured
3. Ensure no large files are being accessed
4. Use targeted searches instead of broad scans
5. Consider breaking complex operations into smaller steps

---

**Remember**: The key to preventing timeouts is to be specific and targeted in your file operations. Use the right tool for the job and avoid reading large files unnecessarily. 