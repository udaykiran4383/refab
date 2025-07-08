import { renderHook, act, waitFor } from '@testing-library/react'
import { 
  useFirebaseCollection, 
  useDashboardStats, 
  useRealtimeDashboard,
  useUsers,
  usePickupRequests,
  useProducts,
  useOrders
} from '../../lib/hooks/useFirebase'
import { 
  collection, 
  getDocs, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  onSnapshot,
  writeBatch,
  serverTimestamp,
  query,
  where,
  orderBy,
  limit
} from 'firebase/firestore'

// Mock Firebase
jest.mock('firebase/firestore', () => ({
  collection: jest.fn(),
  getDocs: jest.fn(),
  addDoc: jest.fn(),
  updateDoc: jest.fn(),
  deleteDoc: jest.fn(),
  onSnapshot: jest.fn(),
  writeBatch: jest.fn(),
  serverTimestamp: jest.fn(() => 'mock-timestamp'),
  query: jest.fn(),
  where: jest.fn(),
  orderBy: jest.fn(),
  limit: jest.fn(),
  doc: jest.fn(() => ({})) // <-- add doc mock
}))
jest.mock('react-hot-toast', () => ({
  success: jest.fn(),
  error: jest.fn()
}))

// Mock the Firebase db instance
jest.mock('../../lib/firebase', () => ({
  db: {}
}))

describe('useFirebaseCollection', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    // Reset all firestore mocks
    const firestore = require('firebase/firestore')
    firestore.collection.mockReset()
    firestore.getDocs.mockReset()
    firestore.addDoc.mockReset()
    firestore.updateDoc.mockReset()
    firestore.deleteDoc.mockReset()
    firestore.onSnapshot.mockReset()
    firestore.writeBatch.mockReset()
    firestore.serverTimestamp.mockReset()
    firestore.query.mockReset()
    firestore.where.mockReset()
    firestore.orderBy.mockReset()
    firestore.limit.mockReset()
    firestore.doc.mockReset()

    // Default mock return values
    firestore.collection.mockReturnValue({})
    firestore.getDocs.mockResolvedValue({ docs: [] })
    firestore.addDoc.mockResolvedValue({ id: 'mock-id' })
    firestore.updateDoc.mockResolvedValue()
    firestore.deleteDoc.mockResolvedValue()
    firestore.onSnapshot.mockReturnValue(() => {})
    firestore.writeBatch.mockReturnValue({
      update: jest.fn(),
      commit: jest.fn()
    })
    firestore.serverTimestamp.mockReturnValue('mock-timestamp')
    firestore.query.mockReturnValue({})
    firestore.where.mockReturnValue({})
    firestore.orderBy.mockReturnValue({})
    firestore.limit.mockReturnValue({})
    firestore.doc.mockReturnValue({})
  })

  it('should initialize with default values', () => {
    const { result } = renderHook(() => useFirebaseCollection('users'))
    expect(result.current.data).toEqual([])
    expect(result.current.loading).toBe(true)
    expect(result.current.error).toBe(null)
  })

  it('should fetch data successfully', async () => {
    const mockDocs = [
      { id: '1', data: () => ({ name: 'John', role: 'admin' }) },
      { id: '2', data: () => ({ name: 'Jane', role: 'user' }) }
    ]
    
    const firestore = require('firebase/firestore')
    firestore.getDocs.mockResolvedValue({ docs: mockDocs })

    let result
    await act(async () => {
      result = renderHook(() => useFirebaseCollection('users')).result
      // Wait for data to be loaded
      await waitFor(() => expect(result.current.data.length).toBe(2), { timeout: 2000 })
    })
    expect(result.current.data[0]).toEqual({ id: '1', name: 'John', role: 'admin' })
    expect(result.current.loading).toBe(false)
  })

  it('should handle fetch errors with retry logic', async () => {
    const firestore = require('firebase/firestore')
    firestore.getDocs.mockRejectedValue(new Error('Permission denied'))

    let result
    await act(async () => {
      result = renderHook(() => useFirebaseCollection('users')).result
      // Wait for error to be set
      await waitFor(() => expect(result.current.error).toBeTruthy(), { timeout: 2000 })
    })
    expect(result.current.error).toContain('Failed to fetch users')
    expect(result.current.loading).toBe(false)
  })

  it('should handle permission denied errors', async () => {
    const error = new Error('Permission denied')
    error.code = 'permission-denied'
    const firestore = require('firebase/firestore')
    firestore.getDocs.mockRejectedValueOnce(error)
    firestore.collection.mockReturnValue({})

    let result
    await act(async () => {
      result = renderHook(() => useFirebaseCollection('users')).result
      await result.current.fetchData()
    })
    await waitFor(() => {
      expect(result.current.error).toContain('Access denied')
    })
  })

  it('should add document successfully', async () => {
    const firestore = require('firebase/firestore')
    firestore.addDoc.mockResolvedValue({ id: 'new-id' })

    let result
    await act(async () => {
      result = renderHook(() => useFirebaseCollection('users')).result
    })
    
    const newUser = { name: 'John', role: 'admin' }
    const addedDoc = await result.current.addDocument(newUser)
    expect(addedDoc).toEqual({ id: 'new-id' })
    expect(firestore.addDoc).toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ name: 'John', role: 'admin' })
    )
  })

  it('should handle add document errors', async () => {
    const firestore = require('firebase/firestore')
    firestore.addDoc.mockRejectedValue(new Error('Invalid data provided.'))

    let result
    await act(async () => {
      result = renderHook(() => useFirebaseCollection('users')).result
    })
    const newUser = { name: 'John' }
    await expect(result.current.addDocument(newUser)).rejects.toThrow('Failed to add user')
  })

  it('should update document successfully', async () => {
    const firestore = require('firebase/firestore')
    firestore.updateDoc.mockResolvedValueOnce()
    firestore.collection.mockReturnValue({})

    const { result } = renderHook(() => useFirebaseCollection('users'))
    await act(async () => {
      await result.current.updateDocument('user-id', { name: 'Updated Name' })
    })
    expect(firestore.updateDoc).toHaveBeenCalled()
  })

  it('should delete document successfully', async () => {
    const firestore = require('firebase/firestore')
    firestore.deleteDoc.mockResolvedValueOnce()
    firestore.collection.mockReturnValue({})

    const { result } = renderHook(() => useFirebaseCollection('users'))
    await act(async () => {
      await result.current.deleteDocument('user-id')
    })
    expect(firestore.deleteDoc).toHaveBeenCalled()
  })

  it('should perform batch updates', async () => {
    const mockBatch = {
      update: jest.fn(),
      commit: jest.fn().mockResolvedValue()
    }
    const firestore = require('firebase/firestore')
    firestore.writeBatch.mockReturnValueOnce(mockBatch)
    firestore.collection.mockReturnValue({})

    const { result } = renderHook(() => useFirebaseCollection('users'))
    const updates = [
      { id: '1', data: { name: 'Updated 1' } },
      { id: '2', data: { name: 'Updated 2' } }
    ]
    await act(async () => {
      await result.current.batchUpdate(updates)
    })
    expect(firestore.writeBatch).toHaveBeenCalled()
    expect(mockBatch.update).toHaveBeenCalledTimes(2)
    expect(mockBatch.commit).toHaveBeenCalled()
  })

  it('should apply query constraints', async () => {
    const mockDocs = [
      { id: '1', data: () => ({ name: 'John', role: 'admin' }) }
    ]
    
    const firestore = require('firebase/firestore')
    firestore.getDocs.mockResolvedValue({ docs: mockDocs })

    let result
    await act(async () => {
      result = renderHook(() => 
        useFirebaseCollection('users', [
          ['role', '==', 'admin']
        ])
      ).result
      // Wait for data to be loaded
      await waitFor(() => expect(result.current.data.length).toBe(1), { timeout: 2000 })
    })
    expect(result.current.data[0]).toEqual({ id: '1', name: 'John', role: 'admin' })
    expect(result.current.loading).toBe(false)
  })

  it('should set up real-time listener', async () => {
    const mockUnsubscribe = jest.fn()
    const mockDocs = [
      { id: '1', data: () => ({ name: 'John' }) }
    ]
    
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementation((query, callback) => {
      callback({ docs: mockDocs })
      return mockUnsubscribe
    })

    let result, unmount
    await act(async () => {
      const hook = renderHook(() => useFirebaseCollection('users'))
      result = hook.result
      unmount = hook.unmount
      // Wait for data to be loaded
      await waitFor(() => expect(result.current.data[0]).toEqual({ id: '1', name: 'John' }), { timeout: 2000 })
    })
    unmount()
    expect(mockUnsubscribe).toHaveBeenCalled()
  })

  it('should handle real-time listener errors', async () => {
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementation((query, callback, onError) => {
      onError(new Error('Listener error'))
      return jest.fn()
    })

    let result
    await act(async () => {
      result = renderHook(() => useFirebaseCollection('users')).result
      // Wait for error to be set
      await waitFor(() => expect(result.current.error).toContain('Listener error'), { timeout: 2000 })
    })
    expect(result.current.loading).toBe(false)
  })

  it('should clean up listeners on unmount', () => {
    const mockUnsubscribe = jest.fn()
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockReturnValue(mockUnsubscribe)

    const { unmount } = renderHook(() => useFirebaseCollection('users'))
    unmount()
    expect(mockUnsubscribe).toHaveBeenCalled()
  })
})

describe('Specific Collection Hooks', () => {
  it('should use correct collection names', () => {
    const { result: usersResult } = renderHook(() => useUsers())
    const { result: pickupsResult } = renderHook(() => usePickupRequests())
    const { result: productsResult } = renderHook(() => useProducts())
    const { result: ordersResult } = renderHook(() => useOrders())

    expect(usersResult.current).toBeDefined()
    expect(pickupsResult.current).toBeDefined()
    expect(productsResult.current).toBeDefined()
    expect(ordersResult.current).toBeDefined()
  })
})

describe('useDashboardStats', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    const firestore = require('firebase/firestore')
    firestore.collection.mockReset()
    firestore.getDocs.mockReset()
    firestore.onSnapshot.mockReset()
    firestore.doc.mockReset()

    // Default mock return values
    firestore.collection.mockReturnValue({})
    firestore.getDocs.mockResolvedValue({ docs: [] })
    firestore.onSnapshot.mockReturnValue(() => {})
    firestore.doc.mockReturnValue({})
  })

  it('should initialize with default values', () => {
    const { result } = renderHook(() => useDashboardStats())
    
    expect(result.current.stats).toEqual({
      totalUsers: 0,
      totalPickups: 0,
      totalProducts: 0,
      totalOrders: 0,
      recentPickups: [],
      pendingPickups: 0,
      completedPickups: 0
    })
    expect(result.current.loading).toBe(true)
    expect(result.current.error).toBe(null)
  })

  it('should fetch stats successfully', async () => {
    const mockUsers = [
      { id: '1', data: () => ({ name: 'John' }) },
      { id: '2', data: () => ({ name: 'Jane' }) }
    ]
    const mockPickups = [
      { id: '1', data: () => ({ status: 'pending' }) },
      { id: '2', data: () => ({ status: 'pending' }) },
      { id: '3', data: () => ({ status: 'completed' }) }
    ]
    const mockProducts = [
      { id: '1', data: () => ({ name: 'Product 1' }) }
    ]
    const mockOrders = [
      { id: '1', data: () => ({ status: 'completed' }) }
    ]
    
    const firestore = require('firebase/firestore')
    firestore.getDocs
      .mockResolvedValueOnce({ docs: mockUsers })
      .mockResolvedValueOnce({ docs: mockPickups })
      .mockResolvedValueOnce({ docs: mockProducts })
      .mockResolvedValueOnce({ docs: mockOrders })

    const { result } = renderHook(() => useDashboardStats())
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false)
      expect(result.current.stats.totalUsers).toBe(2)
      expect(result.current.stats.totalPickups).toBe(3)
      expect(result.current.stats.pendingPickups).toBe(2)
      expect(result.current.stats.completedPickups).toBe(1)
    })
  })

  it('should handle stats fetch errors', async () => {
    const firestore = require('firebase/firestore')
    firestore.getDocs.mockRejectedValue(new Error('Failed to fetch dashboard statistics'))

    const { result } = renderHook(() => useDashboardStats())
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false)
      expect(result.current.error).toContain('Failed to fetch dashboard statistics')
    })
  })

  it('should auto-refresh stats', async () => {
    jest.useFakeTimers()
    
    const mockUsers = { docs: [{ id: '1' }] }
    const mockPickups = { docs: [] }
    const mockProducts = { docs: [] }
    const mockOrders = { docs: [] }
    const mockRecentPickups = { docs: [] }

    const firestore = require('firebase/firestore')
    firestore.getDocs
      .mockResolvedValueOnce(mockUsers)
      .mockResolvedValueOnce(mockPickups)
      .mockResolvedValueOnce(mockProducts)
      .mockResolvedValueOnce(mockOrders)
      .mockResolvedValueOnce(mockRecentPickups)

    firestore.collection.mockReturnValue({})
    firestore.query.mockReturnValue({})
    firestore.orderBy.mockReturnValue({})
    firestore.limit.mockReturnValue({})

    const { result } = renderHook(() => useDashboardStats())

    // Fast-forward 30 seconds
    act(() => {
      jest.advanceTimersByTime(30000)
    })

    await waitFor(() => {
      expect(firestore.getDocs).toHaveBeenCalledTimes(10) // Initial + 30s refresh
    })

    jest.useRealTimers()
  })
})

describe('useRealtimeDashboard', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    const firestore = require('firebase/firestore')
    firestore.collection.mockReset()
    firestore.onSnapshot.mockReset()
    firestore.doc.mockReset()

    // Default mock return values
    firestore.collection.mockReturnValue({})
    firestore.onSnapshot.mockReturnValue(() => {})
    firestore.doc.mockReturnValue({})
  })

  it('should initialize with default values', () => {
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementation((query, callback) => {
      callback({ docs: [] })
      return jest.fn()
    })

    const { result } = renderHook(() => useRealtimeDashboard())
    expect(result.current.loading).toBe(true)
    expect(result.current.error).toBe(null)
  })

  it('should set up real-time listeners for all collections', () => {
    const mockUnsubscribe = jest.fn()
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementationOnce((col, onNext, onError) => {
      onNext({ docs: [{ id: '1', data: () => ({ name: 'John' }) }] })
      return mockUnsubscribe
    })
    firestore.collection.mockReturnValue({})

    renderHook(() => useRealtimeDashboard())

    expect(firestore.onSnapshot).toHaveBeenCalledTimes(4) // users, pickups, products, orders
  })

  it('should update stats when real-time data changes', () => {
    const mockUnsubscribe = jest.fn()
    let onNextCallback
    
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementationOnce((col, onNext, onError) => {
      onNextCallback = onNext
      return mockUnsubscribe
    })
    firestore.collection.mockReturnValue({})

    const { result } = renderHook(() => useRealtimeDashboard())

    // Simulate data update
    act(() => {
      onNextCallback({
        docs: [
          { id: '1', data: () => ({ name: 'John' }) },
          { id: '2', data: () => ({ name: 'Jane' }) }
        ]
      })
    })

    expect(result.current.stats.totalUsers).toBe(2)
    expect(result.current.loading).toBe(false)
  })

  it('should handle real-time listener errors', () => {
    const error = new Error('Real-time error')
    let onErrorCallback
    
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementationOnce((col, onNext, onError) => {
      onErrorCallback = onError
      return jest.fn()
    })
    firestore.collection.mockReturnValue({})

    const { result } = renderHook(() => useRealtimeDashboard())

    act(() => {
      onErrorCallback(error)
    })

    expect(result.current.error).toBe(error.message)
    expect(result.current.loading).toBe(false)
  })

  it('should sort recent pickups by creation date', () => {
    const mockPickups = [
      { id: '1', data: () => ({ 
        customerName: 'Old Pickup', 
        createdAt: { toDate: () => new Date('2023-01-01') }
      })},
      { id: '2', data: () => ({ 
        customerName: 'New Pickup', 
        createdAt: { toDate: () => new Date('2023-01-02') }
      })}
    ]
    
    const firestore = require('firebase/firestore')
    firestore.onSnapshot.mockImplementation((query, callback) => {
      callback({ docs: mockPickups })
      return jest.fn()
    })

    const { result } = renderHook(() => useRealtimeDashboard())
    
    expect(result.current.stats.recentPickups[0].customerName).toBe('New Pickup')
    expect(result.current.stats.recentPickups[1].customerName).toBe('Old Pickup')
  })

  it('should clean up listeners on unmount', () => {
    const mockUnsubscribe = jest.fn()
    const firestore = require('firebase/firestore')
    // Return a new mockUnsubscribe for each call
    firestore.onSnapshot.mockImplementation(() => mockUnsubscribe)
    firestore.collection.mockReturnValue({})

    const { unmount } = renderHook(() => useRealtimeDashboard())
    unmount()
    expect(mockUnsubscribe).toHaveBeenCalledTimes(4) // One for each collection
  })
}) 