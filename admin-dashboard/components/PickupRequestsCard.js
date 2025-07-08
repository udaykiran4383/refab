'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, orderBy, limit } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  ShoppingBagIcon, 
  ClockIcon, 
  CheckCircleIcon, 
  ExclamationTriangleIcon,
  TruckIcon,
  UserIcon
} from '@heroicons/react/24/outline'
import { formatDistanceToNow } from 'date-fns'

export default function PickupRequestsCard() {
  const [pickupData, setPickupData] = useState({
    totalRequests: 0,
    pendingRequests: 0,
    scheduledRequests: 0,
    completedRequests: 0,
    recentRequests: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchPickupData = async () => {
    try {
      console.log('📦 [PICKUP_REQUESTS] Fetching pickup requests data...')
      setLoading(true)
      setError(null)

      // Get all pickup requests
      const pickupRequestsRef = collection(db, 'pickupRequests')
      const pickupSnapshot = await getDocs(pickupRequestsRef)
      
      const requests = pickupSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }))

      // Calculate metrics
      const totalRequests = requests.length
      const pendingRequests = requests.filter(r => r.status === 'pending').length
      const scheduledRequests = requests.filter(r => r.status === 'scheduled').length
      const completedRequests = requests.filter(r => r.status === 'completed').length

      // Get recent requests (last 5)
      const recentRequests = requests
        .sort((a, b) => {
          const dateA = a.created_at ? new Date(a.created_at) : new Date(0)
          const dateB = b.created_at ? new Date(b.created_at) : new Date(0)
          return dateB - dateA
        })
        .slice(0, 5)

      const newData = {
        totalRequests,
        pendingRequests,
        scheduledRequests,
        completedRequests,
        recentRequests
      }

      console.log('📦 [PICKUP_REQUESTS] Data updated:', newData)
      setPickupData(newData)
    } catch (err) {
      console.error('📦 [PICKUP_REQUESTS] Error fetching data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchPickupData()
  }, [])

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending':
        return 'bg-orange-100 text-orange-800'
      case 'scheduled':
        return 'bg-blue-100 text-blue-800'
      case 'inProgress':
        return 'bg-purple-100 text-purple-800'
      case 'pickedUp':
        return 'bg-indigo-100 text-indigo-800'
      case 'inTransit':
        return 'bg-teal-100 text-teal-800'
      case 'delivered':
        return 'bg-green-100 text-green-800'
      case 'completed':
        return 'bg-green-100 text-green-800'
      case 'cancelled':
        return 'bg-red-100 text-red-800'
      case 'rejected':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusIcon = (status) => {
    switch (status) {
      case 'pending':
        return ClockIcon
      case 'scheduled':
        return TruckIcon
      case 'inProgress':
        return ExclamationTriangleIcon
      case 'pickedUp':
        return TruckIcon
      case 'inTransit':
        return TruckIcon
      case 'delivered':
        return CheckCircleIcon
      case 'completed':
        return CheckCircleIcon
      case 'cancelled':
        return ExclamationTriangleIcon
      case 'rejected':
        return ExclamationTriangleIcon
      default:
        return ClockIcon
    }
  }

  const completionRate = pickupData.totalRequests > 0 
    ? Math.round((pickupData.completedRequests / pickupData.totalRequests) * 100) 
    : 0

  const assignmentRate = pickupData.totalRequests > 0 
    ? Math.round(((pickupData.scheduledRequests + pickupData.completedRequests) / pickupData.totalRequests) * 100) 
    : 0

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <ShoppingBagIcon className="h-5 w-5 mr-2" />
            Pickup Requests Overview
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
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
            <ShoppingBagIcon className="h-5 w-5 mr-2" />
            Pickup Requests Overview
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8">
            <ExclamationTriangleIcon className="h-12 w-12 text-red-500 mx-auto mb-4" />
            <p className="text-red-600">Error loading pickup requests</p>
            <p className="text-sm text-gray-500 mt-1">{error}</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <div className="flex items-center">
            <ShoppingBagIcon className="h-5 w-5 mr-2" />
            Pickup Requests Overview
          </div>
          <div className="flex items-center text-orange-600 text-sm">
            <div className="w-2 h-2 bg-orange-500 rounded-full mr-2 animate-pulse"></div>
            {pickupData.pendingRequests} Pending
          </div>
        </CardTitle>
      </CardHeader>
      <CardContent>
        {/* Key Metrics */}
        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="text-center">
            <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center mx-auto mb-2">
              <ShoppingBagIcon className="h-6 w-6 text-blue-600" />
            </div>
            <p className="text-2xl font-bold text-gray-900">{pickupData.totalRequests}</p>
            <p className="text-xs text-gray-500">Total</p>
          </div>
          <div className="text-center">
            <div className="w-12 h-12 rounded-lg bg-orange-100 flex items-center justify-center mx-auto mb-2">
              <ClockIcon className="h-6 w-6 text-orange-600" />
            </div>
            <p className="text-2xl font-bold text-gray-900">{pickupData.pendingRequests}</p>
            <p className="text-xs text-gray-500">Pending</p>
          </div>
          <div className="text-center">
            <div className="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center mx-auto mb-2">
              <CheckCircleIcon className="h-6 w-6 text-green-600" />
            </div>
            <p className="text-2xl font-bold text-gray-900">{pickupData.completedRequests}</p>
            <p className="text-xs text-gray-500">Completed</p>
          </div>
        </div>

        {/* Progress Indicators */}
        <div className="space-y-4 mb-6">
          <div>
            <div className="flex justify-between text-sm mb-1">
              <span className="text-gray-600">Completion Rate</span>
              <span className="font-medium text-green-600">{completionRate}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-green-600 h-2 rounded-full transition-all duration-300" 
                style={{ width: `${completionRate}%` }}
              ></div>
            </div>
          </div>
          <div>
            <div className="flex justify-between text-sm mb-1">
              <span className="text-gray-600">Assignment Rate</span>
              <span className="font-medium text-blue-600">{assignmentRate}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                style={{ width: `${assignmentRate}%` }}
              ></div>
            </div>
          </div>
        </div>

        {/* Recent Requests */}
        <div>
          <h4 className="text-sm font-semibold text-gray-900 mb-3">Recent Requests</h4>
          {pickupData.recentRequests.length > 0 ? (
            <div className="space-y-3">
              {pickupData.recentRequests.map((request) => {
                const StatusIcon = getStatusIcon(request.status)
                return (
                  <div key={request.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    <div className="flex items-center flex-1">
                      <StatusIcon className="h-4 w-4 mr-3 text-gray-500" />
                      <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900">
                          {request.customerName || request.customer_name || 'Unknown Customer'}
                        </p>
                        <p className="text-xs text-gray-500">
                          {request.fabricType || request.fabric_type || 'Unknown'} - {request.estimatedWeight || request.estimated_weight || 0}kg
                        </p>
                        {request.created_at && (
                          <p className="text-xs text-gray-400">
                            {formatDistanceToNow(new Date(request.created_at), { addSuffix: true })}
                          </p>
                        )}
                      </div>
                    </div>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(request.status)}`}>
                      {request.status || 'Pending'}
                    </span>
                  </div>
                )
              })}
            </div>
          ) : (
            <div className="text-center py-8">
              <ShoppingBagIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">No recent requests</p>
              <p className="text-sm text-gray-400 mt-1">New pickup requests will appear here</p>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
} 