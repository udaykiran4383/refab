'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs } from 'firebase/firestore'
import { db } from '../lib/firebase'

export default function TestConnection() {
  const [status, setStatus] = useState('Testing...')
  const [data, setData] = useState({})
  const [error, setError] = useState(null)

  useEffect(() => {
    const testConnection = async () => {
      try {
        setStatus('Testing Firebase connection...')
        
        // Test basic connection
        const collections = ['users', 'products', 'pickupRequests', 'orders']
        const results = {}
        
        for (const collectionName of collections) {
          try {
            console.log(`Testing collection: ${collectionName}`)
            const snapshot = await getDocs(collection(db, collectionName))
            results[collectionName] = {
              count: snapshot.docs.length,
              docs: snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))
            }
            console.log(`${collectionName}: ${snapshot.docs.length} documents`)
          } catch (err) {
            console.error(`Error testing ${collectionName}:`, err)
            results[collectionName] = { error: err.message }
          }
        }
        
        setData(results)
        setStatus('Connection successful!')
      } catch (err) {
        console.error('Connection test failed:', err)
        setError(err.message)
        setStatus('Connection failed!')
      }
    }

    testConnection()
  }, [])

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Firebase Connection Test</h1>
        
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Status: {status}</h2>
          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
              Error: {error}
            </div>
          )}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Object.entries(data).map(([collectionName, result]) => (
            <div key={collectionName} className="bg-white rounded-lg shadow p-6">
              <h3 className="text-lg font-semibold mb-3 capitalize">{collectionName}</h3>
              {result.error ? (
                <div className="text-red-600">Error: {result.error}</div>
              ) : (
                <div>
                  <p className="text-2xl font-bold text-blue-600 mb-2">{result.count}</p>
                  <p className="text-gray-600">documents</p>
                  {result.docs && result.docs.length > 0 && (
                    <div className="mt-4">
                      <h4 className="font-medium mb-2">Sample documents:</h4>
                      <div className="space-y-2 max-h-40 overflow-y-auto">
                        {result.docs.slice(0, 3).map((doc, index) => (
                          <div key={index} className="text-sm bg-gray-50 p-2 rounded">
                            <div className="font-medium">ID: {doc.id}</div>
                            <div className="text-gray-600">
                              {Object.keys(doc).filter(key => key !== 'id').slice(0, 3).map(key => (
                                <span key={key} className="mr-2">
                                  {key}: {typeof doc[key] === 'object' ? 'Object' : String(doc[key])}
                                </span>
                              ))}
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  )
} 