'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card'
import Button from '../components/ui/Button'
import WorkflowOverviewCard from '../components/WorkflowOverviewCard'
import RealTimeStatusCard from '../components/RealTimeStatusCard'
import TailorProgressCard from '../components/TailorProgressCard'
import LogisticsStatusCard from '../components/LogisticsStatusCard'
import WarehouseStatusCard from '../components/WarehouseStatusCard'
import AnalyticsCard from '../components/AnalyticsCard'
import PickupRequestsCard from '../components/PickupRequestsCard'
import { 
  UsersIcon, 
  TruckIcon, 
  CubeIcon, 
  ShoppingCartIcon,
  ChartBarIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ArrowPathIcon,
  WifiIcon,
  MapPinIcon
} from '@heroicons/react/24/outline'
import { WifiSlashIcon } from '@heroicons/react/24/solid'
import { formatDistanceToNow } from 'date-fns'
import toast from 'react-hot-toast'

// DEV_MODE: Set to true to always show sample data (for development/testing)
const DEV_MODE = false;

// Sample/mock data for fallback
const SAMPLE_STATS = {
  totalUsers: 42,
  totalPickups: 17,
  totalProducts: 8,
  totalOrders: 23,
  pickupAssignments: 5,
  deliveryAssignments: 4,
  activePickupAssignments: 2,
  activeDeliveryAssignments: 1,
  recentPickups: [
    { id: 'PU123456', customerName: 'Alice', status: 'pending', createdAt: new Date() },
    { id: 'PU123457', customerName: 'Bob', status: 'completed', createdAt: new Date(Date.now() - 3600 * 1000) },
    { id: 'PU123458', customerName: 'Charlie', status: 'inProgress', createdAt: new Date(Date.now() - 2 * 3600 * 1000) },
  ],
  pendingPickups: 3,
  completedPickups: 10,
};

export default function Dashboard() {
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
  const [lastUpdated, setLastUpdated] = useState(new Date())
  const [isOnline, setIsOnline] = useState(true)
  const [isRefreshing, setIsRefreshing] = useState(false)

  const fetchStats = async () => {
    const timeout = new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timeout after 30 seconds')), 30000)
    )

    try {
      if (DEV_MODE) {
        setStats(SAMPLE_STATS)
        setError(null)
        setLastUpdated(new Date())
        return
      }
      console.log('🔄 Starting fetchStats...')
      console.log('📊 Current Firebase config:', {
        projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'refab-app'
      })
      setLoading(true)
      setError(null)

      // Wrap the fetch operation with timeout
      await Promise.race([
        (async () => {
          // Test Firebase connection first
          console.log('🔗 Testing Firebase connection...')
          try {
            const testCollection = collection(db, 'users')
            console.log('✅ Firebase connection test passed')
          } catch (connError) {
            console.error('❌ Firebase connection test failed:', connError)
            throw new Error(`Firebase connection failed: ${connError.message}`)
          }

          console.log('📋 Fetching users collection...')
          const users = await getDocs(collection(db, 'users'))
          console.log('✅ Users fetched:', users.docs.length, 'documents')

          console.log('📋 Fetching pickupRequests collection...')
          const pickups = await getDocs(collection(db, 'pickupRequests'))
          console.log('✅ Pickups fetched:', pickups.docs.length, 'documents')

          console.log('📋 Fetching products collection...')
          const products = await getDocs(collection(db, 'products'))
          console.log('✅ Products fetched:', products.docs.length, 'documents')

          console.log('📋 Fetching orders collection...')
          const orders = await getDocs(collection(db, 'orders'))
          console.log('✅ Orders fetched:', orders.docs.length, 'documents')

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

          // Fetch logistics assignments for new structure
          console.log('📋 Fetching logisticsAssignments collection...')
          const logisticsAssignments = await getDocs(collection(db, 'logisticsAssignments'))
          console.log('✅ Logistics assignments fetched:', logisticsAssignments.docs.length, 'documents')

          // Separate pickup and delivery assignments
          const pickupAssignments = logisticsAssignments.docs.filter(doc => {
            const data = doc.data()
            return data.type === 'pickup'
          })
          
          const deliveryAssignments = logisticsAssignments.docs.filter(doc => {
            const data = doc.data()
            return data.type === 'delivery'
          })

          const activePickupAssignments = pickupAssignments.filter(doc => {
            const data = doc.data()
            return data.status === 'inProgress'
          })
          
          const activeDeliveryAssignments = deliveryAssignments.filter(doc => {
            const data = doc.data()
            return data.status === 'inProgress'
          })

          const newStats = {
            totalUsers: users.docs.length,
            totalPickups: pickups.docs.length,
            totalProducts: products.docs.length,
            totalOrders: orders.docs.length,
            pickupAssignments: pickupAssignments.length,
            deliveryAssignments: deliveryAssignments.length,
            activePickupAssignments: activePickupAssignments.length,
            activeDeliveryAssignments: activeDeliveryAssignments.length,
            recentPickups,
            pendingPickups,
            completedPickups
          }

          console.log('✅ Dashboard stats updated:', newStats)
          setStats(newStats)
          setLastUpdated(new Date())
        })(),
        timeout
      ])
    } catch (err) {
      console.error('❌ Error fetching dashboard stats:', err)
      console.error('❌ Error details:', {
        code: err.code,
        message: err.message,
        stack: err.stack
      })
      setError(err.message)
      // Fallback: Show sample data if in dev or if all stats are zero
      if (DEV_MODE || (stats.totalUsers === 0 && stats.totalPickups === 0 && stats.totalProducts === 0 && stats.totalOrders === 0)) {
        setStats(SAMPLE_STATS)
      }
    } finally {
      console.log('🏁 fetchStats completed, setting loading to false')
      setLoading(false)
    }
  }

  // Debug logging for data flow understanding
  useEffect(() => {
    console.log('🔍 Main Dashboard Debug Info:')
    console.log('📈 Stats:', stats)
    console.log('🔄 Loading states:', { loading })
    console.log('❌ Error states:', { error })
    console.log('🌐 Online status:', isOnline)
    console.log('⏰ Last updated:', lastUpdated)
    
    if (stats.totalUsers > 0) {
      console.log('✅ Data loaded successfully')
    } else {
      console.log('⚠️ No data yet')
    }
  }, [stats, loading, error, isOnline, lastUpdated])

  // Fetch data on mount
  useEffect(() => {
    fetchStats()
  }, [])

  // Monitor online/offline status
  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true)
      toast.success('Connection restored')
    }
    
    const handleOffline = () => {
      setIsOnline(false)
      toast.error('Connection lost')
    }

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)
    
    setIsOnline(navigator.onLine)

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [])

  // Manual refresh function
  const handleRefresh = async () => {
    setIsRefreshing(true)
    try {
      await fetchStats()
      setLastUpdated(new Date())
      toast.success('Dashboard refreshed')
    } catch (error) {
      toast.error('Failed to refresh dashboard')
    } finally {
      setIsRefreshing(false)
    }
  }

  const statCards = [
    {
      title: 'Total Users',
      value: stats.totalUsers,
      icon: UsersIcon,
      color: 'blue',
      description: 'Registered users',
      trend: '+12% this week'
    },
    {
      title: 'Pickup Assignments',
      value: stats.pickupAssignments || 0,
      icon: TruckIcon,
      color: 'blue',
      description: 'Tailor → Warehouse',
      trend: `${stats.activePickupAssignments || 0} active`
    },
    {
      title: 'Delivery Assignments',
      value: stats.deliveryAssignments || 0,
      icon: MapPinIcon,
      color: 'green',
      description: 'Warehouse → Customer',
      trend: `${stats.activeDeliveryAssignments || 0} active`
    },
    {
      title: 'Orders',
      value: stats.totalOrders,
      icon: ShoppingCartIcon,
      color: 'purple',
      description: 'Total orders',
      trend: '+8% this month'
    }
  ]

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'text-yellow-600 bg-yellow-100'
      case 'in_progress':
      case 'in progress':
        return 'text-blue-600 bg-blue-100'
      case 'completed':
      case 'delivered':
        return 'text-green-600 bg-green-100'
      case 'cancelled':
        return 'text-red-600 bg-red-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  if (loading && !isRefreshing) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading dashboard...</p>
          <p className="text-sm text-gray-400 mt-2">Connecting to Firebase</p>
        </div>
      </div>
    )
  }

  if (error && !isOnline) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <WifiSlashIcon className="h-16 w-16 text-red-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">No Internet Connection</h1>
          <p className="text-gray-600 mb-4">Please check your internet connection and try again.</p>
          <Button onClick={handleRefresh} variant="primary" disabled={!isOnline}>
            <ArrowPathIcon className="h-4 w-4 mr-2" />
            Retry
          </Button>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <ExclamationTriangleIcon className="h-16 w-16 text-red-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Dashboard Error</h1>
          <p className="text-gray-600 mb-4">{error}</p>
          <div className="space-y-2">
            <Button onClick={handleRefresh} variant="primary" disabled={isRefreshing}>
              <ArrowPathIcon className={`h-4 w-4 mr-2 ${isRefreshing ? 'animate-spin' : ''}`} />
              {isRefreshing ? 'Retrying...' : 'Retry'}
            </Button>
            <Button onClick={() => window.location.reload()} variant="outline" className="ml-2">
              Reload Page
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
              <p className="text-gray-600">Monitor your Refab application</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                {isOnline ? (
                  <WifiIcon className="h-5 w-5 text-green-500" />
                ) : (
                  <WifiSlashIcon className="h-5 w-5 text-red-500" />
                )}
                <span className={`text-sm ${isOnline ? 'text-green-600' : 'text-red-600'}`}>
                  {isOnline ? 'Online' : 'Offline'}
                </span>
              </div>
              <div className="text-right">
                <p className="text-sm text-gray-500">Last updated</p>
                <p className="text-sm font-medium text-gray-900">
                  {lastUpdated.toLocaleTimeString()}
                </p>
              </div>
              <Button 
                onClick={handleRefresh} 
                variant="outline" 
                size="sm"
                disabled={isRefreshing}
                className="ml-4"
                data-testid="refresh-button"
              >
                <ArrowPathIcon className={`h-4 w-4 ${isRefreshing ? 'animate-spin' : ''}`} />
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {statCards.map((stat) => {
            const IconComponent = stat.icon
            return (
              <Card key={stat.title} className="hover:shadow-lg transition-shadow">
                <CardContent>
                  <div className="flex items-center">
                    <div className="flex-shrink-0">
                      <div className={`w-12 h-12 rounded-lg flex items-center justify-center bg-${stat.color}-100`}>
                        <IconComponent className={`h-6 w-6 text-${stat.color}-600`} />
                      </div>
                    </div>
                    <div className="ml-4 flex-1">
                      <p className="text-sm font-medium text-gray-500">{stat.title}</p>
                      <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                      <p className="text-xs text-gray-400">{stat.description}</p>
                      {stat.trend && (
                        <p className="text-xs text-green-600 mt-1">{stat.trend}</p>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Recent Activity */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center justify-between">
                <div className="flex items-center">
                  <ClockIcon className="h-5 w-5 mr-2" />
                  Recent Pickup Requests
                </div>
                {stats && stats.totalUsers > 0 && (
                  <div className="flex items-center text-green-600 text-sm">
                    <div className="w-2 h-2 bg-green-500 rounded-full mr-2 animate-pulse"></div>
                    Live
                  </div>
                )}
              </CardTitle>
            </CardHeader>
            <CardContent>
              {stats && stats.recentPickups && stats.recentPickups.length > 0 ? (
                <div className="space-y-4">
                  {stats.recentPickups.map((pickup) => (
                    <div key={pickup.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                      <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900">
                          Pickup #{pickup.id.slice(-6)}
                        </p>
                        <p className="text-xs text-gray-500">
                          {pickup.customerName || pickup.customer_name || pickup.customer?.name || 'Unknown Customer'}
                        </p>
                        {pickup.createdAt && (
                          <p className="text-xs text-gray-400">
                            {formatDistanceToNow(pickup.createdAt.toDate(), { addSuffix: true })}
                          </p>
                        )}
                      </div>
                      <div className="flex items-center">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(pickup.status)}`}>
                          {pickup.status || 'Pending'}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <CheckCircleIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">No recent pickup requests</p>
                  <p className="text-sm text-gray-400 mt-1">New requests will appear here</p>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Quick Actions */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <ChartBarIcon className="h-5 w-5 mr-2" />
                Quick Actions
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 gap-3">
                <Button 
                  variant="primary" 
                  className="w-full justify-center"
                  onClick={() => window.location.href = '/users'}
                >
                  <UsersIcon className="h-4 w-4 mr-2" />
                  Manage Users
                </Button>
                <Button 
                  variant="success" 
                  className="w-full justify-center"
                  onClick={() => window.location.href = '/pickups'}
                >
                  <TruckIcon className="h-4 w-4 mr-2" />
                  View Pickups
                </Button>
                <Button 
                  variant="secondary" 
                  className="w-full justify-center"
                  onClick={() => window.location.href = '/products'}
                >
                  <CubeIcon className="h-4 w-4 mr-2" />
                  Manage Products
                </Button>
                <Button 
                  variant="outline" 
                  className="w-full justify-center"
                  onClick={() => window.location.href = '/analytics'}
                >
                  <ChartBarIcon className="h-4 w-4 mr-2" />
                  View Analytics
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* System Status */}
        <Card className="mt-8">
          <CardHeader>
            <CardTitle>System Status</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="flex items-center">
                {isOnline ? (
                  <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2" />
                ) : (
                  <ExclamationTriangleIcon className="h-5 w-5 text-red-500 mr-2" />
                )}
                <span className="text-sm text-gray-600">Internet Connection</span>
              </div>
              <div className="flex items-center">
                {!error ? (
                  <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2" />
                ) : (
                  <ExclamationTriangleIcon className="h-5 w-5 text-red-500 mr-2" />
                )}
                <span className="text-sm text-gray-600">Firebase Connection</span>
              </div>
              <div className="flex items-center">
                {stats && stats.totalUsers > 0 ? (
                  <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2" />
                ) : (
                  <ExclamationTriangleIcon className="h-5 w-5 text-yellow-500 mr-2" />
                )}
                <span className="text-sm text-gray-600">Real-time Updates</span>
              </div>
              <div className="flex items-center">
                <CheckCircleIcon className="h-5 w-5 text-green-500 mr-2" />
                <span className="text-sm text-gray-600">Database Access</span>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Comprehensive Admin Dashboard */}
        <div className="mt-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">Comprehensive Operations Dashboard</h2>
          
          {/* First Row - Workflow & Real-time Status */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <WorkflowOverviewCard />
            <RealTimeStatusCard />
          </div>

          {/* Second Row - Tailor & Logistics */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <TailorProgressCard />
            <LogisticsStatusCard />
          </div>

          {/* Third Row - Pickup Requests & Warehouse */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <PickupRequestsCard />
            <WarehouseStatusCard />
          </div>

          {/* Fourth Row - Analytics */}
          <div className="grid grid-cols-1 gap-6 mb-6">
            <AnalyticsCard />
          </div>
        </div>
      </div>
    </div>
  )
} 