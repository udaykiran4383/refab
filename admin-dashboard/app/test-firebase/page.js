'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs } from 'firebase/firestore'
import { db } from '../../lib/firebase'

export default function TestFirebase() {
  const [status, setStatus] = useState('Testing...')
  const [data, setData] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    const testFirebase = async () => {
      try {
        setStatus('Testing Firebase connection...')
        
        // Test basic connection
        const testCollection = collection(db, 'users')
        setStatus('Connection established, fetching data...')
        
        // Fetch users
        const usersSnapshot = await getDocs(testCollection)
        const users = usersSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
        
        setStatus('Success!')
        setData({
          users: users,
          userCount: users.length
        })
        
      } catch (err) {
        setStatus('Error!')
        setError({
          message: err.message,
          code: err.code,
          stack: err.stack
        })
      }
    }

    testFirebase()
  }, [])

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-2xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Firebase Connection Test</h1>
        
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">Status</h2>
          <p className="text-lg">{status}</p>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-6 mb-6">
            <h2 className="text-xl font-semibold text-red-800 mb-4">Error</h2>
            <div className="space-y-2">
              <p><strong>Message:</strong> {error.message}</p>
              <p><strong>Code:</strong> {error.code}</p>
              <details className="mt-4">
                <summary className="cursor-pointer text-red-600">Stack Trace</summary>
                <pre className="mt-2 text-xs bg-red-100 p-2 rounded overflow-auto">
                  {error.stack}
                </pre>
              </details>
            </div>
          </div>
        )}

        {data && (
          <div className="bg-green-50 border border-green-200 rounded-lg p-6">
            <h2 className="text-xl font-semibold text-green-800 mb-4">Success!</h2>
            <div className="space-y-2">
              <p><strong>Users found:</strong> {data.userCount}</p>
              <details className="mt-4">
                <summary className="cursor-pointer text-green-600">User Data</summary>
                <pre className="mt-2 text-xs bg-green-100 p-2 rounded overflow-auto">
                  {JSON.stringify(data.users, null, 2)}
                </pre>
              </details>
            </div>
          </div>
        )}

        <div className="mt-8">
          <a 
            href="/" 
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Back to Dashboard
          </a>
        </div>
      </div>
    </div>
  )
} 