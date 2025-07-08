'use client'

import { useState, useEffect } from 'react'
import { useRealtimeDashboard, useDashboardStats } from '../../lib/hooks/useFirebase'
import { Card, CardHeader, CardTitle, CardContent } from '../../components/ui/Card'
import Button from '../../components/ui/Button'
import { 
  ChartBarIcon, 
  ExclamationTriangleIcon,
  ArrowLeftIcon,
  EyeIcon,
  EyeSlashIcon,
  UsersIcon,
  TruckIcon,
  CubeIcon,
  ShoppingCartIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon
} from '@heroicons/react/24/outline'
import { formatDistanceToNow } from 'date-fns'
import toast from 'react-hot-toast'

export default function AnalyticsPage() {
  const { stats: realtimeStats, loading: realtimeLoading, error: realtimeError } = useRealtimeDashboard()
  const { stats, loading, error, fetchStats } = useDashboardStats()
  const [showDebug, setShowDebug] = useState(false)
  const [timeRange, setTimeRange] = useState('7d')

  // Use real-time stats if available, fallback to regular stats
  const currentStats = realtimeStats && realtimeStats.totalUsers > 0 ? realtimeStats : stats
  const currentLoading = realtimeLoading || loading
  const currentError = realtimeError || error

  // Debug logging
  useEffect(() => {
    console.log('🔍 Analytics Page Debug Info:')
    console.log('📊 Real-time stats:', realtimeStats)
    console.log('📈 Regular stats:', stats)
    console.log('🔄 Loading states:', { realtimeLoading, loading })
    console.log('❌ Error states:', { realtimeError, error })
    console.log('📋 Current stats being used:', currentStats)
  }, [realtimeStats, stats, realtimeLoading, loading, realtimeError, error, currentStats])

  const analyticsCards = [
    {
      title: 'Total Users',
      value: currentStats.totalUsers || 0,
      icon: UsersIcon,
      color: 'blue',
      trend: '+12%',
      trendDirection: 'up'
    },
    {
      title: 'Pickup Requests',
      value: currentStats.totalPickups || 0,
      icon: TruckIcon,
      color: 'green',
      trend: '+8%',
      trendDirection: 'up'
    },
    {
      title: 'Products',
      value: currentStats.totalProducts || 0,
      icon: CubeIcon,
      color: 'purple',
      trend: '+5%',
      trendDirection: 'up'
    },
    {
      title: 'Orders',
      value: currentStats.totalOrders || 0,
      icon: ShoppingCartIcon,
      color: 'orange',
      trend: '+15%',
      trendDirection: 'up'
    }
  ]

  const getTrendIcon = (direction) => {
    return direction === 'up' ? 
      <ArrowTrendingUpIcon className="h-4 w-4 text-green-500" /> : 
      <ArrowTrendingDownIcon className="h-4 w-4 text-red-500" />
  }

  const getTrendColor = (direction) => {
    return direction === 'up' ? 'text-green-600' : 'text-red-600'
  }

  if (currentLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading analytics...</p>
          <p className="text-sm text-gray-400 mt-2">Fetching from Firebase</p>
        </div>
      </div>
    )
  }

  if (currentError) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <ExclamationTriangleIcon className="h-16 w-16 text-red-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Error Loading Analytics</h1>
          <p className="text-gray-600 mb-4">{currentError}</p>
          <Button onClick={fetchStats} variant="primary">
            Retry
          </Button>
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
            <div className="flex items-center">
              <Button 
                onClick={() => window.history.back()} 
                variant="outline" 
                className="mr-4"
              >
                <ArrowLeftIcon className="h-4 w-4 mr-2" />
                Back
              </Button>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Analytics Dashboard</h1>
                <p className="text-gray-600">Comprehensive analytics and insights</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <ChartBarIcon className="h-5 w-5 text-green-500" />
                <span className="text-sm text-green-600">Live Updates</span>
              </div>
              <Button 
                onClick={() => setShowDebug(!showDebug)} 
                variant="outline" 
                size="sm"
              >
                {showDebug ? <EyeSlashIcon className="h-4 w-4 mr-2" /> : <EyeIcon className="h-4 w-4 mr-2" />}
                {showDebug ? 'Hide Debug' : 'Show Debug'}
              </Button>
              <Button onClick={fetchStats} variant="outline" size="sm">
                Refresh
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Debug Panel */}
        {showDebug && (
          <Card className="mb-6 border-yellow-200 bg-yellow-50">
            <CardHeader>
              <CardTitle className="text-yellow-800">🔍 Debug Information</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div>
                  <strong>Real-time Loading:</strong> {realtimeLoading ? 'Yes' : 'No'}
                </div>
                <div>
                  <strong>Regular Loading:</strong> {loading ? 'Yes' : 'No'}
                </div>
                <div>
                  <strong>Real-time Error:</strong> {realtimeError ? 'Yes' : 'No'}
                </div>
                <div>
                  <strong>Regular Error:</strong> {error ? 'Yes' : 'No'}
                </div>
              </div>
              <div className="mt-4">
                <strong>Real-time Stats:</strong>
                <pre className="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto max-h-40">
                  {JSON.stringify(realtimeStats, null, 2)}
                </pre>
              </div>
              <div className="mt-4">
                <strong>Regular Stats:</strong>
                <pre className="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto max-h-40">
                  {JSON.stringify(stats, null, 2)}
                </pre>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Time Range Filter */}
        <div className="mb-6">
          <div className="flex space-x-2">
            {['1d', '7d', '30d', '90d'].map((range) => (
              <Button
                key={range}
                onClick={() => setTimeRange(range)}
                variant={timeRange === range ? 'primary' : 'outline'}
                size="sm"
              >
                {range === '1d' ? 'Today' : 
                 range === '7d' ? '7 Days' : 
                 range === '30d' ? '30 Days' : '90 Days'}
              </Button>
            ))}
          </div>
        </div>

        {/* Analytics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {analyticsCards.map((card) => {
            const IconComponent = card.icon
            return (
              <Card key={card.title} className="hover:shadow-lg transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between mb-4">
                    <div className={`w-12 h-12 rounded-lg flex items-center justify-center bg-${card.color}-100`}>
                      <IconComponent className={`h-6 w-6 text-${card.color}-600`} />
                    </div>
                    <div className="flex items-center space-x-1">
                      {getTrendIcon(card.trendDirection)}
                      <span className={`text-sm font-medium ${getTrendColor(card.trendDirection)}`}>
                        {card.trend}
                      </span>
                    </div>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-500">{card.title}</p>
                    <p className="text-2xl font-bold text-gray-900">{card.value}</p>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Detailed Analytics */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Pickup Analytics */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <TruckIcon className="h-5 w-5 mr-2" />
                Pickup Request Analytics
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Pending Pickups</span>
                  <span className="text-lg font-semibold">{currentStats.pendingPickups || 0}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Completed Pickups</span>
                  <span className="text-lg font-semibold">{currentStats.completedPickups || 0}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Total Pickups</span>
                  <span className="text-lg font-semibold">{currentStats.totalPickups || 0}</span>
                </div>
                {currentStats.recentPickups && currentStats.recentPickups.length > 0 && (
                  <div className="mt-4">
                    <h4 className="text-sm font-medium text-gray-900 mb-2">Recent Activity</h4>
                    <div className="space-y-2">
                      {currentStats.recentPickups.slice(0, 3).map((pickup) => (
                        <div key={pickup.id} className="flex justify-between items-center text-sm">
                          <span className="text-gray-600">
                            Pickup #{pickup.id?.slice(-6) || 'N/A'}
                          </span>
                          <span className="text-gray-900">
                            {pickup.status || 'Pending'}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* System Status */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <ChartBarIcon className="h-5 w-5 mr-2" />
                System Performance
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Data Source</span>
                  <span className="text-sm font-medium text-green-600">
                    {realtimeStats.totalUsers > 0 ? 'Real-time' : 'Regular'}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Last Updated</span>
                  <span className="text-sm font-medium">
                    {new Date().toLocaleTimeString()}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Connection Status</span>
                  <span className="text-sm font-medium text-green-600">
                    Connected
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Data Freshness</span>
                  <span className="text-sm font-medium text-green-600">
                    Live
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Additional Analytics Sections */}
        <div className="mt-8">
          <Card>
            <CardHeader>
              <CardTitle>Data Flow Information</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-sm">
                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Flutter App → Firebase</h4>
                  <p className="text-gray-600">
                    Data is sent from your Flutter app to Firebase Firestore in real-time.
                  </p>
                </div>
                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Firebase → Web Dashboard</h4>
                  <p className="text-gray-600">
                    This dashboard listens to Firebase changes and updates automatically.
                  </p>
                </div>
                <div>
                  <h4 className="font-medium text-gray-900 mb-2">Real-time Updates</h4>
                  <p className="text-gray-600">
                    Changes in your Flutter app will appear here instantly without refreshing.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
} 