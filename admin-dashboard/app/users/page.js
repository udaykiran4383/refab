'use client'

import { useState, useEffect } from 'react'
import { useUsers } from '../../lib/hooks/useFirebase'
import { Card, CardHeader, CardTitle, CardContent } from '../../components/ui/Card'
import Button from '../../components/ui/Button'
import { 
  UsersIcon, 
  UserIcon,
  ExclamationTriangleIcon,
  ArrowLeftIcon,
  EyeIcon,
  EyeSlashIcon
} from '@heroicons/react/24/outline'
import { formatDistanceToNow } from 'date-fns'
import toast from 'react-hot-toast'

export default function UsersPage() {
  const { data: users, loading, error, fetchData } = useUsers()
  const [showDebug, setShowDebug] = useState(false)
  const [filter, setFilter] = useState('all')

  const filteredUsers = users.filter(user => {
    if (filter === 'all') return true
    return user.role?.toLowerCase() === filter.toLowerCase()
  })

  // Debug logging
  useEffect(() => {
    console.log('🔍 Users Page Debug Info:')
    console.log('📊 Total users:', users.length)
    console.log('🔄 Loading state:', loading)
    console.log('❌ Error state:', error)
    console.log('👥 Users data:', users)
    
    if (users.length > 0) {
      console.log('📋 Sample user structure:', users[0])
    }
  }, [users, loading, error])

  const getRoleColor = (role) => {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'text-red-600 bg-red-100'
      case 'tailor':
        return 'text-blue-600 bg-blue-100'
      case 'customer':
        return 'text-green-600 bg-green-100'
      case 'volunteer':
        return 'text-purple-600 bg-purple-100'
      case 'warehouse':
        return 'text-orange-600 bg-orange-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading users...</p>
          <p className="text-sm text-gray-400 mt-2">Fetching from Firebase</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md">
          <ExclamationTriangleIcon className="h-16 w-16 text-red-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Error Loading Users</h1>
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
                <h1 className="text-3xl font-bold text-gray-900">Users Management</h1>
                <p className="text-gray-600">Manage and monitor user accounts</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <UsersIcon className="h-5 w-5 text-green-500" />
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
              <Button onClick={fetchData} variant="outline" size="sm">
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
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                <div>
                  <strong>Total Users:</strong> {users.length}
                </div>
                <div>
                  <strong>Loading:</strong> {loading ? 'Yes' : 'No'}
                </div>
                <div>
                  <strong>Error:</strong> {error ? 'Yes' : 'No'}
                </div>
              </div>
              <div className="mt-4">
                <strong>Raw Data (first 3 users):</strong>
                <pre className="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto max-h-40">
                  {JSON.stringify(users.slice(0, 3), null, 2)}
                </pre>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Filters */}
        <div className="mb-6">
          <div className="flex space-x-2">
            {['all', 'admin', 'tailor', 'customer', 'volunteer', 'warehouse'].map((role) => (
              <Button
                key={role}
                onClick={() => setFilter(role)}
                variant={filter === role ? 'primary' : 'outline'}
                size="sm"
              >
                {role.charAt(0).toUpperCase() + role.slice(1)}
                {role !== 'all' && (
                  <span className="ml-2 bg-white bg-opacity-20 px-2 py-0.5 rounded-full text-xs">
                    {users.filter(u => u.role?.toLowerCase() === role.toLowerCase()).length}
                  </span>
                )}
              </Button>
            ))}
          </div>
        </div>

        {/* Users List */}
        <div className="grid gap-6">
          {filteredUsers.length > 0 ? (
            filteredUsers.map((user) => (
              <Card key={user.id} className="hover:shadow-lg transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <UserIcon className="h-6 w-6 text-gray-400" />
                        <h3 className="text-lg font-semibold text-gray-900">
                          {user.name || user.displayName || user.email || 'Unknown User'}
                        </h3>
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getRoleColor(user.role)}`}>
                          {user.role || 'No Role'}
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                        <div>
                          <p className="text-gray-600">
                            <strong>Email:</strong> {user.email || 'N/A'}
                          </p>
                          <p className="text-gray-600">
                            <strong>Phone:</strong> {user.phone || user.phoneNumber || 'N/A'}
                          </p>
                          <p className="text-gray-600">
                            <strong>Location:</strong> {user.location || user.address || 'N/A'}
                          </p>
                        </div>
                        <div>
                          <p className="text-gray-600">
                            <strong>Status:</strong> {user.status || user.isActive ? 'Active' : 'Inactive'}
                          </p>
                          <p className="text-gray-600">
                            <strong>Created:</strong>{' '}
                            {(() => {
                              const val = user.createdAt || user.created_at;
                              if (!val) return 'N/A';
                              // Firestore Timestamp
                              if (val.toDate) {
                                try {
                                  return val.toDate().toLocaleString();
                                } catch (e) { /* fall through */ }
                              }
                              // ISO string or other string
                              if (typeof val === 'string') {
                                const d = new Date(val);
                                return isNaN(d) ? val : d.toLocaleString();
                              }
                              // JS Date
                              if (val instanceof Date) {
                                return val.toLocaleString();
                              }
                              // Fallback
                              return String(val);
                            })()}
                          </p>
                          {user.lastLoginAt && (
                            <p className="text-gray-600">
                              <strong>Last Login:</strong> {formatDistanceToNow(user.lastLoginAt.toDate(), { addSuffix: true })}
                            </p>
                          )}
                        </div>
                      </div>

                      {showDebug && (
                        <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                          <p className="text-xs text-gray-700">
                            <strong>User ID:</strong> {user.id}
                          </p>
                          <p className="text-xs text-gray-700">
                            <strong>Raw Data:</strong> {JSON.stringify(user, null, 2)}
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
                <UsersIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No users found</h3>
                <p className="text-gray-500">
                  {filter === 'all' 
                    ? 'No users have been registered yet.' 
                    : `No users with role "${filter}" found.`
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