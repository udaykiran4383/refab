'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs } from 'firebase/firestore'
import { db } from '../../lib/firebase'

export default function SimpleDashboard() {
  const [data, setData] = useState({
    users: [],
    products: [],
    pickupRequests: [],
    orders: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const fetchData = async () => {
      try {
        console.log('🔄 Starting to fetch data...')
        setLoading(true)
        
        const collections = ['users', 'products', 'pickupRequests', 'orders']
        const results = {}
        
        for (const collectionName of collections) {
          try {
            console.log(`📥 Fetching ${collectionName}...`)
            const snapshot = await getDocs(collection(db, collectionName))
            results[collectionName] = snapshot.docs.map(doc => ({
              id: doc.id,
              ...doc.data()
            }))
            console.log(`✅ ${collectionName}: ${results[collectionName].length} documents`)
          } catch (err) {
            console.error(`❌ Error fetching ${collectionName}:`, err)
            results[collectionName] = []
          }
        }
        
        setData(results)
        console.log('🎉 All data fetched successfully:', results)
      } catch (err) {
        console.error('❌ Failed to fetch data:', err)
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading simple dashboard...</p>
          <p className="text-sm text-gray-400 mt-2">Fetching data from Firebase</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Error</h1>
          <p className="text-gray-600 mb-4">{error}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Simple Dashboard</h1>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold mb-2">Users</h3>
            <p className="text-3xl font-bold text-blue-600">{data.users.length}</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold mb-2">Products</h3>
            <p className="text-3xl font-bold text-green-600">{data.products.length}</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold mb-2">Pickup Requests</h3>
            <p className="text-3xl font-bold text-purple-600">{data.pickupRequests.length}</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-lg font-semibold mb-2">Orders</h3>
            <p className="text-3xl font-bold text-orange-600">{data.orders.length}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {Object.entries(data).map(([collectionName, documents]) => (
            <div key={collectionName} className="bg-white rounded-lg shadow">
              <div className="p-6 border-b border-gray-200">
                <h2 className="text-xl font-semibold capitalize">{collectionName}</h2>
                <p className="text-gray-600">{documents.length} documents</p>
              </div>
              <div className="p-6">
                {documents.length === 0 ? (
                  <p className="text-gray-500 italic">No {collectionName} found</p>
                ) : (
                  <div className="space-y-4 max-h-96 overflow-y-auto">
                    {documents.slice(0, 5).map((doc, index) => (
                      <div key={doc.id} className="border border-gray-200 rounded p-4">
                        <div className="font-medium mb-2">ID: {doc.id}</div>
                        <div className="text-sm text-gray-600">
                          {Object.entries(doc).filter(([key]) => key !== 'id').map(([key, value]) => (
                            <div key={key} className="mb-1">
                              <span className="font-medium">{key}:</span> {
                                typeof value === 'object' && value !== null 
                                  ? JSON.stringify(value).substring(0, 100) + '...'
                                  : String(value)
                              }
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                    {documents.length > 5 && (
                      <p className="text-gray-500 text-sm">
                        ... and {documents.length - 5} more documents
                      </p>
                    )}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
} 