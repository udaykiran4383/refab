'use client'

import { useState, useEffect } from 'react'
import { usePickupRequests } from '../../lib/hooks/useFirebase'
import { Card, CardHeader, CardTitle, CardContent } from '../../components/ui/Card'
import Button from '../../components/ui/Button'
import { 
  TruckIcon, 
  ClockIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ArrowLeftIcon
} from '@heroicons/react/24/outline'
import { formatDistanceToNow } from 'date-fns'
import toast from 'react-hot-toast'

export default function PickupsPage() {
  const { data: pickups, loading, error, fetchData } = usePickupRequests()
  const [filter, setFilter] = useState('all')

  const filteredPickups = pickups.filter(pickup => {
    if (filter === 'all') return true
    return pickup.status?.toLowerCase() === filter.toLowerCase()
  })

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

  const getStatusIcon = (status) => {
    switch (status?.toLowerCase()) {
      case 'pending':
        return <ClockIcon className="h-4 w-4" />
      case 'completed':
      case 'delivered':
        return <CheckCircleIcon className="h-4 w-4" />
      case 'cancelled':
        return <ExclamationTriangleIcon className="h-4 w-4" />
      default:
        return <TruckIcon className="h-4 w-4" />
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading pickup requests...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <ExclamationTriangleIcon className="h-16 w-16 text-red-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Error Loading Pickups</h1>
          <p className="text-gray-600 mb-4">{error}</p>
          <Button onClick={fetchData} variant="primary">
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
                <h1 className="text-3xl font-bold text-gray-900">Pickup Requests</h1>
                <p className="text-gray-600">Manage and monitor pickup requests</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <TruckIcon className="h-5 w-5 text-green-500" />
                <span className="text-sm text-green-600">Live Updates</span>
              </div>
              <Button onClick={fetchData} variant="outline" size="sm">
                Refresh
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Filters */}
        <div className="mb-6">
          <div className="flex space-x-2">
            {['all', 'pending', 'in_progress', 'completed', 'cancelled'].map((status) => (
              <Button
                key={status}
                onClick={() => setFilter(status)}
                variant={filter === status ? 'primary' : 'outline'}
                size="sm"
              >
                {status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' ')}
                {status !== 'all' && (
                  <span className="ml-2 bg-white bg-opacity-20 px-2 py-0.5 rounded-full text-xs">
                    {pickups.filter(p => p.status?.toLowerCase() === status.toLowerCase()).length}
                  </span>
                )}
              </Button>
            ))}
          </div>
        </div>

        {/* Pickup Requests */}
        <div className="grid gap-6">
          {filteredPickups.length > 0 ? (
            filteredPickups.map((pickup) => (
              <Card key={pickup.id} className="hover:shadow-lg transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <h3 className="text-lg font-semibold text-gray-900">
                          Pickup #{pickup.id?.slice(-6) || 'N/A'}
                        </h3>
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(pickup.status)}`}>
                          {getStatusIcon(pickup.status)}
                          <span className="ml-1">{pickup.status || 'Pending'}</span>
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                        <div>
                          <p className="text-gray-600">
                            <strong>Customer:</strong> {pickup.customerName || pickup.customer_name || pickup.customer?.name || 'Unknown'}
                          </p>
                          <p className="text-gray-600">
                            <strong>Phone:</strong> {pickup.customerPhone || pickup.customer_phone || pickup.customer?.phone || 'N/A'}
                          </p>
                          <p className="text-gray-600">
                            <strong>Address:</strong> {pickup.pickupAddress || pickup.pickup_address || 'N/A'}
                          </p>
                        </div>
                        <div>
                          <p className="text-gray-600">
                            <strong>Tailor:</strong> {pickup.tailorName || pickup.tailor_name || pickup.tailor?.name || 'Unassigned'}
                          </p>
                          <p className="text-gray-600">
                            <strong>Created:</strong> {pickup.createdAt ? formatDistanceToNow(pickup.createdAt.toDate(), { addSuffix: true }) : 'N/A'}
                          </p>
                          {pickup.updatedAt && (
                            <p className="text-gray-600">
                              <strong>Updated:</strong> {formatDistanceToNow(pickup.updatedAt.toDate(), { addSuffix: true })}
                            </p>
                          )}
                        </div>
                      </div>

                      {pickup.notes && (
                        <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                          <p className="text-sm text-gray-700">
                            <strong>Notes:</strong> {pickup.notes}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))
          ) : (
            <Card>
              <CardContent className="p-12 text-center">
                <TruckIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No pickup requests found</h3>
                <p className="text-gray-500">
                  {filter === 'all' 
                    ? 'No pickup requests have been created yet.' 
                    : `No pickup requests with status "${filter}" found.`
                  }
                </p>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </div>
  )
} 