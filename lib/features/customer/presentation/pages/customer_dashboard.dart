import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import 'product_catalog_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'my_orders_page.dart';

class CustomerDashboard extends ConsumerWidget {
  final UserModel user;

  const CustomerDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🛍️ [CUSTOMER_DASHBOARD] Building for user: ${user.name}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name.split(' ').first}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'orders',
                child: Text('My Orders'),
              ),
              const PopupMenuItem(
                value: 'impact',
                child: Text('My Impact'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(loginProvider.notifier).signOut();
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              } else if (value == 'orders') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyOrdersPage(),
                  ),
                );
              } else if (value == 'impact') {
                // TODO: Implement My Impact page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('My Impact page coming soon!')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Shop by Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CategoryChip(label: 'All', isSelected: true),
                    CategoryChip(label: 'Bags'),
                    CategoryChip(label: 'Toys'),
                    CategoryChip(label: 'Home Decor'),
                    CategoryChip(label: 'Clothing'),
                    CategoryChip(label: 'Accessories'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductCatalogPage(),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 280,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        name: [
                          'Eco Tote Bag',
                          'Recycled Toy Bear',
                          'Wall Hanging',
                          'Cotton Scarf',
                          'Decorative Cushion',
                          'Recycled Notebook',
                        ][index],
                        price: [299.0, 199.0, 149.0, 99.0, 179.0, 49.0][index],
                        imageUrl: [
                          'https://picsum.photos/200/200?random=1',
                          'https://picsum.photos/200/200?random=2',
                          'https://picsum.photos/200/200?random=3',
                          'https://picsum.photos/200/200?random=4',
                          'https://picsum.photos/200/200?random=5',
                          'https://picsum.photos/200/200?random=6',
                        ][index],
                        onTap: () {
                          // Navigate to product details
                        },
                        onAddToCart: () {
                          // Add to cart functionality
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
