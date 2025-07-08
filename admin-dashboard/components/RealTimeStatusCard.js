'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, onSnapshot } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  SignalIcon,
  UsersIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  WifiIcon
} from '@heroicons/react/24/outline'

export default function RealTimeStatusCard() {
  const [realTimeData, setRealTimeData] = useState({
    activeUsers: 0,
    inProgressPickups: 0,
    pendingRequests: 0,
    systemStatus: 'operational',
    lastUpdated: new Date(),
    alerts: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchRealTimeData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch active users (users who have been active in the last 24 hours)
      const users = await getDocs(collection(db, 'users'))
      const activeUsers = users.docs.filter(doc => {
        const userData = doc.data()
        const lastActive = userData.lastActive?.toDate?.() || userData.last_active?.toDate?.() || new Date(0)
        return (new Date() - lastActive) < 24 * 60 * 60 * 1000 // 24 hours
      }).length

      // Fetch in-progress pickups
      const inProgressPickups = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', 'in', ['in_tailoring', 'in_logistics', 'in_warehouse'])
      ))

      // Fetch pending requests
      const pendingRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'pending')
      ))

      // Determine system status based on various factors
      let systemStatus = 'operational'
      const alerts = []

      if (pendingRequests.docs.length > 10) {
        systemStatus = 'warning'
        alerts.push('High number of pending requests')
      }

      if (inProgressPickups.docs.length > 50) {
        systemStatus = 'warning'
        alerts.push('High workload in progress')
      }

      if (activeUsers === 0) {
        systemStatus = 'error'
        alerts.push('No active users detected')
      }

      setRealTimeData({
        activeUsers,
        inProgressPickups: inProgressPickups.docs.length,
        pendingRequests: pendingRequests.docs.length,
        systemStatus,
        lastUpdated: new Date(),
        alerts
      })
    } catch (err) {
      console.error('Error fetching real-time data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchRealTimeData()
    
    // Set up real-time updates every 30 seconds
    const interval = setInterval(fetchRealTimeData, 30000)
    
    return () => clearInterval(interval)
  }, [])

  const getStatusColor = (status) => {
    switch (status) {
      case 'operational':
        return 'text-green-600 bg-green-100'
      case 'warning':
        return 'text-yellow-600 bg-yellow-100'
      case 'error':
        return 'text-red-600 bg-red-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  const getStatusIcon = (status) => {
    switch (status) {
      case 'operational':
        return <CheckCircleIcon className="h-5 w-5 text-green-500" />
      case 'warning':
        return <ExclamationTriangleIcon className="h-5 w-5 text-yellow-500" />
      case 'error':
        return <ExclamationTriangleIcon className="h-5 w-5 text-red-500" />
      default:
        return <SignalIcon className="h-5 w-5 text-gray-500" />
    }
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Real-Time Status</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
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
          <CardTitle>Real-Time Status</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-red-600">
            <ExclamationTriangleIcon className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading real-time data</p>
            <p className="text-sm text-gray-500">{error}</p>
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
            <SignalIcon className="h-5 w-5 mr-2" />
            Real-Time Status
          </div>
          <div className="flex items-center space-x-2">
            <div className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(realTimeData.systemStatus)}`}>
              {realTimeData.systemStatus}
            </div>
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
          </div>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* System Status */}
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center space-x-3">
              {getStatusIcon(realTimeData.systemStatus)}
              <div>
                <p className="text-sm font-medium text-gray-900">System Status</p>
                <p className="text-xs text-gray-500">Last updated: {realTimeData.lastUpdated.toLocaleTimeString()}</p>
              </div>
            </div>
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(realTimeData.systemStatus)}`}>
              {realTimeData.systemStatus}
            </span>
          </div>

          {/* Live Metrics */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="text-center p-3 bg-blue-50 rounded-lg">
              <UsersIcon className="h-8 w-8 text-blue-600 mx-auto mb-2" />
              <p className="text-lg font-semibold text-gray-900">{realTimeData.activeUsers}</p>
              <p className="text-xs text-gray-500">Active Users</p>
            </div>
            <div className="text-center p-3 bg-orange-50 rounded-lg">
              <ClockIcon className="h-8 w-8 text-orange-600 mx-auto mb-2" />
              <p className="text-lg font-semibold text-gray-900">{realTimeData.inProgressPickups}</p>
              <p className="text-xs text-gray-500">In Progress</p>
            </div>
            <div className="text-center p-3 bg-yellow-50 rounded-lg">
              <ExclamationTriangleIcon className="h-8 w-8 text-yellow-600 mx-auto mb-2" />
              <p className="text-lg font-semibold text-gray-900">{realTimeData.pendingRequests}</p>
              <p className="text-xs text-gray-500">Pending</p>
            </div>
          </div>

          {/* Alerts */}
          {realTimeData.alerts.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-gray-900 mb-2">Active Alerts</h4>
              <div className="space-y-2">
                {realTimeData.alerts.map((alert, index) => (
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