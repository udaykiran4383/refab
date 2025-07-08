'use client'

import { useState, useEffect } from 'react'
import { useProducts } from '../../lib/hooks/useFirebase'
import { Card, CardHeader, CardTitle, CardContent } from '../../components/ui/Card'
import Button from '../../components/ui/Button'
import { 
  CubeIcon, 
  ExclamationTriangleIcon,
  ArrowLeftIcon,
  EyeIcon,
  EyeSlashIcon,
  TagIcon
} from '@heroicons/react/24/outline'
import { formatDistanceToNow } from 'date-fns'
import toast from 'react-hot-toast'

export default function ProductsPage() {
  const { data: products, loading, error, fetchData } = useProducts()
  const [showDebug, setShowDebug] = useState(false)
  const [filter, setFilter] = useState('all')

  const filteredProducts = products.filter(product => {
    if (filter === 'all') return true
    return product.category?.toLowerCase() === filter.toLowerCase()
  })

  // Debug logging
  useEffect(() => {
    console.log('🔍 Products Page Debug Info:')
    console.log('📦 Total products:', products.length)
    console.log('🔄 Loading state:', loading)
    console.log('❌ Error state:', error)
    console.log('📋 Products data:', products)
    
    if (products.length > 0) {
      console.log('📋 Sample product structure:', products[0])
    }
  }, [products, loading, error])

  const getCategoryColor = (category) => {
    switch (category?.toLowerCase()) {
      case 'clothing':
        return 'text-blue-600 bg-blue-100'
      case 'accessories':
        return 'text-purple-600 bg-purple-100'
      case 'shoes':
        return 'text-green-600 bg-green-100'
      case 'bags':
        return 'text-orange-600 bg-orange-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case 'available':
        return 'text-green-600 bg-green-100'
      case 'out_of_stock':
      case 'out of stock':
        return 'text-red-600 bg-red-100'
      case 'pending':
        return 'text-yellow-600 bg-yellow-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading products...</p>
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
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Error Loading Products</h1>
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
                <h1 className="text-3xl font-bold text-gray-900">Products Management</h1>
                <p className="text-gray-600">Manage and monitor product inventory</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <CubeIcon className="h-5 w-5 text-green-500" />
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
                  <strong>Total Products:</strong> {products.length}
                </div>
                <div>
                  <strong>Loading:</strong> {loading ? 'Yes' : 'No'}
                </div>
                <div>
                  <strong>Error:</strong> {error ? 'Yes' : 'No'}
                </div>
              </div>
              <div className="mt-4">
                <strong>Raw Data (first 3 products):</strong>
                <pre className="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto max-h-40">
                  {JSON.stringify(products.slice(0, 3), null, 2)}
                </pre>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Filters */}
        <div className="mb-6">
          <div className="flex space-x-2">
            {['all', 'clothing', 'accessories', 'shoes', 'bags'].map((category) => (
              <Button
                key={category}
                onClick={() => setFilter(category)}
                variant={filter === category ? 'primary' : 'outline'}
                size="sm"
              >
                {category.charAt(0).toUpperCase() + category.slice(1)}
                {category !== 'all' && (
                  <span className="ml-2 bg-white bg-opacity-20 px-2 py-0.5 rounded-full text-xs">
                    {products.filter(p => p.category?.toLowerCase() === category.toLowerCase()).length}
                  </span>
                )}
              </Button>
            ))}
          </div>
        </div>

        {/* Products Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredProducts.length > 0 ? (
            filteredProducts.map((product) => (
              <Card key={product.id} className="hover:shadow-lg transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between mb-3">
                    <CubeIcon className="h-6 w-6 text-gray-400" />
                    <div className="flex space-x-2">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getCategoryColor(product.category)}`}>
                        {product.category || 'Uncategorized'}
                      </span>
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(product.status)}`}>
                        {product.status || 'Unknown'}
                      </span>
                    </div>
                  </div>
                  
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">
                    {product.name || product.title || 'Unnamed Product'}
                  </h3>
                  
                  <div className="space-y-2 text-sm">
                    <p className="text-gray-600">
                      <strong>Price:</strong> ${product.price || product.cost || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <strong>Quantity:</strong> {product.quantity || product.stock || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <strong>Brand:</strong> {product.brand || 'N/A'}
                    </p>
                    <p className="text-gray-600">
                      <strong>SKU:</strong> {product.sku || product.id || 'N/A'}
                    </p>
                    {product.description && (
                      <p className="text-gray-600">
                        <strong>Description:</strong> {product.description}
                      </p>
                    )}
                    <p className="text-gray-600">
                      <strong>Added:</strong> {product.createdAt ? formatDistanceToNow(product.createdAt.toDate(), { addSuffix: true }) : 'N/A'}
                    </p>
                  </div>

                  {showDebug && (
                    <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                      <p className="text-xs text-gray-700">
                        <strong>Product ID:</strong> {product.id}
                      </p>
                      <p className="text-xs text-gray-700">
                        <strong>Raw Data:</strong> {JSON.stringify(product, null, 2)}
                      </p>
                    </div>
                  )}
                </CardContent>
              </Card>
            ))
          ) : (
            <div className="col-span-full">
              <Card>
                <CardContent className="p-12 text-center">
                  <CubeIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">No products found</h3>
                  <p className="text-gray-500">
                    {filter === 'all' 
                      ? 'No products have been added yet.' 
                      : `No products in category "${filter}" found.`
                    }
                  </p>
                </CardContent>
              </Card>
            </div>
          )}
        </div>
      </div>
    </div>
  )
} 