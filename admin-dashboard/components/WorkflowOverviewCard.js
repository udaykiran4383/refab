'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, orderBy, limit } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  TruckIcon, 
  ScissorsIcon, 
  CubeIcon, 
  CheckCircleIcon,
  ClockIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline'

export default function WorkflowOverviewCard() {
  const [workflowData, setWorkflowData] = useState({
    pickupRequests: 0,
    inTailoring: 0,
    inLogistics: 0,
    inWarehouse: 0,
    completed: 0,
    recentActivity: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchWorkflowData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch pickup requests with different statuses
      const pickupRequests = await getDocs(collection(db, 'pickupRequests'))
      const tailoringRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'in_tailoring')
      ))
      const logisticsRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'in_logistics')
      ))
      const warehouseRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'in_warehouse')
      ))
      const completedRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'completed')
      ))

      // Get recent activity
      const recentActivity = await getDocs(query(
        collection(db, 'pickupRequests'),
        orderBy('created_at', 'desc'),
        limit(5)
      ))

      setWorkflowData({
        pickupRequests: pickupRequests.docs.length,
        inTailoring: tailoringRequests.docs.length,
        inLogistics: logisticsRequests.docs.length,
        inWarehouse: warehouseRequests.docs.length,
        completed: completedRequests.docs.length,
        recentActivity: recentActivity.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }))
      })
    } catch (err) {
      console.error('Error fetching workflow data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchWorkflowData()
  }, [])

  const workflowSteps = [
    {
      name: 'Customer',
      count: workflowData.pickupRequests,
      icon: TruckIcon,
      color: 'blue',
      description: 'Tailor has fabric'
    },
    {
      name: 'Tailoring',
      count: workflowData.inTailoring,
      icon: ScissorsIcon,
      color: 'purple',
      description: 'Processing available fabric'
    },
    {
      name: 'Logistics',
      count: workflowData.inLogistics,
      icon: TruckIcon,
      color: 'orange',
      description: 'Tailor to warehouse'
    },
    {
      name: 'Warehouse',
      count: workflowData.inWarehouse,
      icon: CubeIcon,
      color: 'green',
      description: 'Stores products'
    },
    {
      name: 'Completed',
      count: workflowData.completed,
      icon: CheckCircleIcon,
      color: 'emerald',
      description: 'Customer receives'
    }
  ]

  const getStatusIcon = (status) => {
    switch (status?.toLowerCase()) {
      case 'completed':
        return <CheckCircleIcon className="h-4 w-4 text-green-500" />
      case 'in_progress':
      case 'in_tailoring':
      case 'in_logistics':
      case 'in_warehouse':
        return <ClockIcon className="h-4 w-4 text-blue-500" />
      case 'pending':
        return <ClockIcon className="h-4 w-4 text-yellow-500" />
      default:
        return <ExclamationTriangleIcon className="h-4 w-4 text-gray-500" />
    }
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Workflow Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
            <div className="space-y-3">
              {[1, 2, 3, 4, 5].map((i) => (
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
          <CardTitle>Workflow Overview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-red-600">
            <ExclamationTriangleIcon className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading workflow data</p>
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
          Workflow Overview
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Workflow Steps */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
            {workflowSteps.map((step) => {
              const IconComponent = step.icon
              return (
                <div key={step.name} className="text-center">
                  <div className={`w-12 h-12 rounded-lg flex items-center justify-center bg-${step.color}-100 mx-auto mb-2`}>
                    <IconComponent className={`h-6 w-6 text-${step.color}-600`} />
                  </div>
                  <p className="text-lg font-semibold text-gray-900">{step.count}</p>
                  <p className="text-sm font-medium text-gray-700">{step.name}</p>
                  <p className="text-xs text-gray-500">{step.description}</p>
                </div>
              )
            })}
          </div>

          {/* Recent Activity */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3">Recent Activity</h4>
            <div className="space-y-2">
              {workflowData.recentActivity.slice(0, 3).map((activity) => (
                <div key={activity.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(activity.status)}
                    <span className="text-sm text-gray-700">
                      {activity.customerName || activity.customer_name || 'Unknown Customer'}
                    </span>
                  </div>
                  <span className="text-xs text-gray-500 capitalize">
                    {activity.status?.replace('_', ' ') || 'Unknown'}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  )
} 