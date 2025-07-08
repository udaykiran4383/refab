'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, orderBy } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  TruckIcon,
  MapPinIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  UserIcon
} from '@heroicons/react/24/outline'

export default function LogisticsStatusCard() {
  const [logisticsData, setLogisticsData] = useState({
    totalVehicles: 0,
    activeVehicles: 0,
    pickupAssignments: 0,
    deliveryAssignments: 0,
    activePickupAssignments: 0,
    activeDeliveryAssignments: 0,
    completedToday: 0,
    averageDeliveryTime: 0,
    deliveries: [],
    issues: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchLogisticsData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch logistics personnel
      const users = await getDocs(collection(db, 'users'))
      const logisticsUsers = users.docs.filter(doc => {
        const userData = doc.data()
        return userData.role === 'logistics' || userData.userType === 'logistics'
      })

      // Fetch logistics assignments (new structure)
      const logisticsAssignments = await getDocs(collection(db, 'logisticsAssignments'))
      
      // Separate pickup and delivery assignments
      const pickupAssignments = logisticsAssignments.docs.filter(doc => {
        const data = doc.data()
        return data.type === 'pickup'
      })
      
      const deliveryAssignments = logisticsAssignments.docs.filter(doc => {
        const data = doc.data()
        return data.type === 'delivery'
      })

      // Get active assignments (in progress)
      const activePickupAssignments = pickupAssignments.filter(doc => {
        const data = doc.data()
        return data.status === 'inProgress'
      })
      
      const activeDeliveryAssignments = deliveryAssignments.filter(doc => {
        const data = doc.data()
        return data.status === 'inProgress'
      })

      // Get completed assignments from today
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      
      const completedPickupAssignments = pickupAssignments.filter(doc => {
        const data = doc.data()
        const completedAt = data.completedTime?.toDate?.() || data.completed_time?.toDate?.() || new Date(0)
        return data.status === 'completed' && completedAt >= today
      })
      
      const completedDeliveryAssignments = deliveryAssignments.filter(doc => {
        const data = doc.data()
        const completedAt = data.completedTime?.toDate?.() || data.completed_time?.toDate?.() || new Date(0)
        return data.status === 'completed' && completedAt >= today
      })

      // Calculate average delivery time for completed assignments
      const deliveryTimes = [...completedPickupAssignments, ...completedDeliveryAssignments].map(doc => {
        const data = doc.data()
        const createdAt = data.createdAt?.toDate?.() || data.created_at?.toDate?.() || new Date(0)
        const completedAt = data.completedTime?.toDate?.() || data.completed_time?.toDate?.() || new Date(0)
        return (completedAt - createdAt) / (1000 * 60 * 60) // hours
      }).filter(time => time > 0)

      const averageDeliveryTime = deliveryTimes.length > 0 
        ? Math.round(deliveryTimes.reduce((a, b) => a + b, 0) / deliveryTimes.length)
        : 0

      // Identify issues
      const issues = []
      const totalActiveAssignments = activePickupAssignments.length + activeDeliveryAssignments.length
      if (totalActiveAssignments > logisticsUsers.length * 5) {
        issues.push('High assignment load per logistics personnel')
      }
      if (averageDeliveryTime > 72) {
        issues.push('Slow delivery times')
      }
      if (logisticsUsers.length === 0) {
        issues.push('No logistics personnel available')
      }
      if (totalActiveAssignments > 20) {
        issues.push('Large number of active assignments')
      }

      setLogisticsData({
        totalVehicles: logisticsUsers.length,
        activeVehicles: logisticsUsers.filter(doc => {
          const userData = doc.data()
          const lastActive = userData.lastActive?.toDate?.() || userData.last_active?.toDate?.() || new Date(0)
          return (new Date() - lastActive) < 24 * 60 * 60 * 1000 // 24 hours
        }).length,
        pickupAssignments: pickupAssignments.length,
        deliveryAssignments: deliveryAssignments.length,
        activePickupAssignments: activePickupAssignments.length,
        activeDeliveryAssignments: activeDeliveryAssignments.length,
        completedToday: completedPickupAssignments.length + completedDeliveryAssignments.length,
        averageDeliveryTime,
        deliveries: [...activePickupAssignments, ...activeDeliveryAssignments].slice(0, 5).map(doc => ({
          id: doc.id,
          ...doc.data()
        })),
        issues
      })
    } catch (err) {
      console.error('Error fetching logistics data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchLogisticsData()
  }, [])

  const getDeliveryStatus = (delivery) => {
    const createdAt = delivery.createdAt?.toDate?.() || delivery.created_at?.toDate?.() || new Date(0)
    const hoursSinceCreation = (new Date() - createdAt) / (1000 * 60 * 60)
    
    if (hoursSinceCreation > 48) return 'delayed'
    if (hoursSinceCreation > 24) return 'warning'
    return 'on_time'
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'on_time':
        return 'text-green-600 bg-green-100'
      case 'warning':
        return 'text-yellow-600 bg-yellow-100'
      case 'delayed':
        return 'text-red-600 bg-red-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Logistics Status</CardTitle>
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
          <CardTitle>Logistics Status</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-red-600">
            <ExclamationTriangleIcon className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading logistics data</p>
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
          <TruckIcon className="h-5 w-5 mr-2" />
          Logistics Status
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Fleet Status */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="text-center p-3 bg-blue-50 rounded-lg">
              <TruckIcon className="h-6 w-6 text-blue-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{logisticsData.totalVehicles}</p>
              <p className="text-xs text-gray-500">Total Vehicles</p>
            </div>
            <div className="text-center p-3 bg-green-50 rounded-lg">
              <UserIcon className="h-6 w-6 text-green-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{logisticsData.activeVehicles}</p>
              <p className="text-xs text-gray-500">Active</p>
            </div>
            <div className="text-center p-3 bg-orange-50 rounded-lg">
              <MapPinIcon className="h-6 w-6 text-orange-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{logisticsData.pickupAssignments}</p>
              <p className="text-xs text-gray-500">Pickup Assignments</p>
            </div>
            <div className="text-center p-3 bg-purple-50 rounded-lg">
              <MapPinIcon className="h-6 w-6 text-purple-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{logisticsData.deliveryAssignments}</p>
              <p className="text-xs text-gray-500">Delivery Assignments</p>
            </div>
          </div>

          {/* Active Assignments */}
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-blue-50 p-3 rounded-lg">
              <h4 className="text-sm font-medium text-blue-900 mb-2">Active Pickup Assignments</h4>
              <div className="space-y-2">
                {logisticsData.activePickupAssignments > 0 ? (
                  <p className="text-sm text-blue-700">{logisticsData.activePickupAssignments} active</p>
                ) : (
                  <p className="text-sm text-blue-500">No active pickup assignments</p>
                )}
              </div>
            </div>
            <div className="bg-purple-50 p-3 rounded-lg">
              <h4 className="text-sm font-medium text-purple-900 mb-2">Active Delivery Assignments</h4>
              <div className="space-y-2">
                {logisticsData.activeDeliveryAssignments > 0 ? (
                  <p className="text-sm text-purple-700">{logisticsData.activeDeliveryAssignments} active</p>
                ) : (
                  <p className="text-sm text-purple-500">No active delivery assignments</p>
                )}
              </div>
            </div>
          </div>

          {/* Completed Assignments */}
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-emerald-50 p-3 rounded-lg">
              <h4 className="text-sm font-medium text-emerald-900 mb-2">Completed Today</h4>
              <div className="space-y-2">
                <p className="text-sm text-emerald-700">{logisticsData.completedToday} completed today</p>
              </div>
            </div>
            <div className="bg-gray-50 p-3 rounded-lg">
              <h4 className="text-sm font-medium text-gray-900 mb-2">Avg. Delivery Time</h4>
              <div className="space-y-2">
                <p className="text-sm text-gray-700">Average delivery time: {logisticsData.averageDeliveryTime}h</p>
              </div>
            </div>
          </div>

          {/* Active Assignments */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3">Active Assignments</h4>
            <div className="space-y-2">
              {logisticsData.deliveries.map((assignment) => {
                const status = getDeliveryStatus(assignment)
                const isPickup = assignment.type === 'pickup'
                return (
                  <div key={assignment.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                    <div className="flex items-center space-x-2">
                      {isPickup ? (
                        <TruckIcon className="h-4 w-4 text-blue-500" />
                      ) : (
                        <MapPinIcon className="h-4 w-4 text-green-500" />
                      )}
                      <div className="flex flex-col">
                        <span className="text-sm text-gray-700">
                          {isPickup 
                            ? (assignment.tailorName || assignment.tailor_name || 'Unknown Tailor')
                            : (assignment.customerName || assignment.customer_name || 'Unknown Customer')
                          }
                        </span>
                        <span className="text-xs text-gray-500">
                          {isPickup ? 'Pickup Assignment' : 'Delivery Assignment'}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        isPickup ? 'text-blue-600 bg-blue-100' : 'text-green-600 bg-green-100'
                      }`}>
                        {isPickup ? 'Pickup' : 'Delivery'}
                      </span>
                      <span className="text-xs text-gray-500">
                        #{assignment.id.slice(-6)}
                      </span>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Issues */}
          {logisticsData.issues.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-gray-900 mb-2">Issues</h4>
              <div className="space-y-2">
                {logisticsData.issues.map((issue, index) => (
                  <div key={index} className="flex items-center space-x-2 p-2 bg-red-50 rounded">
                    <ExclamationTriangleIcon className="h-4 w-4 text-red-500" />
                    <span className="text-sm text-red-700">{issue}</span>
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