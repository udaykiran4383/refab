import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/enhanced_product_card.dart';
import '../widgets/customer_analytics_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/notification_card.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/search_bar_widget.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'my_orders_page.dart';
import 'wishlist_page.dart';
import 'notifications_page.dart';

class EnhancedCustomerDashboard extends ConsumerStatefulWidget {
  final UserModel user;

  const EnhancedCustomerDashboard({super.key, required this.user});

  @override
  ConsumerState<EnhancedCustomerDashboard> createState() => _EnhancedCustomerDashboardState();
}

class _EnhancedCustomerDashboardState extends ConsumerState<EnhancedCustomerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartItemCountProvider(widget.user.id));
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider(widget.user.id));
    final customerProfile = ref.watch(customerProfileProvider(widget.user.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(cartItemCount, unreadNotifications),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildProductsTab(),
                _buildOrdersTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(int cartItemCount, int unreadNotifications) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${widget.user.name.split(' ').first}!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          customerProfile.when(
            data: (profile) => profile != null
                ? Text(
                    '${profile.tierDisplayName} Member',
                    style: TextStyle(
                      fontSize: 12,
                      color: profile.tierColor,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.black87),
              if (unreadNotifications > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      unreadNotifications.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsPage(user: widget.user),
            ),
          ),
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(user: widget.user),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          SearchBarWidget(
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          const SizedBox(height: 12),
          CategoryFilterChip(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final products = ref.watch(productsProvider({
      'category': _selectedCategory == 'All' ? null : _selectedCategory,
      'searchQuery': _searchQuery.isEmpty ? null : _searchQuery,
    }));

    final trendingProducts = ref.watch(trendingProductsProvider);
    final recommendedProducts = ref.watch(recommendedProductsProvider(widget.user.id));
    final customerAnalytics = ref.watch(customerAnalyticsProvider(widget.user.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Cards
          customerAnalytics.when(
            data: (analytics) => analytics != null
                ? CustomerAnalyticsCard(analytics: analytics)
                : const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          QuickActionsCard(
            onViewOrders: () => _tabController.animateTo(2),
            onViewWishlist: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WishlistPage(user: widget.user),
              ),
            ),
            onViewProfile: () => _tabController.animateTo(3),
          ),
          const SizedBox(height: 24),

          // Recommended Products
          _buildSectionHeader('Recommended for You', Icons.recommend),
          const SizedBox(height: 12),
          recommendedProducts.when(
            data: (products) => products.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 160,
                            child: EnhancedProductCard(
                              product: products[index],
                              onTap: () => _navigateToProductDetail(products[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text('No recommendations available'),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text('Failed to load recommendations'),
            ),
          ),
          const SizedBox(height: 24),

          // Trending Products
          _buildSectionHeader('Trending Now', Icons.trending_up),
          const SizedBox(height: 12),
          trendingProducts.when(
            data: (products) => products.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 160,
                            child: EnhancedProductCard(
                              product: products[index],
                              onTap: () => _navigateToProductDetail(products[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text('No trending products available'),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text('Failed to load trending products'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final products = ref.watch(productsProvider({
      'category': _selectedCategory == 'All' ? null : _selectedCategory,
      'searchQuery': _searchQuery.isEmpty ? null : _searchQuery,
    }));

    return products.when(
      data: (products) => products.isNotEmpty
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return EnhancedProductCard(
                  product: products[index],
                  onTap: () => _navigateToProductDetail(products[index]),
                );
              },
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading products',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    final orders = ref.watch(customerOrdersProvider(widget.user.id));

    return orders.when(
      data: (orders) => orders.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderSummaryCard(
                    order: orders[index],
                    onTap: () {
                      // Navigate to order detail
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start shopping to see your orders here',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading orders',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile summary card
          customerProfile.when(
            data: (profile) => profile != null
                ? _buildProfileSummaryCard(profile)
                : const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          // Profile actions
          _buildProfileActions(),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(CustomerProfileModel profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: profile.profileImage != null
                  ? NetworkImage(profile.profileImage!)
                  : null,
              child: profile.profileImage == null
                  ? Text(
                      profile.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: profile.tierColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.tierDisplayName,
                style: TextStyle(
                  color: profile.tierColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        _buildProfileActionTile(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: widget.user),
            ),
          ),
        ),
        _buildProfileActionTile(
          icon: Icons.favorite_outline,
          title: 'My Wishlist',
          subtitle: 'View your saved items',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WishlistPage(user: widget.user),
            ),
          ),
        ),
        _buildProfileActionTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsPage(user: widget.user),
            ),
          ),
        ),
        _buildProfileActionTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'App preferences and settings',
          onTap: () {
            // Navigate to settings
          },
        ),
        _buildProfileActionTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // Navigate to help
          },
        ),
        _buildProfileActionTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () {
            ref.read(authProvider.notifier).signOut();
          },
        ),
      ],
    );
  }

  Widget _buildProfileActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _tabController.animateTo(index);
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Quick add to cart or other action
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add_shopping_cart, color: Colors.white),
    );
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product, user: widget.user),
      ),
    );
  }
} 