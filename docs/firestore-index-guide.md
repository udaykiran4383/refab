# 🔥 Firestore Index Management Guide

## Overview

This guide helps you manage Firestore composite indexes for the ReFab app. Firestore requires composite indexes when you use multiple `.where()` clauses or combine `.where()` with `.orderBy()` in your queries.

## 🚨 Common Error

When you see this error:
```
[cloud_firestore/failed-precondition] The query requires an index. You can create it here: <URL>
```

**This means you need to create a composite index for your query.**

## 🚀 Quick Fix

### Method 1: Use the Error Link (Recommended)
1. **Copy the error link** from the Firebase error message
2. **Paste it in your browser** - it will take you directly to the Firebase Console
3. **Click "Create Index"** - the fields will be pre-filled
4. **Wait 1-2 minutes** for the index to build
5. **Re-run your app** - the error will be gone!

### Method 2: Use Our Script
```bash
# Run the interactive script
node scripts/fix_firestore_index.js

# Then paste your error link when prompted
```

## 📋 Required Indexes for ReFab App

### 1. Pickup Requests
**Collection:** `pickupRequests`
**Fields:**
- `status` (ASCENDING)
- `logistics_id` (ASCENDING) 
- `created_at` (DESCENDING)

**Used by:** `getAvailablePickupRequests()` - finds pending requests without logistics assignment

### 2. Logistics Assignments
**Collection:** `logisticsAssignments`
**Fields:**
- `pickup_request_id` (ASCENDING)
- `type` (ASCENDING)

**Used by:** Checking existing logistics assignments for pickup requests

### 3. Volunteer Hours
**Collection:** `volunteerHours`
**Fields:**
- `volunteerId` (ASCENDING)
- `logDate` (ASCENDING)

**Used by:** `getVolunteerHoursByDateRange()` - volunteer hours by date range

### 4. Volunteer Tasks
**Collection:** `volunteerTasks`
**Fields:**
- `assignedVolunteerId` (ASCENDING)
- `createdAt` (DESCENDING)

**Used by:** `getVolunteerTasks()` - volunteer tasks ordered by creation date

### 5. Warehouse Inventory
**Collection:** `warehouseInventory`
**Fields:**
- `warehouseId` (ASCENDING)
- `status` (ASCENDING)

**Used by:** Filtering warehouse inventory by warehouse ID and status

## 🔧 Manual Index Creation

### Step-by-Step Process

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/indexes

2. **Click "Create Index"**

3. **Configure the Index**
   - **Collection ID:** Enter the collection name (e.g., `pickupRequests`)
   - **Fields:** Add each field in the exact order specified
   - **Order:** Set to ASCENDING or DESCENDING as required

4. **Create the Index**
   - Click "Create" button
   - Wait for the index to build (usually 1-2 minutes)

5. **Monitor Progress**
   - Status will show "Building" → "Enabled"
   - Only works when status is "Enabled"

## 📊 Index Management Best Practices

### ✅ Do's
- **Create indexes as needed** - Firestore will tell you exactly what's needed
- **Wait for indexes to build** - Don't expect immediate results
- **Monitor index usage** - Check which indexes are actually being used
- **Delete unused indexes** - Stay under the 200 composite index limit

### ❌ Don'ts
- **Don't create unnecessary indexes** - Only create what Firestore requests
- **Don't delete indexes in use** - This will break your queries
- **Don't expect instant results** - Index building takes time

## 🛠️ Troubleshooting

### Index Not Building
- **Check field names** - Make sure they match your data exactly
- **Verify field types** - Ensure the field exists in your documents
- **Check permissions** - Make sure you have write access to Firestore

### Still Getting Errors
- **Wait longer** - Some indexes take up to 5 minutes to build
- **Check collection name** - Ensure it matches your Firestore collection
- **Verify field order** - Fields must be in the exact order specified

### Multiple Index Errors
- **Create them one by one** - Don't try to create all at once
- **Wait between creations** - Let each index build before creating the next
- **Use the error links** - Each error provides the exact index needed

## 📈 Performance Considerations

### Index Costs
- **Storage:** Each index uses additional storage
- **Write operations:** Indexes are updated on every write
- **Query performance:** Indexes make queries faster

### Optimization Tips
- **Use specific queries** - Avoid broad range queries when possible
- **Limit result sets** - Use `.limit()` to reduce data transfer
- **Monitor usage** - Remove indexes that aren't being used

## 🔍 Monitoring Index Usage

### Firebase Console
1. Go to Firestore → Indexes
2. Check the "Usage" column
3. Look for indexes with low usage
4. Consider removing unused indexes

### Index Metrics
- **Query count:** How many times the index was used
- **Document count:** How many documents are indexed
- **Storage used:** How much space the index consumes

## 🚀 Automation Scripts

### View All Required Indexes
```bash
node scripts/setup_firestore_indexes.js
```

### Get Firestore Rules
```bash
node scripts/setup_firestore_indexes.js --rules
```

### Quick Fix for Specific Error
```bash
node scripts/fix_firestore_index.js
```

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Index Limits](https://firebase.google.com/docs/firestore/quotas#indexes)
- [Query Performance](https://firebase.google.com/docs/firestore/query-data/best-practices)

## 🆘 Need Help?

If you're still having issues:

1. **Check the error message** - It contains the exact index needed
2. **Use the provided link** - Firebase gives you a direct link to create the index
3. **Verify your data** - Make sure the fields exist in your documents
4. **Wait for index building** - Don't expect immediate results

Remember: **Firestore will tell you exactly what index you need and provide a link to create it!** 