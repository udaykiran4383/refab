import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/firestore_service.dart';
import '../../../models/product_model.dart';
import '../presentation/widgets/product_card.dart';
import '../presentation/pages/cart_page.dart';
import '../providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Featured';

  final List<String> _categories = [
    'All', 'Bags', 'Toys', 'Home Decor', 'Clothing', 'Accessories'
  ];
  final List<String> _sortOptions = [
    'Featured', 'Price: Low to High', 'Price: High to Low', 'Newest'
  ];

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    var filtered = products;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    switch (_sortBy) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userName = 'User'; // Replace with actual user name if available
    final cart = ref.watch(cartProvider);
    int cartCount = cart.values.fold(0, (sum, item) => sum + (item['quantity'] as int));
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $userName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch<String?>(
                context: context,
                delegate: _ProductSearchDelegate(_searchQuery),
              );
              if (result != null) {
                setState(() => _searchQuery = result);
              }
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  print('Navigating to cart page using GoRouter');
                  context.push('/cart');
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              print('PopupMenu selected: $value');
              if (value == 'profile') {
                print('Navigating to /profile using GoRouter');
                context.push('/profile');
              } else if (value == 'orders') {
                print('Navigating to /orders using GoRouter');
                context.push('/orders');
              } else if (value == 'logout') {
                print('Logging out...');
                // Use Riverpod to sign out
                ref.read(authServiceProvider).signOut().then((_) {
                  print('Logout complete, navigating to /login using GoRouter');
                  context.go('/login');
                });
              }
            },
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
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              )).toList(),
            ),
          ),
          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Featured Products', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _sortBy = value!);
                  },
                ),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: FirestoreService.getProducts(),
              builder: (context, snapshot) {
                final products = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : [
                      ProductModel(id: '1', name: 'Eco Tote Bag', description: 'Sustainable cotton tote bag', price: 299.0, imageUrl: 'https://picsum.photos/200/200?random=1', category: 'Bags', rating: 4.5, isAvailable: true, createdAt: DateTime.now()),
                      ProductModel(id: '2', name: 'Recycled Toy Bear', description: 'Soft toy made from recycled materials', price: 199.0, imageUrl: 'https://picsum.photos/200/200?random=2', category: 'Toys', rating: 4.2, isAvailable: true, createdAt: DateTime.now()),
                      ProductModel(id: '3', name: 'Wall Hanging', description: 'Beautiful wall decoration', price: 149.0, imageUrl: 'https://picsum.photos/200/200?random=3', category: 'Home Decor', rating: 4.8, isAvailable: true, createdAt: DateTime.now()),
                      ProductModel(id: '4', name: 'Cotton Scarf', description: 'Handwoven cotton scarf', price: 99.0, imageUrl: 'https://picsum.photos/200/200?random=4', category: 'Clothing', rating: 4.1, isAvailable: true, createdAt: DateTime.now()),
                    ];
                final filtered = _applyFilters(products);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final inCart = cart[product.id];
                    final quantity = inCart != null ? inCart['quantity'] as int : 0;
                    return Stack(
                      children: [
                        ProductCard(
                          name: product.name,
                          price: product.price,
                          imageUrl: product.imageUrl,
                          onTap: () {},
                          onAddToCart: () {
                            ref.read(cartProvider.notifier).addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${product.name} to cart!')),
                            );
                          },
                        ),
                        if (quantity > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+$quantity',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<String?> {
  final String initialQuery;
  _ProductSearchDelegate(this.initialQuery) {
    query = initialQuery;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}
