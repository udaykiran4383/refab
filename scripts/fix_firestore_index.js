// Firestore Index Fix Script
// This script helps you create the required Firestore composite indexes

console.log('🔥 Firestore Index Fix Script');
console.log('=============================\n');

console.log('❌ You are getting Firestore index errors because your queries require composite indexes.');
console.log('Here\'s how to fix them:\n');

console.log('📋 REQUIRED INDEXES:\n');

console.log('1. warehouseWorkers Collection:');
console.log('   - warehouseId (ASCENDING)');
console.log('   - createdAt (DESCENDING)');
console.log('   - __name__ (ASCENDING)\n');

console.log('2. processingTasks Collection:');
console.log('   - warehouseId (ASCENDING)');
console.log('   - createdAt (DESCENDING)');
console.log('   - __name__ (ASCENDING)\n');

console.log('3. inventory Collection:');
console.log('   - warehouseId (ASCENDING)');
console.log('   - createdAt (DESCENDING)');
console.log('   - __name__ (ASCENDING)\n');

console.log('4. warehouseLocations Collection:');
console.log('   - warehouseId (ASCENDING)');
console.log('   - createdAt (DESCENDING)');
console.log('   - __name__ (ASCENDING)\n');

console.log('🚀 HOW TO CREATE THESE INDEXES:\n');

console.log('Option 1: Firebase Console (Recommended)');
console.log('1. Go to: https://console.firebase.google.com/project/refab-app/firestore/indexes');
console.log('2. Click "Create Index"');
console.log('3. For each collection above:');
console.log('   - Collection ID: [collection name]');
console.log('   - Fields: Add the fields in the exact order shown');
console.log('   - Order: Set to ASCENDING or DESCENDING as specified');
console.log('4. Click "Create"');
console.log('5. Wait for indexes to build (1-2 minutes)\n');

console.log('Option 2: Firebase CLI');
console.log('1. Install Firebase CLI: npm install -g firebase-tools');
console.log('2. Login: firebase login');
console.log('3. Initialize: firebase init firestore');
console.log('4. Deploy indexes: firebase deploy --only firestore:indexes\n');

console.log('📁 I\'ve created firestore.indexes.json with all the required indexes.');
console.log('You can use this file with Firebase CLI or copy the configurations manually.\n');

console.log('⚠️  IMPORTANT NOTES:');
console.log('- Indexes must be built before your queries will work');
console.log('- You can monitor build progress in Firebase Console');
console.log('- If you get more index errors, repeat this process for each one');
console.log('- The __name__ field is automatically added by Firestore for ordering\n');

console.log('🔗 Direct Links:');
console.log('- Firebase Console: https://console.firebase.google.com/project/refab-app/firestore/indexes');
console.log('- Firebase CLI Docs: https://firebase.google.com/docs/firestore/query-data/indexing');

// Generate the indexes configuration
function generateFirestoreIndexesFile() {
  const indexesConfig = {
    indexes: [
      {
        collectionGroup: "warehouseWorkers",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "warehouseWorkers",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "status", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "warehouseWorkers",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "role", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "processingTasks",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "processingTasks",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "status", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "processingTasks",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "assignedWorkerId", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "processingTasks",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "taskType", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "inventory",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "inventory",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "status", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "inventory",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "fabricCategory", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "inventory",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "qualityGrade", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "warehouseLocations",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "warehouseLocations",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "status", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      },
      {
        collectionGroup: "warehouseLocations",
        queryScope: "COLLECTION",
        fields: [
          { fieldPath: "warehouseId", order: "ASCENDING" },
          { fieldPath: "type", order: "ASCENDING" },
          { fieldPath: "createdAt", order: "DESCENDING" },
          { fieldPath: "__name__", order: "ASCENDING" }
        ]
      }
    ],
    fieldOverrides: []
  };

  return JSON.stringify(indexesConfig, null, 2);
}

console.log('\n📄 Generated firestore.indexes.json content:');
console.log('==========================================');
console.log(generateFirestoreIndexesFile());

module.exports = {
  generateFirestoreIndexesFile
}; 