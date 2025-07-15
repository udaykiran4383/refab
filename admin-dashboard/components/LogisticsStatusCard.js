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
  UserIcon,
  WarehouseIcon,
  ScissorsIcon
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
    issues: [],
    warehouseAssignments: [],
    tailorProgress: []
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

      // Get warehouse assignment information
      const warehouseAssignments = pickupAssignments.filter(doc => {
        const data = doc.data()
        return data.assigned_warehouse_id || data.assignedWarehouseId
      }).map(doc => {
        const data = doc.data()
        const isSelfAssigned = data.logistics_id === data.assigned_by_logistics_id
        return {
          id: doc.id,
          warehouseName: data.assigned_warehouse_name || data.assignedWarehouseName || 'Unknown Warehouse',
          warehouseType: data.warehouse_type || data.warehouseType || 'Unknown Type',
          status: data.status || 'unknown',
          tailorName: data.tailor_name || data.tailorName || 'Unknown Tailor',
          tailorPhone: data.tailor_phone || data.tailorPhone || null,
          fabricType: data.fabric_type || data.fabricType || 'Unknown Fabric',
          estimatedWeight: data.estimated_weight || data.estimatedWeight || 0,
          logisticsId: data.logistics_id || data.logisticsId,
          isSelfAssigned: isSelfAssigned,
          assignedByLogisticsId: data.assigned_by_logistics_id || data.assignedByLogisticsId || null,
          assignedAt: data.assigned_at || data.assignedAt || null,
          warehouseAddress: data.warehouse_address || data.warehouseAddress || null,
          createdAt: data.created_at || data.createdAt || null,
          pickupRequestId: data.pickup_request_id || data.pickupRequestId || null
        }
      })

      // Get tailor pickup progress information
      const tailorProgress = pickupAssignments.map(doc => {
        const data = doc.data()
        return {
          id: doc.id,
          pickupRequestId: data.pickup_request_id || data.pickupRequestId,
          tailorName: data.tailor_name || data.tailorName || 'Unknown Tailor',
          fabricType: data.fabric_type || data.fabricType || 'Unknown Fabric',
          status: data.status || 'unknown',
          warehouseAssigned: !!(data.assigned_warehouse_id || data.assignedWarehouseId),
          warehouseName: data.assigned_warehouse_name || data.assignedWarehouseName || null,
          logisticsId: data.logistics_id || data.logisticsId || 'Unknown',
          estimatedWeight: data.estimated_weight || data.estimatedWeight || 0,
          tailorPhone: data.tailor_phone || data.tailorPhone || null,
          tailorAddress: data.tailor_address || data.tailorAddress || null
        }
      })

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
        issues,
        warehouseAssignments: warehouseAssignments.slice(0, 5),
        tailorProgress: tailorProgress.slice(0, 5)
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
          <CardTitle className="flex items-center">
            <TruckIcon className="h-5 w-5 mr-2" />
            Logistics Status
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse space-y-4">
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="h-20 bg-gray-200 rounded-lg"></div>
              ))}
            </div>
            <div className="space-y-2">
              {[...Array(3)].map((_, i) => (
                <div key={i} className="h-4 bg-gray-200 rounded"></div>
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
          <CardTitle className="flex items-center">
            <TruckIcon className="h-5 w-5 mr-2" />
            Logistics Status
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-4">
            <ExclamationTriangleIcon className="h-8 w-8 text-red-500 mx-auto mb-2" />
            <p className="text-red-600">Error loading logistics data: {error}</p>
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

          {/* Warehouse Assignments */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3 flex items-center">
              <WarehouseIcon className="h-4 w-4 mr-2 text-blue-500" />
              Warehouse Assignments
            </h4>
            <div className="space-y-2">
              {logisticsData.warehouseAssignments.length > 0 ? (
                logisticsData.warehouseAssignments.map((assignment) => (
                  <div key={assignment.id} className="p-3 bg-blue-50 rounded-lg border border-blue-200">
                    {/* Assignment Header with Status */}
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        <WarehouseIcon className="h-4 w-4 text-blue-500" />
                        <span className="text-sm font-medium text-blue-700">
                          Assignment #{assignment.id.slice(-6)}
                        </span>
                        {assignment.isSelfAssigned && (
                          <span className="px-2 py-1 rounded-full text-xs font-medium text-green-600 bg-green-100">
                            Self-Assigned ✓
                          </span>
                        )}
                      </div>
                      <span className="px-2 py-1 rounded-full text-xs font-medium text-blue-600 bg-blue-100">
                        {assignment.status}
                      </span>
                    </div>
                    
                    {/* Warehouse Information */}
                    <div className="mb-2 p-2 bg-blue-100 rounded border border-blue-300">
                      <div className="flex items-center space-x-2 mb-1">
                        <WarehouseIcon className="h-3 w-3 text-blue-600" />
                        <span className="text-xs font-medium text-blue-700">Warehouse Details</span>
                      </div>
                      <div className="text-xs text-gray-700 ml-5">
                        <div className="font-medium">{assignment.warehouseName}</div>
                        <div>Type: {assignment.warehouseType}</div>
                        {assignment.warehouseAddress && (
                          <div>Location: {assignment.warehouseAddress.substring(0, 30)}...</div>
                        )}
                      </div>
                    </div>
                    
                    {/* Logistics Personnel Information */}
                    <div className="mb-2 p-2 bg-green-50 rounded border border-green-200">
                      <div className="flex items-center space-x-2 mb-1">
                        <UserIcon className="h-3 w-3 text-green-600" />
                        <span className="text-xs font-medium text-green-700">Logistics Personnel</span>
                        {assignment.isSelfAssigned && (
                          <span className="px-1 py-0.5 rounded text-xs font-medium text-green-600 bg-green-100">
                            Self-Assigned
                          </span>
                        )}
                      </div>
                      <div className="text-xs text-gray-600 ml-5">
                        <div>ID: {assignment.logisticsId}</div>
                        <div>Status: {assignment.status}</div>
                        {assignment.isSelfAssigned && (
                          <div className="text-green-600 font-medium mt-1">
                            ✓ Logistics person assigned themselves to warehouse
                          </div>
                        )}
                        {assignment.assignedAt && (
                          <div>Assigned: {new Date(assignment.assignedAt).toLocaleDateString()}</div>
                        )}
                        {assignment.assignedByLogisticsId && assignment.assignedByLogisticsId === assignment.logisticsId && (
                          <div className="text-green-600 font-medium">
                            ✓ Self-assignment confirmed
                          </div>
                        )}
                      </div>
                    </div>
                    
                    {/* Tailor Information */}
                    <div className="p-2 bg-orange-50 rounded border border-orange-200">
                      <div className="flex items-center space-x-2 mb-1">
                        <ScissorsIcon className="h-3 w-3 text-orange-600" />
                        <span className="text-xs font-medium text-orange-700">Pickup Details</span>
                      </div>
                      <div className="text-xs text-gray-600 ml-5">
                        <div>Tailor: {assignment.tailorName}</div>
                        <div>Fabric: {assignment.fabricType}</div>
                        <div>Weight: {assignment.estimatedWeight}kg</div>
                        {assignment.tailorPhone && (
                          <div>Contact: {assignment.tailorPhone}</div>
                        )}
                      </div>
                    </div>

                    {/* Assignment Timeline */}
                    {(assignment.assignedAt || assignment.createdAt) && (
                      <div className="mt-2 p-2 bg-gray-50 rounded border border-gray-200">
                        <div className="flex items-center space-x-2 mb-1">
                          <ClockIcon className="h-3 w-3 text-gray-600" />
                          <span className="text-xs font-medium text-gray-700">Timeline</span>
                        </div>
                        <div className="text-xs text-gray-600 ml-5">
                          {assignment.createdAt && (
                            <div>Created: {new Date(assignment.createdAt).toLocaleString()}</div>
                          )}
                          {assignment.assignedAt && (
                            <div className="text-green-600 font-medium">
                              Warehouse Assigned: {new Date(assignment.assignedAt).toLocaleString()}
                            </div>
                          )}
                          {assignment.isSelfAssigned && (
                            <div className="text-blue-600 font-medium">
                              ⚡ Real-time assignment by logistics personnel
                            </div>
                          )}
                        </div>
                      </div>
                    )}
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500">No warehouse assignments found</p>
              )}
            </div>
          </div>

          {/* Tailor Pickup Progress */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3 flex items-center">
              <ScissorsIcon className="h-4 w-4 mr-2 text-orange-500" />
              Tailor Pickup Progress
            </h4>
            <div className="space-y-2">
              {logisticsData.tailorProgress.length > 0 ? (
                logisticsData.tailorProgress.map((progress) => (
                  <div key={progress.id} className="p-3 bg-orange-50 rounded-lg border border-orange-200">
                    {/* Tailor Information */}
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        <ScissorsIcon className="h-4 w-4 text-orange-500" />
                        <div className="flex flex-col">
                          <span className="text-sm text-gray-700 font-medium">
                            {progress.tailorName}
                          </span>
                          <span className="text-xs text-gray-500">
                            Fabric: {progress.fabricType} • Weight: {progress.estimatedWeight}kg
                          </span>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          progress.warehouseAssigned 
                            ? 'text-green-600 bg-green-100' 
                            : 'text-orange-600 bg-orange-100'
                        }`}>
                          {progress.warehouseAssigned ? 'Assigned' : 'Pending'}
                        </span>
                        <span className="text-xs text-gray-500">
                          #{progress.id.slice(-6)}
                        </span>
                      </div>
                    </div>
                    
                    {/* Logistics Personnel Information */}
                    <div className="mb-2 p-2 bg-green-50 rounded border border-green-200">
                      <div className="flex items-center space-x-2 mb-1">
                        <UserIcon className="h-3 w-3 text-green-600" />
                        <span className="text-xs font-medium text-green-700">Logistics Personnel</span>
                      </div>
                      <div className="text-xs text-gray-600 ml-5">
                        <div>ID: {progress.logisticsId}</div>
                        <div>Status: {progress.status}</div>
                      </div>
                    </div>
                    
                    {/* Warehouse Assignment Status */}
                    <div className="p-2 bg-blue-50 rounded border border-blue-200">
                      <div className="flex items-center space-x-2 mb-1">
                        <WarehouseIcon className="h-3 w-3 text-blue-600" />
                        <span className="text-xs font-medium text-blue-700">Warehouse Assignment</span>
                      </div>
                      <div className="text-xs text-gray-600 ml-5">
                        {progress.warehouseAssigned ? (
                          <div>
                            <div>✓ Assigned to: {progress.warehouseName}</div>
                            <div>Status: {progress.status}</div>
                          </div>
                        ) : (
                          <div className="text-orange-600">⏳ Pending warehouse assignment</div>
                        )}
                      </div>
                    </div>
                    
                    {/* Tailor Contact Information */}
                    {(progress.tailorPhone || progress.tailorAddress) && (
                      <div className="p-2 bg-gray-50 rounded border border-gray-200">
                        <div className="flex items-center space-x-2 mb-1">
                          <ScissorsIcon className="h-3 w-3 text-gray-600" />
                          <span className="text-xs font-medium text-gray-700">Tailor Contact</span>
                        </div>
                        <div className="text-xs text-gray-600 ml-5">
                          {progress.tailorPhone && <div>Phone: {progress.tailorPhone}</div>}
                          {progress.tailorAddress && <div>Address: {progress.tailorAddress.substring(0, 50)}...</div>}
                        </div>
                      </div>
                    )}
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500">No tailor pickup progress</p>
              )}
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