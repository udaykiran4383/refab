'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, limit } from 'firebase/firestore'
import { db } from '../../lib/firebase'

export default function DebugPage() {
  const [status, setStatus] = useState('Initializing...')
  const [logs, setLogs] = useState([])

  const addLog = (message, type = 'info') => {
    const timestamp = new Date().toLocaleTimeString()
    setLogs(prev => [...prev, { message, type, timestamp }])
    console.log(`[${timestamp}] ${message}`)
  }

  useEffect(() => {
    const testFirebase = async () => {
      try {
        addLog('🚀 Starting Firebase connection test...')
        setStatus('Testing connection...')

        // Test 1: Basic connection
        addLog('📡 Testing basic Firebase connection...')
        const testQuery = query(collection(db, 'users'), limit(1))
        addLog('✅ Firebase connection established')

        // Test 2: Try to fetch data
        addLog('📥 Attempting to fetch data from collections...')
        
        const collections = ['users', 'products', 'pickupRequests', 'orders']
        
        for (const collectionName of collections) {
          try {
            addLog(`🔍 Testing collection: ${collectionName}`)
            const snapshot = await getDocs(collection(db, collectionName))
            addLog(`✅ ${collectionName}: ${snapshot.docs.length} documents found`)
            
            if (snapshot.docs.length > 0) {
              const firstDoc = snapshot.docs[0].data()
              addLog(`📄 Sample data from ${collectionName}:`, 'data')
              addLog(JSON.stringify(firstDoc, null, 2), 'data')
            }
          } catch (err) {
            addLog(`❌ Error with ${collectionName}: ${err.message}`, 'error')
          }
        }

        setStatus('Test completed successfully')
        addLog('🎉 All tests completed!')

      } catch (error) {
        addLog(`💥 Critical error: ${error.message}`, 'error')
        setStatus('Test failed')
      }
    }

    testFirebase()
  }, [])

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Firebase Debug Console</h1>
        
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Status: {status}</h2>
          <div className="bg-gray-100 rounded p-4 font-mono text-sm">
            <div className="mb-2 font-semibold">Console Logs:</div>
            <div className="space-y-1 max-h-96 overflow-y-auto">
              {logs.map((log, index) => (
                <div key={index} className={`${
                  log.type === 'error' ? 'text-red-600' : 
                  log.type === 'data' ? 'text-green-600' : 
                  'text-gray-800'
                }`}>
                  [{log.timestamp}] {log.message}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">Firebase Configuration</h2>
          <div className="bg-gray-100 rounded p-4 font-mono text-sm">
            <div>Project ID: {process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'refab-app'}</div>
            <div>API Key: {process.env.NEXT_PUBLIC_FIREBASE_API_KEY ? 'Set' : 'Using default'}</div>
            <div>Auth Domain: {process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || 'refab-app.firebaseapp.com'}</div>
          </div>
        </div>
      </div>
    </div>
  )
} 