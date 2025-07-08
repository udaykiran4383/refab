'use client'

import React from 'react'
import { Users, ShoppingCart, Truck, Clock } from 'lucide-react'

export default function RecentActivity({ activities }) {
  const getActivityIcon = (type) => {
    switch (type) {
      case 'user':
        return Users
      case 'order':
        return ShoppingCart
      case 'pickup':
        return Truck
      default:
        return Clock
    }
  }

  const getActivityColor = (type) => {
    switch (type) {
      case 'user':
        return 'text-blue-600 bg-blue-100'
      case 'order':
        return 'text-purple-600 bg-purple-100'
      case 'pickup':
        return 'text-orange-600 bg-orange-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  const getActivityTitle = (activity) => {
    switch (activity.type) {
      case 'user':
        return `New user registered: ${activity.data.name || activity.data.email}`
      case 'order':
        return `New order placed: ₹${activity.data.totalAmount || 0}`
      case 'pickup':
        return `New pickup request: ${activity.data.customer_name || 'Unknown customer'}`
      default:
        return 'Unknown activity'
    }
  }

  const formatTime = (timestamp) => {
    if (!timestamp) return 'Unknown time'
    
    try {
      const date = new Date(timestamp)
      const now = new Date()
      const diffInMinutes = Math.floor((now - date) / (1000 * 60))
      
      if (diffInMinutes < 1) return 'Just now'
      if (diffInMinutes < 60) return `${diffInMinutes}m ago`
      if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)}h ago`
      return `${Math.floor(diffInMinutes / 1440)}d ago`
    } catch (error) {
      return 'Unknown time'
    }
  }

  return (
    <div className="bg-white shadow rounded-lg">
      <div className="px-4 py-5 sm:p-6">
        <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">Recent Activity</h3>
        <div className="flow-root">
          <ul className="-mb-8">
            {activities.map((activity, activityIdx) => (
              <li key={activity.id}>
                <div className="relative pb-8">
                  {activityIdx !== activities.length - 1 ? (
                    <span
                      className="absolute top-4 left-4 -ml-px h-full w-0.5 bg-gray-200"
                      aria-hidden="true"
                    />
                  ) : null}
                  <div className="relative flex space-x-3">
                    <div>
                                             <span className={`h-8 w-8 rounded-full flex items-center justify-center ring-8 ring-white ${getActivityColor(activity.type)}`}>
                         {(() => {
                           const IconComponent = getActivityIcon(activity.type);
                           return <IconComponent className="h-5 w-5" />;
                         })()}
                       </span>
                    </div>
                    <div className="min-w-0 flex-1 pt-1.5 flex justify-between space-x-4">
                      <div>
                        <p className="text-sm text-gray-500">
                          {getActivityTitle(activity)}
                        </p>
                      </div>
                      <div className="text-right text-sm whitespace-nowrap text-gray-500">
                        <time dateTime={activity.timestamp}>
                          {formatTime(activity.timestamp)}
                        </time>
                      </div>
                    </div>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  )
} 