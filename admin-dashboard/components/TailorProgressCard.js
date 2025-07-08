'use client'

import { useState, useEffect } from 'react'
import { collection, getDocs, query, where, orderBy } from 'firebase/firestore'
import { db } from '../lib/firebase'
import { Card, CardHeader, CardTitle, CardContent } from './ui/Card'
import { 
  ScissorsIcon,
  UserIcon,
  ClockIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ChartBarIcon
} from '@heroicons/react/24/outline'

export default function TailorProgressCard() {
  const [tailorData, setTailorData] = useState({
    totalTailors: 0,
    activeTailors: 0,
    totalAssignments: 0,
    completedToday: 0,
    averageCompletionTime: 0,
    assignments: [],
    bottlenecks: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const fetchTailorData = async () => {
    try {
      setLoading(true)
      setError(null)

      // Fetch tailors
      const tailors = await getDocs(collection(db, 'users'))
      const tailorUsers = tailors.docs.filter(doc => {
        const userData = doc.data()
        return userData.role === 'tailor' || userData.userType === 'tailor'
      })

      // Fetch tailoring assignments
      const tailoringRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'in_tailoring')
      ))

      // Fetch completed requests from today
      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const completedRequests = await getDocs(query(
        collection(db, 'pickupRequests'),
        where('status', '==', 'completed')
      ))

      const completedToday = completedRequests.docs.filter(doc => {
        const data = doc.data()
        const completedAt = data.completedAt?.toDate?.() || data.completed_at?.toDate?.() || new Date(0)
        return completedAt >= today
      }).length

      // Calculate average completion time
      const completionTimes = completedRequests.docs.map(doc => {
        const data = doc.data()
        const createdAt = data.createdAt?.toDate?.() || data.created_at?.toDate?.() || new Date(0)
        const completedAt = data.completedAt?.toDate?.() || data.completed_at?.toDate?.() || new Date(0)
        return (completedAt - createdAt) / (1000 * 60 * 60) // hours
      }).filter(time => time > 0)

      const averageCompletionTime = completionTimes.length > 0 
        ? Math.round(completionTimes.reduce((a, b) => a + b, 0) / completionTimes.length)
        : 0

      // Identify bottlenecks
      const bottlenecks = []
      if (tailoringRequests.docs.length > tailorUsers.length * 3) {
        bottlenecks.push('High workload per tailor')
      }
      if (averageCompletionTime > 48) {
        bottlenecks.push('Slow completion times')
      }
      if (tailorUsers.length === 0) {
        bottlenecks.push('No tailors available')
      }

      setTailorData({
        totalTailors: tailorUsers.length,
        activeTailors: tailorUsers.filter(doc => {
          const userData = doc.data()
          const lastActive = userData.lastActive?.toDate?.() || userData.last_active?.toDate?.() || new Date(0)
          return (new Date() - lastActive) < 24 * 60 * 60 * 1000 // 24 hours
        }).length,
        totalAssignments: tailoringRequests.docs.length,
        completedToday,
        averageCompletionTime,
        assignments: tailoringRequests.docs.slice(0, 5).map(doc => ({
          id: doc.id,
          ...doc.data()
        })),
        bottlenecks
      })
    } catch (err) {
      console.error('Error fetching tailor data:', err)
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTailorData()
  }, [])

  const getProgressPercentage = (completed, total) => {
    if (total === 0) return 0
    return Math.round((completed / total) * 100)
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Tailor Progress</CardTitle>
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
          <CardTitle>Tailor Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-red-600">
            <ExclamationTriangleIcon className="h-8 w-8 mx-auto mb-2" />
            <p>Error loading tailor data</p>
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
          <ScissorsIcon className="h-5 w-5 mr-2" />
          Tailor Progress
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Key Metrics */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="text-center p-3 bg-purple-50 rounded-lg">
              <UserIcon className="h-6 w-6 text-purple-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{tailorData.totalTailors}</p>
              <p className="text-xs text-gray-500">Total Tailors</p>
            </div>
            <div className="text-center p-3 bg-green-50 rounded-lg">
              <UserIcon className="h-6 w-6 text-green-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{tailorData.activeTailors}</p>
              <p className="text-xs text-gray-500">Active</p>
            </div>
            <div className="text-center p-3 bg-blue-50 rounded-lg">
              <ClockIcon className="h-6 w-6 text-blue-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{tailorData.totalAssignments}</p>
              <p className="text-xs text-gray-500">Assignments</p>
            </div>
            <div className="text-center p-3 bg-emerald-50 rounded-lg">
              <CheckCircleIcon className="h-6 w-6 text-emerald-600 mx-auto mb-1" />
              <p className="text-lg font-semibold text-gray-900">{tailorData.completedToday}</p>
              <p className="text-xs text-gray-500">Today</p>
            </div>
          </div>

          {/* Progress Bar */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm font-medium text-gray-700">Completion Rate</span>
              <span className="text-sm text-gray-500">
                {getProgressPercentage(tailorData.completedToday, tailorData.totalAssignments)}%
              </span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-purple-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${getProgressPercentage(tailorData.completedToday, tailorData.totalAssignments)}%` }}
              ></div>
            </div>
          </div>

          {/* Average Completion Time */}
          <div className="p-3 bg-gray-50 rounded-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <ChartBarIcon className="h-5 w-5 text-gray-600" />
                <span className="text-sm font-medium text-gray-700">Avg. Completion Time</span>
              </div>
              <span className="text-lg font-semibold text-gray-900">{tailorData.averageCompletionTime}h</span>
            </div>
          </div>

          {/* Recent Assignments */}
          <div>
            <h4 className="text-sm font-medium text-gray-900 mb-3">Recent Assignments</h4>
            <div className="space-y-2">
              {tailorData.assignments.map((assignment) => (
                <div key={assignment.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <div className="flex items-center space-x-2">
                    <ClockIcon className="h-4 w-4 text-blue-500" />
                    <span className="text-sm text-gray-700">
                      {assignment.customerName || assignment.customer_name || 'Unknown Customer'}
                    </span>
                  </div>
                  <span className="text-xs text-gray-500">
                    #{assignment.id.slice(-6)}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Bottlenecks */}
          {tailorData.bottlenecks.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-gray-900 mb-2">Bottlenecks</h4>
              <div className="space-y-2">
                {tailorData.bottlenecks.map((bottleneck, index) => (
                  <div key={index} className="flex items-center space-x-2 p-2 bg-red-50 rounded">
                    <ExclamationTriangleIcon className="h-4 w-4 text-red-500" />
                    <span className="text-sm text-red-700">{bottleneck}</span>
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