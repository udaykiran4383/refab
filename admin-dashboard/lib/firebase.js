import { initializeApp, getApps } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'
import { getAuth } from 'firebase/auth'

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY || "AIzaSyCFy8Q8SWWiGQ4lh1yON0dxn0jVy5Lq8nk",
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || "refab-app.firebaseapp.com",
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || "refab-app",
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || "refab-app.firebasestorage.app",
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || "924684180668",
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID || "1:924684180668:web:4aea87a38556d3e0f144b9",
  measurementId: "G-6C6E0JD1EP"
}

let app
let db
let auth

try {
  if (!getApps().length) {
    app = initializeApp(firebaseConfig)
  } else {
    app = getApps()[0]
  }

  db = getFirestore(app)
  auth = getAuth(app)

  console.log('✅ Firebase initialized successfully')
  console.log('🌐 Using production Firebase project:', firebaseConfig.projectId)
} catch (error) {
  console.error('Firebase initialization error:', error)
  throw new Error('Failed to initialize Firebase')
}

export { db, auth }
export default app 