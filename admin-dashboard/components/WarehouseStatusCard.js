'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, orderBy } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  CubeIcon,
  UserIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ArchiveBoxIcon
} from '@heroicons/react/24/outline'

export default function WarehouseStatusCard() {
  const [warehouseData, setWarehouseData] = useState({
    totalWorkers: 0,
    activeWorkers: 0,
    totalInventory: 0,
    processingCapacity: 0,
    itemsProcessedToday: 0,
    inventory: [],
    alerts: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchWarehouseData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch warehouse workers
      const users = await getDocs(collection(db, 'users'))
      const warehouseUsers = users.docs.filter(doc => {
        const userData = doc.data()
        return userData.role === 'warehouse' || userData.userType === 'warehouse'
      })

      // Fetch products/inventory
      const products = await getDocs(collection(db, 'products'))
      
      // Fetch warehouse processing requests
      const warehouseRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'in_warehouse')
      ))

      // Fetch completed warehouse processing from today
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const completedRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'completed')
      ))

      const itemsProcessedToday = completedRequests.docs.filter(doc => {
        const data = doc.data()
        const completedAt = data.completedAt?.toDate?.() || data.completed_at?.toDate?.() || new Date(0)
        return completedAt >= today
      }).length

      // Calculate processing capacity (items per worker per day)
      const processingCapacity = warehouseUsers.length * 10 // Assuming 10 items per worker per day

      // Identify alerts
      const alerts = []
      if (warehouseRequests.docs.length > processingCapacity) {
        alerts.push('Processing capacity exceeded')
      }
      if (warehouseUsers.length === 0) {
        alerts.push('No warehouse workers available')
      }
      if (products.docs.length < 50) {
        alerts.push('Low inventory levels')
      }
      if (warehouseRequests.docs.length > 30) {
        alerts.push('High processing backlog')
      }

      setWarehouseData({
        totalWorkers: warehouseUsers.length,
        activeWorkers: warehouseUsers.filter(doc => {
          const userData = doc.data()
          const lastActive = userData.lastActive?.toDate?.() || userData.last_active?.toDate?.() || new Date(0)
          return (new Date() - lastActive) < 24 * 60 * 60 * 1000 // 24 hours
        }).length,
        totalInventory: products.docs.length,
        processingCapacity,
        itemsProcessedToday,
        inventory: products.docs.slice(0, 5).map(doc => ({
          id: doc.id,
          ...doc.data()
        })),
        alerts
      })
    } catch (err) {
      console.error('Error fetching warehouse data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchWarehouseData()
  }, [])

  const getCapacityUtilization = () => {
    if (warehouseData.processingCapacity === 0) return 0
    return Math.round((warehouseData.itemsProcessedToday / warehouseData.processingCapacity) * 100)
  }

  const getInventoryStatus = (product) => {
    const quantity = product.quantity || product.stock || 0
    if (quantity === 0) return 'out_of_stock'
    if (quantity < 10) return 'low_stock'
    return 'in_stock'
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'in_stock':
        return 'text-green-600 bg-green-100'
      case 'low_stock':
        return 'text-yellow-600 bg-yellow-100'
      case 'out_of_stock':
        return 'text-red-600 bg-red-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Warehouse Status</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
            <div className="space-y-3">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="h-8 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Warehouse Status</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-red-600">
            <ExclamationTriangleIcon className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading warehouse data</p>
            <p className="text-sm text-gray-500">{error}</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center">
          <CubeIcon className="h-5 w-5 mr-2" />
          Warehouse Status
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Worker & Inventory Stats */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="text-center p-3 bg-blue-50 rounded-lg">
              <UserIcon className="h-6 w-6 text-blue-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{warehouseData.totalWorkers}</p>
              <p className="text-xs text-gray-500">Total Workers</p>
            </div>
            <div className="text-center p-3 bg-green-50 rounded-lg">
              <UserIcon className="h-6 w-6 text-green-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{warehouseData.activeWorkers}</p>
              <p className="text-xs text-gray-500">Active</p>
            </div>
            <div className="text-center p-3 bg-purple-50 rounded-lg">
              <ArchiveBoxIcon className="h-6 w-6 text-purple-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{warehouseData.totalInventory}</p>
              <p className="text-xs text-gray-500">Inventory Items</p>
            </div>
            <div className="text-center p-3 bg-emerald-50 rounded-lg">
              <CheckCircleIcon className="h-6 w-6 text-emerald-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{warehouseData.itemsProcessedToday}</p>
              <p className="text-xs text-gray-500">Processed Today</p>
            </div>
          </div>

          {/* Capacity Utilization */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm font-medium text-gray-700">Capacity Utilization</span>
              <span className="text-sm text-gray-500">
                {getCapacityUtilization()}%
              </span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-green-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${Math.min(getCapacityUtilization(), 100)}%` }}
              ></div>
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {warehouseData.itemsProcessedToday} / {warehouseData.processingCapacity} items
            </p>
          </div>

          {/* Processing Capacity */}
          <div className="p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <ClockIcon className="h-5 w-5 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Daily Processing Capacity</span>
              </div>
              <span className="text-lg font-semibold text-gray-900">{warehouseData.processingCapacity} items</span>
            </div>
          </div>

          {/* Inventory Status */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3">Inventory Status</h4>
            <div className="space-y-2">
              {warehouseData.inventory.map((product) => {
                const status = getInventoryStatus(product)
                return (
                  <div key={product.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                    <div className="flex items-center space-x-2">
                      <ArchiveBoxIcon className="h-4 w-4 text-blue-500" />
                      <span className="text-sm text-gray-700">
                        {product.name || product.title || 'Unknown Product'}
                      </span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(status)}`}>
                        {status.replace('_', ' ')}
                      </span>
                      <span className="text-xs text-gray-500">
                        Qty: {product.quantity || product.stock || 0}
                      </span>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Alerts */}
          {warehouseData.alerts.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-gray-900 mb-2">Alerts</h4>
              <div className="space-y-2">
                {warehouseData.alerts.map((alert, index) => (
                  <div key={index} className="flex items-center space-x-2 p-2 bg-red-50 rounded">
                    <ExclamationTriangleIcon className="h-4 w-4 text-red-500" />
                    <span className="text-sm text-red-700">{alert}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
} 