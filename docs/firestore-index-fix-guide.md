# Firestore Index Fix Guide

## Problem
You're getting Firestore index errors like:
```
Error: [cloud_firestore/failed-precondition] The query requires an index.
```

This happens when your Firestore queries use multiple fields with ordering, which requires composite indexes.

## Root Cause
Looking at your warehouse repository code, the following queries are causing the errors:

1. **warehouseWorkers collection**: Queries with `warehouseId` + `createdAt` ordering
2. **processingTasks collection**: Queries with `warehouseId` + `createdAt` ordering  
3. **inventory collection**: Queries with `warehouseId` + `createdAt` ordering
4. **warehouseLocations collection**: Queries with `warehouseId` + `createdAt` ordering

## Solution

### Option 1: Firebase Console (Recommended)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/project/refab-app/firestore/indexes

2. **Create Indexes for Each Collection**

   **For warehouseWorkers:**
   - Collection ID: `warehouseWorkers`
   - Fields:
     - `warehouseId` (Ascending)
     - `createdAt` (Descending)
     - `__name__` (Ascending)

   **For processingTasks:**
   - Collection ID: `processingTasks`
   - Fields:
     - `warehouseId` (Ascending)
     - `createdAt` (Descending)
     - `__name__` (Ascending)

   **For inventory:**
   - Collection ID: `inventory`
   - Fields:
     - `warehouseId` (Ascending)
     - `createdAt` (Descending)
     - `__name__` (Ascending)

   **For warehouseLocations:**
   - Collection ID: `warehouseLocations`
   - Fields:
     - `warehouseId` (Ascending)
     - `createdAt` (Descending)
     - `__name__` (Ascending)

3. **Wait for Indexes to Build**
   - Indexes take 1-2 minutes to build
   - Monitor progress in Firebase Console
   - Status will show "Enabled" when ready

### Option 2: Firebase CLI

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firestore**
   ```bash
   firebase init firestore
   ```

4. **Deploy Indexes**
   ```bash
   firebase deploy --only firestore:indexes
   ```

## Additional Indexes Needed

Based on your code, you'll also need these additional composite indexes:

### warehouseWorkers with Status/Role Filters
- `warehouseId` + `status` + `createdAt` + `__name__`
- `warehouseId` + `role` + `createdAt` + `__name__`

### processingTasks with Status/Worker/TaskType Filters
- `warehouseId` + `status` + `createdAt` + `__name__`
- `warehouseId` + `assignedWorkerId` + `createdAt` + `__name__`
- `warehouseId` + `taskType` + `createdAt` + `__name__`

### inventory with Status/Category/Quality Filters
- `warehouseId` + `status` + `createdAt` + `__name__`
- `warehouseId` + `fabricCategory` + `createdAt` + `__name__`
- `warehouseId` + `qualityGrade` + `createdAt` + `__name__`

### warehouseLocations with Status/Type Filters
- `warehouseId` + `status` + `createdAt` + `__name__`
- `warehouseId` + `type` + `createdAt` + `__name__`

## Important Notes

1. **Field Order Matters**: The order of fields in the index must match your query exactly
2. **__name__ Field**: Firestore automatically adds this field for consistent ordering
3. **Index Building Time**: Indexes take time to build, especially for large collections
4. **Cost**: Composite indexes consume more storage and have higher read costs

## Verification

After creating the indexes:

1. Wait for all indexes to show "Enabled" status
2. Restart your Flutter app
3. Test the warehouse management features
4. Check that the error messages are gone

## Troubleshooting

If you still get index errors:

1. **Check Index Status**: Ensure all indexes are "Enabled" in Firebase Console
2. **Verify Field Names**: Make sure field names match exactly (case-sensitive)
3. **Check Query Order**: Ensure your query field order matches the index
4. **Wait Longer**: Large collections may take longer to build indexes

## Files Created

- `firestore.indexes.json`: Complete index configuration
- `scripts/fix_firestore_index.js`: Helper script to generate index configs

## Quick Fix Commands

```bash
# Run the helper script
node scripts/fix_firestore_index.js

# If using Firebase CLI
firebase deploy --only firestore:indexes
```

## Support

If you continue to have issues:
1. Check the Firebase Console for any index build errors
2. Verify your Firebase project configuration
3. Ensure you have the correct permissions to create indexes 