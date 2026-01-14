const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('../admin-dashboard/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'refab-app'
});

const db = admin.firestore();
const auth = admin.auth();

async function disableApp() {
  console.log('🚫 Starting app disable process...');
  
  try {
    // 1. Disable all Firebase Auth users
    console.log('🔐 Disabling all Firebase Auth users...');
    const listUsersResult = await auth.listUsers();
    
    for (const userRecord of listUsersResult.users) {
      try {
        await auth.updateUser(userRecord.uid, {
          disabled: true
        });
        console.log(`✅ Disabled user: ${userRecord.email}`);
      } catch (error) {
        console.log(`⚠️ Failed to disable user ${userRecord.email}: ${error.message}`);
      }
    }
    
    // 2. Update Firestore security rules to deny all access
    console.log('🔒 Updating Firestore security rules...');
    const firestoreRules = `
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // DENY ALL ACCESS - APP DISABLED
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
`;
    
    // Note: You'll need to manually update this in Firebase Console
    console.log('📋 Copy these rules to Firebase Console → Firestore → Rules:');
    console.log(firestoreRules);
    
    // 3. Disable Firebase Authentication
    console.log('🚫 Disabling Firebase Authentication...');
    // Note: This needs to be done manually in Firebase Console
    console.log('📋 Go to Firebase Console → Authentication → Settings → General → Disable sign-in methods');
    
    // 4. Add a system config flag
    console.log('⚙️ Adding system disable flag...');
    try {
      await db.collection('systemConfig').doc('appStatus').set({
        appDisabled: true,
        disabledAt: admin.firestore.FieldValue.serverTimestamp(),
        disabledReason: 'Payment not received',
        disabledBy: 'developer'
      });
      console.log('✅ System disable flag added');
    } catch (error) {
      console.log(`⚠️ Failed to add system flag: ${error.message}`);
    }
    
    // 5. Clear all user sessions
    console.log('🧹 Clearing all user sessions...');
    const batch = db.batch();
    
    // Delete all user documents
    const usersSnapshot = await db.collection('users').get();
    usersSnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    // Delete all pickup requests
    const pickupSnapshot = await db.collection('pickupRequests').get();
    pickupSnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    // Delete all products
    const productsSnapshot = await db.collection('products').get();
    productsSnapshot.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log('✅ All user data cleared');
    
    console.log('\n🎯 APP DISABLE COMPLETE!');
    console.log('The client\'s APK will now be unable to:');
    console.log('- Sign in to the app');
    console.log('- Access any data');
    console.log('- Perform any operations');
    console.log('\n📋 Manual steps required:');
    console.log('1. Go to Firebase Console → Firestore → Rules');
    console.log('2. Replace rules with the DENY ALL version above');
    console.log('3. Go to Firebase Console → Authentication → Settings');
    console.log('4. Disable all sign-in methods');
    
  } catch (error) {
    console.error('❌ Error disabling app:', error);
  }
}

// Run the disable function
disableApp().then(() => {
  console.log('✅ App disable script completed');
  process.exit(0);
}).catch((error) => {
  console.error('❌ Script failed:', error);
  process.exit(1);
}); 