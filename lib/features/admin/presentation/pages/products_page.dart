import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(allProductsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.inventory,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Product Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          _buildFilters(),
          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: products.when(
              data: (productsList) {
                final filteredProducts = _filterProducts(productsList);
                
                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductCard(context, product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading products: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Search
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            // Category Filter
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: ['All', 'Clothing', 'Accessories', 'Home', 'Other'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(
            Icons.inventory,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          product['name'] ?? 'Unknown Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product['description'] ?? 'No description'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '₹${product['price']?.toString() ?? '0'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product['category']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleProductAction(context, product, value),
        ),
        onTap: () => _showProductDetails(context, product),
      ),
    );
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    return products.where((product) {
      // Search filter
      final matchesSearch = product['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          product['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) == true;

      // Category filter
      final matchesCategory = _selectedCategory == 'All' || product['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _handleProductAction(BuildContext context, Map<String, dynamic> product, String action) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(context, product);
        break;
      case 'delete':
        _showDeleteProductDialog(context, product);
        break;
    }
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Product Details - ${product['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${product['name']}'),
              const SizedBox(height: 8),
              Text('Description: ${product['description']}'),
              const SizedBox(height: 8),
              Text('Price: ₹${product['price']}'),
              const SizedBox(height: 8),
              Text('Category: ${product['category']}'),
              const SizedBox(height: 8),
              Text('Stock: ${product['stock'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Created: ${_formatDate(product['createdAt'])}'),
              if (product['updatedAt'] != null) ...[
                const SizedBox(height: 8),
                Text('Updated: ${_formatDate(product['updatedAt'])}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: const Text('Product creation functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product - ${product['name']}'),
        content: const Text('Product editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).deleteProduct(product['id']);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

// Provider for all products
final allProductsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllProducts();
}); 