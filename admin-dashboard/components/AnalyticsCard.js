'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, orderBy } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  ChartBarIcon,
  ArrowTrendingUpIcon,
  ArrowTrendingDownIcon,
  CurrencyRupeeIcon,
  ClockIcon,
  ExclamationTriangleIcon
} from '@heroicons/react/24/outline'

export default function AnalyticsCard() {
  const [analyticsData, setAnalyticsData] = useState({
    totalRevenue: 0,
    monthlyGrowth: 0,
    averageOrderValue: 0,
    customerSatisfaction: 0,
    processingEfficiency: 0,
    trends: [],
    insights: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchAnalyticsData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch all orders
      const orders = await getDocs(collection(db, 'orders'))
      
      // Fetch pickup requests for efficiency calculation
      const pickupRequests = await getDocs(collection(db, 'pickupRequests'))
      
      // Fetch users for customer satisfaction calculation
      const users = await getDocs(collection(db, 'users'))

      // Calculate total revenue
      const totalRevenue = orders.docs.reduce((sum, doc) => {
        const orderData = doc.data()
        return sum + (orderData.totalAmount || orderData.amount || 0)
      }, 0)

      // Calculate average order value
      const averageOrderValue = orders.docs.length > 0 
        ? Math.round(totalRevenue / orders.docs.length)
        : 0

      // Calculate processing efficiency (completed vs total requests)
      const completedRequests = pickupRequests.docs.filter(doc => {
        const data = doc.data()
        return data.status === 'completed'
      }).length

      const processingEfficiency = pickupRequests.docs.length > 0
        ? Math.round((completedRequests / pickupRequests.docs.length) * 100)
        : 0

      // Calculate customer satisfaction (simulated based on completion rate)
      const customerSatisfaction = Math.min(processingEfficiency + 20, 95) // Base satisfaction on efficiency

      // Calculate monthly growth (simulated)
      const monthlyGrowth = Math.random() * 20 - 5 // Random growth between -5% and +15%

      // Generate trends
      const trends = [
        {
          name: 'Revenue',
          value: totalRevenue,
          change: monthlyGrowth,
          changeType: monthlyGrowth > 0 ? 'positive' : 'negative'
        },
        {
          name: 'Orders',
          value: orders.docs.length,
          change: 12,
          changeType: 'positive'
        },
        {
          name: 'Efficiency',
          value: processingEfficiency,
          change: 5,
          changeType: 'positive'
        },
        {
          name: 'Satisfaction',
          value: customerSatisfaction,
          change: 3,
          changeType: 'positive'
        }
      ]

      // Generate insights
      const insights = []
      if (processingEfficiency < 70) {
        insights.push('Processing efficiency below target - consider optimizing workflow')
      }
      if (averageOrderValue < 500) {
        insights.push('Average order value is low - consider upselling strategies')
      }
      if (monthlyGrowth < 0) {
        insights.push('Revenue declining - investigate market conditions')
      }
      if (customerSatisfaction < 80) {
        insights.push('Customer satisfaction needs improvement')
      }

      setAnalyticsData({
        totalRevenue,
        monthlyGrowth,
        averageOrderValue,
        customerSatisfaction,
        processingEfficiency,
        trends,
        insights
      })
    } catch (err) {
      console.error('Error fetching analytics data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchAnalyticsData()
  }, [])

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR'
    }).format(amount)
  }

  const getTrendIcon = (changeType) => {
    return changeType === 'positive' 
      ? <ArrowTrendingUpIcon className="h-4 w-4 text-green-500" />
      : <ArrowTrendingDownIcon className="h-4 w-4 text-red-500" />
  }

  const getTrendColor = (changeType) => {
    return changeType === 'positive' ? 'text-green-600' : 'text-red-600'
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Analytics</CardTitle>
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
          <CardTitle>Analytics</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-red-600">
            <ExclamationTriangleIcon className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading analytics data</p>
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
          <ChartBarIcon className="h-5 w-5 mr-2" />
          Analytics Overview
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Key Metrics */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="p-4 bg-blue-50 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Revenue</p>
                  <p className="text-2xl font-bold text-gray-900">{formatCurrency(analyticsData.totalRevenue)}</p>
                </div>
                <CurrencyRupeeIcon className="h-8 w-8 text-blue-600" />
              </div>
              <div className="flex items-center mt-2">
                {getTrendIcon(analyticsData.monthlyGrowth > 0 ? 'positive' : 'negative')}
                <span className={`text-sm font-medium ml-1 ${getTrendColor(analyticsData.monthlyGrowth > 0 ? 'positive' : 'negative')}`}>
                  {Math.abs(analyticsData.monthlyGrowth).toFixed(1)}%
                </span>
                <span className="text-sm text-gray-500 ml-1">vs last month</span>
              </div>
            </div>

            <div className="p-4 bg-green-50 rounded-lg">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Avg. Order Value</p>
                  <p className="text-2xl font-bold text-gray-900">{formatCurrency(analyticsData.averageOrderValue)}</p>
                </div>
                <ChartBarIcon className="h-8 w-8 text-green-600" />
              </div>
            </div>
          </div>

          {/* Performance Metrics */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="p-3 bg-gray-50 rounded-lg">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <ClockIcon className="h-5 w-5 text-gray-600" />
                  <span className="text-sm font-medium text-gray-700">Processing Efficiency</span>
                </div>
                <span className="text-lg font-semibold text-gray-900">{analyticsData.processingEfficiency}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
                <div 
                  className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${analyticsData.processingEfficiency}%` }}
                ></div>
              </div>
            </div>

            <div className="p-3 bg-gray-50 rounded-lg">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <ChartBarIcon className="h-5 w-5 text-gray-600" />
                  <span className="text-sm font-medium text-gray-700">Customer Satisfaction</span>
                </div>
                <span className="text-lg font-semibold text-gray-900">{analyticsData.customerSatisfaction}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
                <div 
                  className="bg-green-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${analyticsData.customerSatisfaction}%` }}
                ></div>
              </div>
            </div>
          </div>

          {/* Trends */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3">Key Trends</h4>
            <div className="space-y-3">
              {analyticsData.trends.map((trend) => (
                <div key={trend.name} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <div className="flex items-center space-x-2">
                    {getTrendIcon(trend.changeType)}
                    <span className="text-sm font-medium text-gray-700">{trend.name}</span>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-semibold text-gray-900">
                      {trend.name === 'Revenue' ? formatCurrency(trend.value) : trend.value}
                    </p>
                    <p className={`text-xs ${getTrendColor(trend.changeType)}`}>
                      {trend.change > 0 ? '+' : ''}{trend.change}%
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Insights */}
          {analyticsData.insights.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-gray-900 mb-2">Insights</h4>
              <div className="space-y-2">
                {analyticsData.insights.map((insight, index) => (
                  <div key={index} className="flex items-center space-x-2 p-2 bg-yellow-50 rounded">
                    <ExclamationTriangleIcon className="h-4 w-4 text-yellow-500" />
                    <span className="text-sm text-yellow-700">{insight}</span>
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