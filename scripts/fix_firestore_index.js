#!/usr/bin/env node

/**
 * Quick Firestore Index Fix Script
 * 
 * When you get a Firestore index error, this script helps you create the required index.
 * Usage: node scripts/fix_firestore_index.js "your_error_link_here"
 */

const readline = require('readline');

function extractIndexInfo(errorLink) {
  // Extract collection and fields from the error link
  const url = new URL(errorLink);
  const queryParams = url.searchParams;
  
  const collection = queryParams.get('collection_id');
  const fields = queryParams.get('fields');
  
  if (!collection || !fields) {
    console.log('❌ Could not extract index information from the provided link.');
    console.log('Please make sure you copied the complete error link from Firebase.');
    return null;
  }
  
  // Parse the fields parameter
  const fieldList = fields.split(',').map(field => {
    const [fieldPath, order] = field.split(':');
    return { fieldPath, order: order === 'asc' ? 'ASCENDING' : 'DESCENDING' };
  });
  
  return { collection, fields: fieldList };
}

function displayIndexInstructions(indexInfo) {
  console.log('🔥 Firestore Index Fix Instructions\n');
  console.log(`📋 Required Index for Collection: ${indexInfo.collection}\n`);
  console.log('Fields to add:');
  indexInfo.fields.forEach((field, i) => {
    console.log(`  ${i + 1}. ${field.fieldPath} (${field.order})`);
  });
  console.log('');
  
  console.log('🚀 Steps to Create the Index:\n');
  console.log('1. Go to Firebase Console → Firestore Database → Indexes');
  console.log('2. Click "Create Index"');
  console.log('3. Configure the index:');
  console.log(`   - Collection ID: ${indexInfo.collection}`);
  console.log('   - Fields: Add each field in the exact order shown above');
  console.log('   - Order: Set to ASCENDING or DESCENDING as specified');
  console.log('4. Click "Create"');
  console.log('5. Wait for the index to build (usually 1-2 minutes)');
  console.log('6. Once status shows "Enabled", your app will work!');
  console.log('');
  
  console.log('⚠️  Important:');
  console.log('- The index must be built before your query will work');
  console.log('- You can monitor the build progress in the Firebase Console');
  console.log('- If you get more index errors, repeat this process for each one');
  console.log('');
  
  console.log('🔗 Firebase Console:');
  console.log('https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/indexes');
}

function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  console.log('🔥 Firestore Index Error Fixer\n');
  console.log('This script helps you create the required Firestore index when you get an error.\n');
  
  rl.question('📋 Paste the error link from Firebase here: ', (errorLink) => {
    rl.close();
    
    if (!errorLink || errorLink.trim() === '') {
      console.log('❌ No error link provided. Please run the script again with a valid link.');
      return;
    }
    
    const indexInfo = extractIndexInfo(errorLink.trim());
    if (indexInfo) {
      displayIndexInstructions(indexInfo);
    }
  });
}

// Run the script
if (require.main === module) {
  main();
}

module.exports = { extractIndexInfo, displayIndexInstructions }; 