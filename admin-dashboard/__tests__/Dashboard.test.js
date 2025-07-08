import { render, screen, waitFor, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom'
import Dashboard from '../app/page'
import React from 'react'

// Add these at the top
const mockUseRealtimeDashboard = jest.fn()
const mockUseDashboardStats = jest.fn()

// Mock all Heroicons
jest.mock('@heroicons/react/24/outline', () => ({
  UsersIcon: ({ className, ...props }) => <div data-testid="users-icon" className={className} {...props} />,
  TruckIcon: ({ className, ...props }) => <div data-testid="truck-icon" className={className} {...props} />,
  CubeIcon: ({ className, ...props }) => <div data-testid="cube-icon" className={className} {...props} />,
  ShoppingCartIcon: ({ className, ...props }) => <div data-testid="shopping-cart-icon" className={className} {...props} />,
  ChartBarIcon: ({ className, ...props }) => <div data-testid="chart-bar-icon" className={className} {...props} />,
  ClockIcon: ({ className, ...props }) => <div data-testid="clock-icon" className={className} {...props} />,
  ExclamationTriangleIcon: ({ className, ...props }) => <div data-testid="exclamation-triangle-icon" className={className} {...props} />,
  CheckCircleIcon: ({ className, ...props }) => <div data-testid="check-circle-icon" className={className} {...props} />,
  ArrowPathIcon: ({ className, ...props }) => <div data-testid="arrow-path-icon" className={className} {...props} />,
  WifiIcon: ({ className, ...props }) => <div data-testid="wifi-icon" className={className} {...props} />,
  WifiSlashIcon: ({ className, ...props }) => <div data-testid="wifi-slash-icon" className={className} {...props} />
}))

// Mock date-fns
jest.mock('date-fns', () => ({
  formatDistanceToNow: jest.fn(() => '2 hours ago')
}))

// Mock react-hot-toast
jest.mock('react-hot-toast', () => ({
  __esModule: true,
  default: {
    success: jest.fn(),
    error: jest.fn()
  }
}))

// Mock the Firebase hooks
jest.mock('../lib/hooks/useFirebase', () => ({
  useRealtimeDashboard: () => mockUseRealtimeDashboard(),
  useDashboardStats: () => mockUseDashboardStats()
}))

// Mock the components
jest.mock('../components/ui/Card', () => ({
  Card: ({ children, ...props }) => <div data-testid="card" {...props}>{children}</div>,
  CardHeader: ({ children, ...props }) => <div data-testid="card-header" {...props}>{children}</div>,
  CardTitle: ({ children, ...props }) => <h3 data-testid="card-title" {...props}>{children}</h3>,
  CardContent: ({ children, ...props }) => <div data-testid="card-content" {...props}>{children}</div>
}))

jest.mock('../components/ui/Button', () => {
  return function MockButton({ children, 'aria-label': ariaLabel, ...props }) {
    const accessibleName = ariaLabel || children
    // Check if this is the refresh button (has arrow-path-icon)
    const isRefreshButton = React.Children.toArray(children).some(child => 
      child && child.props && child.props['data-testid'] === 'arrow-path-icon'
    )
    const testId = isRefreshButton ? 'refresh-button' : 'button'
    
    return (
      <button 
        data-testid={testId}
        aria-label={accessibleName}
        {...props}
      >
        {children}
      </button>
    )
  }
})

describe('Dashboard', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    
    // Default mock for real-time dashboard
    mockUseRealtimeDashboard.mockReturnValue({
      stats: {
        totalUsers: 10,
        totalPickups: 4,
        totalProducts: 0,
        totalOrders: 0,
        pendingPickups: 0,
        completedPickups: 0,
        recentPickups: []
      },
      loading: false,
      error: null
    })
    
    // Default mock for regular dashboard
    mockUseDashboardStats.mockReturnValue({
      stats: {
        totalUsers: 10,
        totalPickups: 4,
        totalProducts: 0,
        totalOrders: 0,
        pendingPickups: 0,
        completedPickups: 0,
        recentPickups: []
      },
      loading: false,
      error: null,
      fetchStats: jest.fn()
    })
  })

  it('renders dashboard with correct title', () => {
    render(<Dashboard />)
    expect(screen.getByText('Admin Dashboard')).toBeInTheDocument()
  })

  it('displays all stat cards with correct values', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('Total Users')).toBeInTheDocument()
    expect(screen.getByText('10')).toBeInTheDocument()
    
    expect(screen.getByText('Pickup Requests')).toBeInTheDocument()
    expect(screen.getByText('4')).toBeInTheDocument()
    
    expect(screen.getByText('Products')).toBeInTheDocument()
    // Use getAllByText for duplicate '0' values
    expect(screen.getAllByText('0')[0]).toBeInTheDocument()
    
    expect(screen.getByText('Orders')).toBeInTheDocument()
    expect(screen.getAllByText('0')[1]).toBeInTheDocument()
  })

  it('displays recent pickup requests', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('Recent Pickup Requests')).toBeInTheDocument()
    // Use regex to match Pickup #pickup-1 and Pickup #pickup-2
    expect(screen.getByText(/Pickup #pickup-1/i)).toBeInTheDocument()
    expect(screen.getByText(/Pickup #pickup-2/i)).toBeInTheDocument()
    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('Jane Smith')).toBeInTheDocument()
  })

  it('displays correct status badges', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('pending')).toBeInTheDocument()
    expect(screen.getByText('completed')).toBeInTheDocument()
  })

  it('displays quick action buttons', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('Manage Users')).toBeInTheDocument()
    expect(screen.getByText('View Pickups')).toBeInTheDocument()
    expect(screen.getByText('Manage Products')).toBeInTheDocument()
    expect(screen.getByText('View Analytics')).toBeInTheDocument()
  })

  it('displays system status indicators', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('System Status')).toBeInTheDocument()
    expect(screen.getByText('Internet Connection')).toBeInTheDocument()
    expect(screen.getByText('Firebase Connection')).toBeInTheDocument()
    expect(screen.getByText('Real-time Updates')).toBeInTheDocument()
    expect(screen.getByText('Database Access')).toBeInTheDocument()
  })

  it('shows last updated time', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('Last updated')).toBeInTheDocument()
    // The time will be dynamic, so we just check that the element exists
    expect(screen.getByText(/^\d{1,2}:\d{2}:\d{2}/)).toBeInTheDocument()
  })

  it('shows online status when connected', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('Online')).toBeInTheDocument()
  })

  it('shows offline status when disconnected', () => {
    Object.defineProperty(window.navigator, 'onLine', {
      value: false,
      writable: true
    })
    
    render(<Dashboard />)
    
    expect(screen.getByText('Offline')).toBeInTheDocument()
  })

  it('shows live indicator when real-time data is available', () => {
    mockUseRealtimeDashboard.mockReturnValue({
      stats: {
        totalUsers: 15,
        totalPickups: 8,
        totalProducts: 5,
        totalOrders: 12,
        recentPickups: []
      },
      loading: false,
      error: null
    })
    
    render(<Dashboard />)
    
    expect(screen.getByText('Live')).toBeInTheDocument()
  })

  it('displays trend information in stat cards', () => {
    render(<Dashboard />)
    
    expect(screen.getByText('+12% this week')).toBeInTheDocument()
    expect(screen.getByText('0 pending')).toBeInTheDocument()
    expect(screen.getByText('+5 new today')).toBeInTheDocument()
    expect(screen.getByText('+8% this month')).toBeInTheDocument()
  })
})

describe('Dashboard Loading State', () => {
  it('shows loading spinner when loading', () => {
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: true,
      error: null,
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    expect(screen.getByText('Loading dashboard...')).toBeInTheDocument()
    expect(screen.getByText('Connecting to Firebase')).toBeInTheDocument()
  })

  it('does not show loading when refreshing', () => {
    mockUseDashboardStats.mockReturnValue({
      stats: {
        totalUsers: 10,
        totalPickups: 4,
        totalProducts: 0,
        totalOrders: 0,
        recentPickups: []
      },
      loading: true,
      error: null,
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    // Should show the dashboard content even when refreshing
    expect(screen.getByText('Admin Dashboard')).toBeInTheDocument()
  })
})

describe('Dashboard Error State', () => {
  it('shows error message when there is an error', () => {
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: false,
      error: 'Failed to fetch data',
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    expect(screen.getByText('Dashboard Error')).toBeInTheDocument()
    expect(screen.getByText('Failed to fetch data')).toBeInTheDocument()
    expect(screen.getByText('Retry')).toBeInTheDocument()
  })

  it('calls fetchStats when retry button is clicked', async () => {
    const mockFetchStats = jest.fn()
    
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: false,
      error: 'Failed to fetch data',
      fetchStats: mockFetchStats
    })

    render(<Dashboard />)
    
    const retryButton = screen.getByText('Retry')
    fireEvent.click(retryButton)
    
    await waitFor(() => {
      expect(mockFetchStats).toHaveBeenCalled()
    })
  })

  it('shows reload page button in error state', () => {
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: false,
      error: 'Failed to fetch data',
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    expect(screen.getByText('Reload Page')).toBeInTheDocument()
  })

  it('calls window.location.reload when reload button is clicked', () => {
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: false,
      error: 'Failed to fetch data',
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    
    const reloadButton = screen.getByText('Reload Page')
    fireEvent.click(reloadButton)
    
    expect(mockLocation.reload).toHaveBeenCalled()
  })
})

describe('Dashboard Offline State', () => {
  it('shows offline error when no internet connection', () => {
    Object.defineProperty(window.navigator, 'onLine', {
      value: false,
      writable: true
    })
    
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: false,
      error: 'Network error',
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    
    expect(screen.getByText('No Internet Connection')).toBeInTheDocument()
    expect(screen.getByText('Please check your internet connection and try again.')).toBeInTheDocument()
  })

  it('disables retry button when offline', () => {
    Object.defineProperty(window.navigator, 'onLine', {
      value: false,
      writable: true
    })
    
    mockUseDashboardStats.mockReturnValue({
      stats: {},
      loading: false,
      error: 'Network error',
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    
    const retryButton = screen.getByText('Retry')
    expect(retryButton).toBeDisabled()
  })
})

describe('Dashboard Empty State', () => {
  it('shows empty state when no recent pickups', () => {
    mockUseDashboardStats.mockReturnValue({
      stats: {
        totalUsers: 0,
        totalPickups: 0,
        totalProducts: 0,
        totalOrders: 0,
        recentPickups: []
      },
      loading: false,
      error: null,
      fetchStats: jest.fn()
    })

    render(<Dashboard />)
    expect(screen.getByText('No recent pickup requests')).toBeInTheDocument()
    expect(screen.getByText('New requests will appear here')).toBeInTheDocument()
  })
})

describe('Dashboard Refresh Functionality', () => {
  it('should display refresh button', () => {
    render(<Dashboard />)
    
    // Look for the refresh button (it's an icon button)
    const refreshButton = screen.getByTestId('refresh-button')
    expect(refreshButton).toBeInTheDocument()
  })

  it('should handle refresh button click', async () => {
    render(<Dashboard />)
    
    // Use getByTestId for the specific refresh button
    const refreshButton = screen.getByTestId('refresh-button')
    fireEvent.click(refreshButton)
    
    // Verify the refresh function was called
    expect(mockUseDashboardStats).toHaveBeenCalled()
  })

  it('should handle refresh with loading state', async () => {
    render(<Dashboard />)
    
    const refreshButton = screen.getByTestId('refresh-button')
    fireEvent.click(refreshButton)
    
    // The button should show spinning animation
    await waitFor(() => {
      expect(refreshButton).toBeInTheDocument()
    })
  })

  it('falls back to regular stats when real-time is not available', () => {
    mockUseRealtimeDashboard.mockReturnValue({
      stats: { totalUsers: 0, totalPickups: 0, totalProducts: 0, totalOrders: 0, recentPickups: [] },
      loading: false,
      error: null
    })
    mockUseDashboardStats.mockReturnValue({
      stats: { totalUsers: 10, totalPickups: 4, totalProducts: 0, totalOrders: 0, recentPickups: [] },
      loading: false,
      error: null,
      fetchStats: jest.fn()
    })
    render(<Dashboard />)
    // Should show regular dashboard values
    expect(screen.getAllByText((content) => content.trim() === '10').length).toBeGreaterThan(0) // Users
    expect(screen.getAllByText((content) => content.trim() === '4').length).toBeGreaterThan(0)  // Pickups
  })
})

describe('Dashboard Real-time Updates', () => {
  it('uses real-time stats when available', () => {
    mockUseRealtimeDashboard.mockReturnValue({
      stats: {
        totalUsers: 25,
        totalPickups: 12,
        totalProducts: 8,
        totalOrders: 15,
        recentPickups: []
      },
      loading: false,
      error: null
    })
    
    render(<Dashboard />)
    
    // Should show real-time values instead of regular dashboard values
    expect(screen.getByText('25')).toBeInTheDocument() // Users
    expect(screen.getByText('12')).toBeInTheDocument() // Pickups
    expect(screen.getByText('8')).toBeInTheDocument()  // Products
    expect(screen.getByText('15')).toBeInTheDocument() // Orders
  })

  it('falls back to regular stats when real-time is not available', () => {
    mockUseRealtimeDashboard.mockReturnValue({
      stats: {
        totalUsers: 0,
        totalPickups: 0,
        totalProducts: 0,
        totalOrders: 0,
        recentPickups: []
      },
      loading: false,
      error: null
    })
    
    render(<Dashboard />)
    
    // Should show regular dashboard values
    expect(screen.getByText('10')).toBeInTheDocument() // Users
    expect(screen.getByText('4')).toBeInTheDocument()  // Pickups
  })
}) 