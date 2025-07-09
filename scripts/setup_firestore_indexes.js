#!/usr/bin/env node

/**
 * Firestore Index Setup Script for ReFab App
 * 
 * This script helps you create all the required composite indexes for your Firestore queries.
 * Run this script to get the exact index configurations you need.
 */

const indexes = [
  // ==================== PICKUP REQUESTS ====================
  {
    collection: 'pickupRequests',
    fields: [
      { fieldPath: 'status', order: 'ASCENDING' },
      { fieldPath: 'logistics_id', order: 'ASCENDING' },
      { fieldPath: 'created_at', order: 'DESCENDING' }
    ],
    description: 'For getAvailablePickupRequests() - pending requests without logistics assignment, ordered by creation date'
  },
  
  // ==================== LOGISTICS ASSIGNMENTS ====================
  {
    collection: 'logisticsAssignments',
    fields: [
      { fieldPath: 'pickup_request_id', order: 'ASCENDING' },
      { fieldPath: 'type', order: 'ASCENDING' }
    ],
    description: 'For checking existing logistics assignments for pickup requests'
  },
  
  {
    collection: 'logisticsAssignments',
    fields: [
      { fieldPath: 'logistics_id', order: 'ASCENDING' },
      { fieldPath: 'status', order: 'ASCENDING' }
    ],
    description: 'For filtering logistics assignments by logistics ID and status'
  },
  
  {
    collection: 'logisticsAssignments',
    fields: [
      { fieldPath: 'logistics_id', order: 'ASCENDING' },
      { fieldPath: 'type', order: 'ASCENDING' }
    ],
    description: 'For filtering logistics assignments by logistics ID and type'
  },
  
  // ==================== VOLUNTEER HOURS ====================
  {
    collection: 'volunteerHours',
    fields: [
      { fieldPath: 'volunteerId', order: 'ASCENDING' },
      { fieldPath: 'logDate', order: 'ASCENDING' }
    ],
    description: 'For getVolunteerHoursByDateRange() - volunteer hours by date range'
  },
  
  {
    collection: 'volunteerHours',
    fields: [
      { fieldPath: 'volunteerId', order: 'ASCENDING' },
      { fieldPath: 'isVerified', order: 'ASCENDING' }
    ],
    description: 'For checkCertificateEligibility() - verified volunteer hours'
  },
  
  // ==================== VOLUNTEER TASKS ====================
  {
    collection: 'volunteerTasks',
    fields: [
      { fieldPath: 'assignedVolunteerId', order: 'ASCENDING' },
      { fieldPath: 'taskCategory', order: 'ASCENDING' }
    ],
    description: 'For getTasksByType() - volunteer tasks by category'
  },
  
  {
    collection: 'volunteerTasks',
    fields: [
      { fieldPath: 'assignedVolunteerId', order: 'ASCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' }
    ],
    description: 'For getVolunteerTasks() - volunteer tasks ordered by creation date'
  },
  
  // ==================== CERTIFICATE REQUESTS ====================
  {
    collection: 'certificateRequests',
    fields: [
      { fieldPath: 'volunteerId', order: 'ASCENDING' },
      { fieldPath: 'requestedAt', order: 'DESCENDING' }
    ],
    description: 'For getCertificateRequests() - certificate requests ordered by request date'
  },
  
  // ==================== WAREHOUSE INVENTORY ====================
  {
    collection: 'warehouseInventory',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'status', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse inventory by warehouse ID and status'
  },
  
  {
    collection: 'warehouseInventory',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'fabricCategory', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse inventory by warehouse ID and fabric category'
  },
  
  // ==================== WAREHOUSE TASKS ====================
  {
    collection: 'warehouseTasks',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'status', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse tasks by warehouse ID and status'
  },
  
  {
    collection: 'warehouseTasks',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'assignedWorkerId', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse tasks by warehouse ID and assigned worker'
  },
  
  {
    collection: 'warehouseTasks',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'taskType', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse tasks by warehouse ID and task type'
  },
  
  // ==================== WAREHOUSE WORKERS ====================
  {
    collection: 'warehouseWorkers',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'status', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse workers by warehouse ID and status'
  },
  
  {
    collection: 'warehouseWorkers',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'role', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse workers by warehouse ID and role'
  },
  
  // ==================== WAREHOUSE LOCATIONS ====================
  {
    collection: 'warehouseLocations',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'status', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse locations by warehouse ID and status'
  },
  
  {
    collection: 'warehouseLocations',
    fields: [
      { fieldPath: 'warehouseId', order: 'ASCENDING' },
      { fieldPath: 'type', order: 'ASCENDING' }
    ],
    description: 'For filtering warehouse locations by warehouse ID and type'
  }
];

function generateIndexConfig() {
  console.log('🔥 Firestore Index Configuration for ReFab App\n');
  console.log('📋 Required Composite Indexes:\n');
  
  indexes.forEach((index, i) => {
    console.log(`${i + 1}. Collection: ${index.collection}`);
    console.log(`   Fields:`);
    index.fields.forEach(field => {
      console.log(`     - ${field.fieldPath} (${field.order})`);
    });
    console.log(`   Description: ${index.description}`);
    console.log('');
  });
  
  console.log('🚀 How to Create These Indexes:\n');
  console.log('1. Go to Firebase Console → Firestore Database → Indexes');
  console.log('2. Click "Create Index"');
  console.log('3. For each index above:');
  console.log('   - Select the collection name');
  console.log('   - Add the fields in the exact order shown');
  console.log('   - Set the order (ASCENDING/DESCENDING) as specified');
  console.log('   - Click "Create"');
  console.log('4. Wait for indexes to build (usually 1-2 minutes)');
  console.log('');
  
  console.log('⚠️  Important Notes:');
  console.log('- Indexes take time to build. Wait until status shows "Enabled"');
  console.log('- You can only create 200 composite indexes per database');
  console.log('- Monitor index usage in Firebase Console');
  console.log('- Delete unused indexes to stay under the limit');
  console.log('');
  
  console.log('🔗 Firebase Console URL:');
  console.log('https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/indexes');
  console.log('');
  
  console.log('📚 For more information:');
  console.log('https://firebase.google.com/docs/firestore/query-data/indexing');
}

function generateFirestoreRules() {
  console.log('🔒 Recommended Firestore Security Rules:\n');
  console.log(`rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Pickup requests - tailors can create, admins can read all
    match /pickupRequests/{requestId} {
      allow read, write: if request.auth != null;
    }
    
    // Products - everyone can read, admins can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Logistics assignments - logistics users and admins
    match /logisticsAssignments/{assignmentId} {
      allow read, write: if request.auth != null;
    }
    
    // Volunteer data - volunteers and admins
    match /volunteerHours/{entryId} {
      allow read, write: if request.auth != null;
    }
    
    match /volunteerTasks/{taskId} {
      allow read, write: if request.auth != null;
    }
    
    match /certificateRequests/{requestId} {
      allow read, write: if request.auth != null;
    }
    
    // Warehouse data - warehouse users and admins
    match /warehouseInventory/{itemId} {
      allow read, write: if request.auth != null;
    }
    
    match /warehouseTasks/{taskId} {
      allow read, write: if request.auth != null;
    }
    
    match /warehouseWorkers/{workerId} {
      allow read, write: if request.auth != null;
    }
    
    match /warehouseLocations/{locationId} {
      allow read, write: if request.auth != null;
    }
    
    // Admin collections - admin only access
    match /admin/{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/\${database}/documents/users/\${request.auth.uid}).data.role == 'admin';
    }
    
    // Analytics - admin only
    match /analytics/{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/\${database}/documents/users/\${request.auth.uid}).data.role == 'admin';
    }
    
    // System config - admin only
    match /systemConfig/{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/\${database}/documents/users/\${request.auth.uid}).data.role == 'admin';
    }
  }
}`);
}

// Main execution
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.includes('--rules')) {
    generateFirestoreRules();
  } else {
    generateIndexConfig();
  }
}

module.exports = { indexes, generateIndexConfig, generateFirestoreRules }; 