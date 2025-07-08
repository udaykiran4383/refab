'use client'

import { useState, useEffect, useCallback } from 'react'
import { 
  collection, 
  getDocs, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  doc, 
  query, 
  where, 
  orderBy, 
  limit,
  onSnapshot,
  serverTimestamp,
  writeBatch,
  runTransaction
} from 'firebase/firestore'
import { db } from '../firebase'
import toast from 'react-hot-toast'

// Error handling utility
const handleFirebaseError = (error, operation) => {
  console.error(`Firebase ${operation} error:`, error)
  
  let userMessage = `Failed to ${operation}`
  
  if (error.code === 'permission-denied') {
    userMessage = 'Access denied. Please check your permissions.'
  } else if (error.code === 'unavailable') {
    userMessage = 'Service temporarily unavailable. Please try again.'
  } else if (error.code === 'not-found') {
    userMessage = 'Resource not found.'
  } else if (error.code === 'already-exists') {
    userMessage = 'Resource already exists.'
  } else if (error.code === 'invalid-argument') {
    userMessage = 'Invalid data provided.'
  }
  
  toast.error(userMessage)
  return userMessage
}

// Retry utility
const retryOperation = async (operation, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation()
    } catch (error) {
      if (i === maxRetries - 1) throw error
      if (error.code === 'unavailable') {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)))
        continue
      }
      throw error
    }
  }
}

// Generic hook for CRUD operations
export function useFirebaseCollection(collectionName) {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchData = useCallback(async (constraints = []) => {
    try {
      setLoading(true)
      setError(null)
      
      let q = collection(db, collectionName)
      
      // Apply constraints
      constraints.forEach(constraint => {
        if (constraint.type === 'where') {
          q = query(q, where(constraint.field, constraint.operator, constraint.value))
        } else if (constraint.type === 'orderBy') {
          q = query(q, orderBy(constraint.field, constraint.direction || 'asc'))
        } else if (constraint.type === 'limit') {
          q = query(q, limit(constraint.value))
        }
      })

      const snapshot = await retryOperation(() => getDocs(q))
      const documents = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }))
      
      setData(documents)
    } catch (err) {
      const errorMessage = handleFirebaseError(err, `fetch ${collectionName}`)
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [collectionName])

  // Fetch data on mount
  useEffect(() => {
    fetchData()
  }, [fetchData])

  const addDocument = useCallback(async (documentData) => {
    try {
      const docRef = await retryOperation(() => 
        addDoc(collection(db, collectionName), {
          ...documentData,
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp()
        })
      )
      toast.success(`${collectionName.slice(0, -1)} added successfully`)
      return docRef
    } catch (err) {
      const errorMessage = handleFirebaseError(err, `add ${collectionName.slice(0, -1)}`)
      throw new Error(errorMessage)
    }
  }, [collectionName])

  const updateDocument = useCallback(async (id, updates) => {
    try {
      const docRef = doc(db, collectionName, id)
      await retryOperation(() => 
        updateDoc(docRef, {
          ...updates,
          updatedAt: serverTimestamp()
        })
      )
      toast.success(`${collectionName.slice(0, -1)} updated successfully`)
    } catch (err) {
      const errorMessage = handleFirebaseError(err, `update ${collectionName.slice(0, -1)}`)
      throw new Error(errorMessage)
    }
  }, [collectionName])

  const deleteDocument = useCallback(async (id) => {
    try {
      const docRef = doc(db, collectionName, id)
      await retryOperation(() => deleteDoc(docRef))
      toast.success(`${collectionName.slice(0, -1)} deleted successfully`)
    } catch (err) {
      const errorMessage = handleFirebaseError(err, `delete ${collectionName.slice(0, -1)}`)
      throw new Error(errorMessage)
    }
  }, [collectionName])

  // Batch operations
  const batchUpdate = useCallback(async (updates) => {
    try {
      const batch = writeBatch(db)
      
      updates.forEach(({ id, data }) => {
        const docRef = doc(db, collectionName, id)
        batch.update(docRef, {
          ...data,
          updatedAt: serverTimestamp()
        })
      })
      
      await retryOperation(() => batch.commit())
      toast.success(`Batch update completed successfully`)
    } catch (err) {
      const errorMessage = handleFirebaseError(err, 'perform batch update')
      throw new Error(errorMessage)
    }
  }, [collectionName])

  // Real-time listener
  const subscribeToCollection = useCallback((constraints = []) => {
    try {
      let q = collection(db, collectionName)
      
      constraints.forEach(constraint => {
        if (constraint.type === 'where') {
          q = query(q, where(constraint.field, constraint.operator, constraint.value))
        } else if (constraint.type === 'orderBy') {
          q = query(q, orderBy(constraint.field, constraint.direction || 'asc'))
        } else if (constraint.type === 'limit') {
          q = query(q, limit(constraint.value))
        }
      })

      return onSnapshot(q, (snapshot) => {
        const documents = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
        setData(documents)
        setLoading(false)
        setError(null)
      }, (err) => {
        const errorMessage = handleFirebaseError(err, `listen to ${collectionName}`)
        setError(errorMessage)
        setLoading(false)
      })
    } catch (err) {
      const errorMessage = handleFirebaseError(err, `set up listener for ${collectionName}`)
      setError(errorMessage)
      setLoading(false)
    }
  }, [collectionName])

  return {
    data,
    loading,
    error,
    fetchData,
    addDocument,
    updateDocument,
    deleteDocument,
    batchUpdate,
    subscribeToCollection
  }
}

// Specific hooks for different collections
export function useUsers() {
  const result = useFirebaseCollection('users')
  
  // Debug logging for users hook
  useEffect(() => {
    console.log('👥 [USE_USERS] Hook state updated:', {
      dataLength: result.data.length,
      loading: result.loading,
      error: result.error
    })
  }, [result.data.length, result.loading, result.error])
  
  return result
}

export function usePickupRequests() {
  return useFirebaseCollection('pickupRequests')
}

export function useProducts() {
  return useFirebaseCollection('products')
}

export function useOrders() {
  return useFirebaseCollection('orders')
}

// Hook for dashboard statistics
export function useDashboardStats() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalPickups: 0,
    totalProducts: 0,
    totalOrders: 0,
    recentPickups: [],
    pendingPickups: 0,
    completedPickups: 0
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchStats = useCallback(async () => {
    try {
      console.log('🔄 Fetching dashboard stats...')
      setLoading(true)
      setError(null)

      // Fetch all collections
      const [users, pickups, products, orders] = await Promise.all([
        getDocs(collection(db, 'users')),
        getDocs(collection(db, 'pickupRequests')),
        getDocs(collection(db, 'products')),
        getDocs(collection(db, 'orders'))
      ])

      console.log('📊 Raw data counts:', {
        users: users.docs.length,
        pickups: pickups.docs.length,
        products: products.docs.length,
        orders: orders.docs.length
      })

      // Get recent pickup requests
      const recentPickups = pickups.docs
        .map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
        .sort((a, b) => {
          const dateA = a.created_at ? new Date(a.created_at) : new Date(0)
          const dateB = b.created_at ? new Date(b.created_at) : new Date(0)
          return dateB - dateA
        })
        .slice(0, 5)

      // Calculate pickup status counts
      const pickupData = pickups.docs.map(doc => doc.data())
      const pendingPickups = pickupData.filter(p => p.status === 'pending').length
      const completedPickups = pickupData.filter(p => p.status === 'completed').length

      const newStats = {
        totalUsers: users.docs.length,
        totalPickups: pickups.docs.length,
        totalProducts: products.docs.length,
        totalOrders: orders.docs.length,
        recentPickups,
        pendingPickups,
        completedPickups
      }

      console.log('✅ Dashboard stats updated:', newStats)
      setStats(newStats)
    } catch (err) {
      console.error('❌ Error fetching dashboard stats:', err)
      const errorMessage = handleFirebaseError(err, 'fetch dashboard statistics')
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [])

  // Fetch stats on mount
  useEffect(() => {
    fetchStats()
  }, [fetchStats])

  return { stats, loading, error, fetchStats }
}

// Hook for real-time dashboard updates
export function useRealtimeDashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalPickups: 0,
    totalProducts: 0,
    totalOrders: 0,
    recentPickups: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const unsubscribeUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      setStats(prev => ({ ...prev, totalUsers: snapshot.docs.length }))
    }, (err) => {
      handleFirebaseError(err, 'listen to users')
      setError(err.message)
    })

    const unsubscribePickups = onSnapshot(collection(db, 'pickupRequests'), (snapshot) => {
      const recentPickups = snapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .sort((a, b) => b.createdAt?.toDate() - a.createdAt?.toDate())
        .slice(0, 5)
      
      setStats(prev => ({ 
        ...prev, 
        totalPickups: snapshot.docs.length,
        recentPickups 
      }))
    }, (err) => {
      handleFirebaseError(err, 'listen to pickup requests')
      setError(err.message)
    })

    const unsubscribeProducts = onSnapshot(collection(db, 'products'), (snapshot) => {
      setStats(prev => ({ ...prev, totalProducts: snapshot.docs.length }))
    }, (err) => {
      handleFirebaseError(err, 'listen to products')
      setError(err.message)
    })

    const unsubscribeOrders = onSnapshot(collection(db, 'orders'), (snapshot) => {
      setStats(prev => ({ ...prev, totalOrders: snapshot.docs.length }))
    }, (err) => {
      handleFirebaseError(err, 'listen to orders')
      setError(err.message)
    })

    setLoading(false)

    return () => {
      unsubscribeUsers()
      unsubscribePickups()
      unsubscribeProducts()
      unsubscribeOrders()
    }
  }, [])

  return { stats, loading, error }
} 