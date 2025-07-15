const { execSync } = require('child_process');

console.log('🧹 [CLEANUP] Starting Firestore index cleanup...');

// List of indexes to delete (unwanted indexes)
const indexesToDelete = [
  // processingTasks indexes
  'processingTasks_warehouseId_createdAt',
  'processingTasks_warehouseId_assignedWorkerId_createdAt',
  'processingTasks_warehouseId_status_createdAt',
  'processingTasks_warehouseId_taskType_createdAt',
  
  // warehouseLocations indexes
  'warehouseLocations_warehouseId_createdAt',
  'warehouseLocations_warehouseId_status_createdAt',
  'warehouseLocations_warehouseId_type_createdAt',
];

console.log('🗑️ [CLEANUP] Indexes to delete:');
indexesToDelete.forEach(index => {
  console.log(`   - ${index}`);
});

console.log('\n⚠️ [CLEANUP] WARNING: This will delete the above indexes from Firebase Console.');
console.log('⚠️ [CLEANUP] Make sure you have backed up any important data.');
console.log('\n📋 [CLEANUP] Manual cleanup steps:');
console.log('1. Go to Firebase Console > Firestore Database > Indexes');
console.log('2. Delete the following indexes:');
indexesToDelete.forEach(index => {
  console.log(`   - ${index}`);
});
console.log('3. Also delete any duplicate inventory indexes');
console.log('\n✅ [CLEANUP] After manual cleanup, run: firebase deploy --only firestore:indexes');

console.log('\n🔗 [CLEANUP] Firebase Console URL:');
console.log('https://console.firebase.google.com/project/refab-app/firestore/indexes'); 