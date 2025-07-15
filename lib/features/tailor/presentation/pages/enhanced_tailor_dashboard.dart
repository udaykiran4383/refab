import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/tailor_provider.dart';
import '../../data/models/pickup_request_model.dart';
import '../../data/models/tailor_analytics_model.dart';
import '../widgets/enhanced_pickup_request_card.dart';
import '../widgets/analytics_dashboard_card.dart';
import '../widgets/stats_card.dart';
import 'new_pickup_request_page.dart';

class EnhancedTailorDashboard extends ConsumerStatefulWidget {
  final UserModel user;

  const EnhancedTailorDashboard({super.key, required this.user});

  @override
  ConsumerState<EnhancedTailorDashboard> createState() => _EnhancedTailorDashboardState();
}

class _EnhancedTailorDashboardState extends ConsumerState<EnhancedTailorDashboard>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  int _selectedIndex = 0;
  String _selectedStatus = 'All';
  bool _showCompleted = true;

  final List<String> _statusFilters = ['All', 'Pending', 'Scheduled', 'In Progress', 'Picked Up', 'In Transit', 'Delivered', 'Completed', 'Cancelled', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tailorProvider.notifier).refreshData(widget.user.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔥 [TAILOR_DASHBOARD] Building dashboard for user: ${widget.user.id}');
    print('🔥 [TAILOR_DASHBOARD] User name: ${widget.user.name}');
    print('🔥 [TAILOR_DASHBOARD] User email: ${widget.user.email}');
    
    final tailorState = ref.watch(tailorProvider);
    final pickupRequests = ref.watch(pickupRequestsProvider(widget.user.id));
    final analytics = ref.watch(tailorAnalyticsProvider((
      tailorId: widget.user.id,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    )));


    // Debug logging for pickup requests
    pickupRequests.when(
      data: (requests) {
        print('🔥 [TAILOR_DASHBOARD] Pickup requests data: ${requests.length} requests');
        for (final request in requests) {
          print('🔥 [TAILOR_DASHBOARD] Request: ${request.id} - ${request.customerName} - ${request.fabricTypeDisplayName}');
        }
        return const SizedBox.shrink();
      },
      loading: () {
        print('🔥 [TAILOR_DASHBOARD] Pickup requests loading...');
        return const SizedBox.shrink();
      },
      error: (error, stack) {
        print('🔥 [TAILOR_DASHBOARD] Pickup requests error: $error');
        return const SizedBox.shrink();
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Tailor Dashboard - ${widget.user.name}'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Menu
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: Text('Analytics'),
              ),
              const PopupMenuItem(
                value: 'schedule',
                child: Text('Schedule'),
              ),
              const PopupMenuItem(
                value: 'customers',
                child: Text('Customers'),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Text('Help & Support'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) => _handleMenuSelection(value),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.list_alt), text: 'Requests'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Schedule'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(tailorState, pickupRequests, analytics),
          _buildRequestsTab(pickupRequests),
          _buildAnalyticsTab(analytics),
          _buildScheduleTab(),
          _buildCustomersTab(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewPickupRequestPage(user: widget.user),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ) : null,
    );
  }

  Widget _buildOverviewTab(TailorState tailorState, AsyncValue<List<PickupRequestModel>> pickupRequests, AsyncValue<TailorAnalyticsModel> analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${widget.user.name}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s your business overview for today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          pickupRequests.when(
            data: (requests) {
              final stats = _calculateStats(requests);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Requests',
                          value: '${stats['total']}',
                          icon: Icons.list_alt,
                          color: Colors.blue,
                          subtitle: 'All time',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'Completed',
                          value: '${stats['completed']}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                          subtitle: '${stats['completionRate']}% rate',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Pending',
                          value: '${stats['pending']}',
                          icon: Icons.schedule,
                          color: Colors.orange,
                          subtitle: 'Awaiting action',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: 'In Progress',
                          value: '${stats['inProgress']}',
                          icon: Icons.work,
                          color: Colors.indigo,
                          subtitle: 'Currently working',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading stats: $error'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Analytics Overview
          analytics.when(
            data: (analyticsData) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Analytics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                MiniAnalyticsCard(
                  analytics: analyticsData,
                  onTap: () => _navigateToAnalytics(),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading analytics: $error'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Recent Requests
          pickupRequests.when(
            data: (requests) {
              final recentRequests = requests.take(3).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _tabController.animateTo(1),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (recentRequests.isEmpty)
                    _buildEmptyState('No recent requests', Icons.inbox)
                  else
                    ...recentRequests.map((request) => EnhancedPickupRequestCard(
                      request: request,
                      showActions: false,
                      onTap: () => _showRequestDetails(request),
                    )),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading requests: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(AsyncValue<List<PickupRequestModel>> pickupRequests) {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search requests...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 12),
              
              // Status Filters
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length,
                  itemBuilder: (context, index) {
                    final status = _statusFilters[index];
                    final isSelected = status == _selectedStatus;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = status;
                          });
                          if (status != 'All') {
                            final pickupStatus = _getPickupStatusFromString(status);
                            ref.read(pickupRequestsFilterProvider.notifier).state = pickupStatus;
                          } else {
                            ref.read(pickupRequestsFilterProvider.notifier).state = null;
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Requests List
        Expanded(
          child: pickupRequests.when(
            data: (requests) {
              final filteredRequests = _filterRequests(requests);
              
              if (filteredRequests.isEmpty) {
                return _buildEmptyState('No requests found', Icons.inbox);
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(pickupRequestsProvider(widget.user.id));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return EnhancedPickupRequestCard(
                      request: request,
                      onTap: () => _showRequestDetails(request),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading requests: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(AsyncValue<TailorAnalyticsModel> analytics) {
    return analytics.when(
      data: (analyticsData) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnalyticsDashboardCard(
              analytics: analyticsData,
              onTap: () => _navigateToAnalytics(),
            ),
            const SizedBox(height: 24),
            _buildFabricTypeDistribution(analyticsData),
            const SizedBox(height: 24),
            _buildEarningsChart(analyticsData),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading analytics: $error'),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return const Center(child: Text('Schedule Page - Coming Soon'));
  }

  Widget _buildCustomersTab() {
    return const Center(child: Text('Customers Page - Coming Soon'));
  }



  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'New Pickup Request',
                'Schedule a new pickup',
                Icons.add_circle,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewPickupRequestPage(user: widget.user),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Analytics',
                'View performance data',
                Icons.analytics,
                Colors.purple,
                () => _tabController.animateTo(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Customers',
                'Manage customer data',
                Icons.people,
                Colors.orange,
                () => _tabController.animateTo(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabricTypeDistribution(TailorAnalyticsModel analytics) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fabric Type Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...analytics.fabricTypeDistribution.entries.map((entry) {
              final percentage = analytics.totalPickupRequests > 0 
                  ? (entry.value / analytics.totalPickupRequests * 100).toStringAsFixed(1)
                  : '0.0';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('$percentage%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: analytics.totalPickupRequests > 0 
                          ? entry.value / analytics.totalPickupRequests 
                          : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsChart(TailorAnalyticsModel analytics) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Earnings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (analytics.monthlyEarnings.isEmpty)
              _buildEmptyState('No earnings data available', Icons.bar_chart)
            else
              ...analytics.monthlyEarnings.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('₹${entry.value.toStringAsFixed(0)}'),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<PickupRequestModel> requests) {
    final total = requests.length;
    final pending = requests.where((r) => r.isPending).length;
    final inProgress = requests.where((r) => r.isInProgress).length;
    final completed = requests.where((r) => r.isCompleted).length;
    final completionRate = total > 0 ? (completed / total * 100).round() : 0;

    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'completionRate': completionRate,
    };
  }

  List<PickupRequestModel> _filterRequests(List<PickupRequestModel> requests) {
    if (_selectedStatus == 'All') {
      return requests;
    }
    
    final status = _getPickupStatusFromString(_selectedStatus);
    return requests.where((request) => request.status == status).toList();
  }

  PickupStatus _getPickupStatusFromString(String status) {
    switch (status) {
      case 'Pending':
        return PickupStatus.pending;
      case 'Scheduled':
        return PickupStatus.scheduled;
      case 'In Progress':
        return PickupStatus.inProgress;
      case 'Picked Up':
        return PickupStatus.pickedUp;
      case 'In Transit':
        return PickupStatus.inTransit;
      case 'Delivered':
        return PickupStatus.delivered;
      case 'Completed':
        return PickupStatus.completed;
      case 'Cancelled':
        return PickupStatus.cancelled;
      case 'Rejected':
        return PickupStatus.rejected;
      default:
        return PickupStatus.pending;
    }
  }

  void _showRequestDetails(PickupRequestModel request) {
    // This will be handled by the EnhancedPickupRequestCard
  }



  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        // Navigate to profile page
        break;
      case 'analytics':
        _navigateToAnalytics();
        break;
      case 'schedule':
        _tabController.animateTo(3);
        break;
      case 'customers':
        _tabController.animateTo(4);
        break;
      case 'help':
        _showHelpDialog();
        break;
      case 'logout':
        ref.read(authServiceProvider).signOut();
        break;
    }
  }

  void _navigateToAnalytics() {
    // Navigate to detailed analytics page
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Please contact re fab gmail.com',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 