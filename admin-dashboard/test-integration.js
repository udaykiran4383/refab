#!/usr/bin/env node

/**
 * Integration Test Script for Refab Admin Dashboard
 * Tests the entire application end-to-end with real Firebase connection
 */

const { initializeApp } = require('firebase/app')
const { getFirestore, collection, getDocs, addDoc, deleteDoc, doc } = require('firebase/firestore')

// Firebase configuration (same as in lib/firebase.js)
const firebaseConfig = {
  apiKey: "AIzaSyCFy8Q8SWWiGQ4lh1yON0dxn0jVy5Lq8nk",
  authDomain: "refab-app.firebaseapp.com",
  projectId: "refab-app",
  storageBucket: "refab-app.firebasestorage.app",
  messagingSenderId: "924684180668",
  appId: "1:924684180668:web:4aea87a38556d3e0f144b9",
  measurementId: "G-6C6E0JD1EP"
}

// Initialize Firebase
const app = initializeApp(firebaseConfig)
const db = getFirestore(app)

// Test data
const testData = {
  users: [
    {
      name: 'Test User 1',
      email: 'test1@example.com',
      role: 'customer',
      phone: '+1234567890',
      is_active: true,
      created_at: new Date()
    },
    {
      name: 'Test User 2',
      email: 'test2@example.com',
      role: 'tailor',
      phone: '+1234567891',
      is_active: true,
      created_at: new Date()
    }
  ],
  pickupRequests: [
    {
      customerName: 'Test Customer',
      customer_phone: '+1234567890',
      pickup_address: '123 Test St, Test City',
      items: ['Shirt', 'Pants'],
      status: 'pending',
      created_at: new Date()
    },
    {
      customerName: 'Test Customer 2',
      customer_phone: '+1234567891',
      pickup_address: '456 Test Ave, Test City',
      items: ['Dress'],
      status: 'in_progress',
      created_at: new Date()
    }
  ],
  products: [
    {
      name: 'Test Product 1',
      description: 'A test product',
      price: 29.99,
      category: 'clothing',
      is_active: true,
      created_at: new Date()
    }
  ],
  orders: [
    {
      customer_id: 'test-customer-1',
      items: ['Test Product 1'],
      total: 29.99,
      status: 'pending',
      created_at: new Date()
    }
  ]
}

// Test results
const testResults = {
  passed: 0,
  failed: 0,
  errors: []
}

// Utility functions
const log = (message, type = 'info') => {
  const timestamp = new Date().toISOString()
  const colors = {
    info: '\x1b[36m',    // Cyan
    success: '\x1b[32m', // Green
    error: '\x1b[31m',   // Red
    warning: '\x1b[33m', // Yellow
    reset: '\x1b[0m'     // Reset
  }
  
  console.log(`${colors[type]}[${timestamp}] ${message}${colors.reset}`)
}

const assert = (condition, message) => {
  if (condition) {
    testResults.passed++
    log(`✅ ${message}`, 'success')
  } else {
    testResults.failed++
    testResults.errors.push(message)
    log(`❌ ${message}`, 'error')
  }
}

const testCollection = async (collectionName, testData, testFunction) => {
  log(`\n🧪 Testing ${collectionName} collection...`, 'info')
  
  try {
    const collectionRef = collection(db, collectionName)
    
    // Test reading existing data
    const existingDocs = await getDocs(collectionRef)
    log(`📊 Found ${existingDocs.docs.length} existing documents in ${collectionName}`)
    
    // Run custom test function
    if (testFunction) {
      await testFunction(collectionRef, existingDocs)
    }
    
    return true
  } catch (error) {
    log(`❌ Error testing ${collectionName}: ${error.message}`, 'error')
    testResults.errors.push(`${collectionName}: ${error.message}`)
    return false
  }
}

// Test functions for each collection
const testUsersCollection = async (collectionRef, existingDocs) => {
  // Test adding a user
  const testUser = testData.users[0]
  const userDoc = await addDoc(collectionRef, testUser)
  assert(userDoc.id, 'User document created successfully')
  
  // Test reading the user
  const userDocs = await getDocs(collectionRef)
  const createdUser = userDocs.docs.find(doc => doc.id === userDoc.id)
  assert(createdUser, 'Created user can be retrieved')
  assert(createdUser.data().name === testUser.name, 'User name matches')
  
  // Clean up
  await deleteDoc(doc(db, 'users', userDoc.id))
  log('🧹 Cleaned up test user', 'warning')
}

const testPickupRequestsCollection = async (collectionRef, existingDocs) => {
  // Test adding a pickup request
  const testPickup = testData.pickupRequests[0]
  const pickupDoc = await addDoc(collectionRef, testPickup)
  assert(pickupDoc.id, 'Pickup request document created successfully')
  
  // Test reading the pickup request
  const pickupDocs = await getDocs(collectionRef)
  const createdPickup = pickupDocs.docs.find(doc => doc.id === pickupDoc.id)
  assert(createdPickup, 'Created pickup request can be retrieved')
  assert(createdPickup.data().customerName === testPickup.customerName, 'Customer name matches')
  
  // Clean up
  await deleteDoc(doc(db, 'pickupRequests', pickupDoc.id))
  log('🧹 Cleaned up test pickup request', 'warning')
}

const testProductsCollection = async (collectionRef, existingDocs) => {
  // Test adding a product
  const testProduct = testData.products[0]
  const productDoc = await addDoc(collectionRef, testProduct)
  assert(productDoc.id, 'Product document created successfully')
  
  // Test reading the product
  const productDocs = await getDocs(collectionRef)
  const createdProduct = productDocs.docs.find(doc => doc.id === productDoc.id)
  assert(createdProduct, 'Created product can be retrieved')
  assert(createdProduct.data().name === testProduct.name, 'Product name matches')
  
  // Clean up
  await deleteDoc(doc(db, 'products', productDoc.id))
  log('🧹 Cleaned up test product', 'warning')
}

const testOrdersCollection = async (collectionRef, existingDocs) => {
  // Test adding an order
  const testOrder = testData.orders[0]
  const orderDoc = await addDoc(collectionRef, testOrder)
  assert(orderDoc.id, 'Order document created successfully')
  
  // Test reading the order
  const orderDocs = await getDocs(collectionRef)
  const createdOrder = orderDocs.docs.find(doc => doc.id === orderDoc.id)
  assert(createdOrder, 'Created order can be retrieved')
  assert(createdOrder.data().total === testOrder.total, 'Order total matches')
  
  // Clean up
  await deleteDoc(doc(db, 'orders', orderDoc.id))
  log('🧹 Cleaned up test order', 'warning')
}

// Performance test
const testPerformance = async () => {
  log('\n⚡ Testing performance...', 'info')
  
  const startTime = Date.now()
  
  // Test multiple concurrent reads
  const promises = [
    getDocs(collection(db, 'users')),
    getDocs(collection(db, 'pickupRequests')),
    getDocs(collection(db, 'products')),
    getDocs(collection(db, 'orders'))
  ]
  
  await Promise.all(promises)
  
  const endTime = Date.now()
  const duration = endTime - startTime
  
  assert(duration < 5000, `All collections fetched in ${duration}ms (under 5 seconds)`)
  log(`⏱️  Performance test completed in ${duration}ms`, 'success')
}

// Error handling test
const testErrorHandling = async () => {
  log('\n🛡️  Testing error handling...', 'info')
  
  try {
    // Try to access a non-existent collection
    const nonExistentCollection = collection(db, 'nonExistentCollection')
    await getDocs(nonExistentCollection)
    assert(false, 'Should have thrown an error for non-existent collection')
  } catch (error) {
    assert(true, 'Error handling works correctly')
    log(`✅ Error caught: ${error.message}`, 'success')
  }
}

// Main test runner
const runTests = async () => {
  log('🚀 Starting Refab Admin Dashboard Integration Tests', 'info')
  log('=' * 60, 'info')
  
  try {
    // Test Firebase connection
    log('\n🔌 Testing Firebase connection...', 'info')
    const testCollection = collection(db, 'users')
    await getDocs(testCollection)
    assert(true, 'Firebase connection successful')
    
    // Test each collection
    await testCollection('users', testData.users, testUsersCollection)
    await testCollection('pickupRequests', testData.pickupRequests, testPickupRequestsCollection)
    await testCollection('products', testData.products, testProductsCollection)
    await testCollection('orders', testData.orders, testOrdersCollection)
    
    // Performance test
    await testPerformance()
    
    // Error handling test
    await testErrorHandling()
    
  } catch (error) {
    log(`❌ Test suite failed: ${error.message}`, 'error')
    testResults.errors.push(`Test suite: ${error.message}`)
  }
  
  // Print results
  log('\n' + '=' * 60, 'info')
  log('📊 Test Results Summary', 'info')
  log('=' * 60, 'info')
  
  log(`✅ Passed: ${testResults.passed}`, 'success')
  log(`❌ Failed: ${testResults.failed}`, testResults.failed > 0 ? 'error' : 'success')
  log(`📈 Success Rate: ${((testResults.passed / (testResults.passed + testResults.failed)) * 100).toFixed(1)}%`, 'info')
  
  if (testResults.errors.length > 0) {
    log('\n❌ Errors:', 'error')
    testResults.errors.forEach((error, index) => {
      log(`${index + 1}. ${error}`, 'error')
    })
  }
  
  log('\n🎯 Integration Test Status:', testResults.failed === 0 ? 'success' : 'error')
  if (testResults.failed === 0) {
    log('🎉 ALL TESTS PASSED! Your admin dashboard is ready for production.', 'success')
  } else {
    log('⚠️  Some tests failed. Please check the errors above.', 'warning')
  }
  
  log('\n📋 Next Steps:', 'info')
  log('1. Start the development server: npm run dev', 'info')
  log('2. Open http://localhost:3000 in your browser', 'info')
  log('3. Verify the dashboard displays correctly', 'info')
  log('4. Test all interactive features', 'info')
  log('5. Deploy to production when ready', 'info')
  
  process.exit(testResults.failed === 0 ? 0 : 1)
}

// Run the tests
runTests().catch(error => {
  log(`❌ Test runner failed: ${error.message}`, 'error')
  process.exit(1)
}) 