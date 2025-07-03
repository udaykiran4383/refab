import 'package:flutter/material.dart';
import '../widgets/product_card.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  String _selectedCategory = 'All';
  String _sortBy = 'Featured';
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _showFilters = false;

  final List<String> _categories = [
    'All', 'Bags', 'Toys', 'Home Decor', 'Clothing', 'Accessories'
  ];

  final List<String> _sortOptions = [
    'Featured', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Newest'
  ];

  // Placeholder products with better data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Eco Tote Bag',
      'price': 299.0,
      'category': 'Bags',
      'imageUrl': 'https://via.placeholder.com/200x200/4CAF50/FFFFFF?text=Eco+Bag',
      'rating': 4.5,
      'description': 'Sustainable cotton tote bag',
    },
    {
      'name': 'Recycled Toy Bear',
      'price': 199.0,
      'category': 'Toys',
      'imageUrl': 'https://via.placeholder.com/200x200/FF9800/FFFFFF?text=Toy+Bear',
      'rating': 4.2,
      'description': 'Soft toy made from recycled materials',
    },
    {
      'name': 'Wall Hanging',
      'price': 149.0,
      'category': 'Home Decor',
      'imageUrl': 'https://via.placeholder.com/200x200/9C27B0/FFFFFF?text=Wall+Art',
      'rating': 4.8,
      'description': 'Beautiful wall decoration',
    },
    {
      'name': 'Cotton Scarf',
      'price': 249.0,
      'category': 'Clothing',
      'imageUrl': 'https://via.placeholder.com/200x200/2196F3/FFFFFF?text=Scarf',
      'rating': 4.1,
      'description': 'Comfortable cotton scarf',
    },
    {
      'name': 'Laptop Sleeve',
      'price': 399.0,
      'category': 'Accessories',
      'imageUrl': 'https://via.placeholder.com/200x200/607D8B/FFFFFF?text=Laptop+Sleeve',
      'rating': 4.6,
      'description': 'Protective laptop sleeve',
    },
    {
      'name': 'Decorative Cushion',
      'price': 179.0,
      'category': 'Home Decor',
      'imageUrl': 'https://via.placeholder.com/200x200/E91E63/FFFFFF?text=Cushion',
      'rating': 4.3,
      'description': 'Stylish decorative cushion',
    },
    {
      'name': 'Recycled Notebook',
      'price': 89.0,
      'category': 'Accessories',
      'imageUrl': 'https://via.placeholder.com/200x200/795548/FFFFFF?text=Notebook',
      'rating': 4.4,
      'description': 'Eco-friendly notebook',
    },
    {
      'name': 'Bamboo Water Bottle',
      'price': 129.0,
      'category': 'Accessories',
      'imageUrl': 'https://via.placeholder.com/200x200/4CAF50/FFFFFF?text=Water+Bottle',
      'rating': 4.7,
      'description': 'Sustainable bamboo water bottle',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products.where((p) {
      final inCategory = _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final inPrice = (p['price'] as double) >= _priceRange.start && (p['price'] as double) <= _priceRange.end;
      return inCategory && inPrice;
    }).toList();
    
    // Apply sorting
    switch (_sortBy) {
      case 'Price: Low to High':
        filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'Rating':
        filtered.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'Newest':
        // For demo, we'll sort by name
        filtered.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      default:
        // Featured - keep original order
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
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
          
          // Advanced Filters
          if (_showFilters) _buildAdvancedFilters(),
          
          // Sort and Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} products found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Product Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          name: product['name'],
                          price: product['price'],
                          imageUrl: product['imageUrl'],
                          onTap: () {
                            _showProductDetails(context, product);
                          },
                          onAddToCart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${product['name']} to cart!'),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '₹${_priceRange.start.round()}',
              '₹${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${_priceRange.start.round()}'),
              Text('₹${_priceRange.end.round()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _priceRange = const RangeValues(0, 1000);
                _sortBy = 'Featured';
                _showFilters = false;
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Products'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter product name...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Searching for: $value')),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['imageUrl'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product['price']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(' ${product['rating']}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(product['description']),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${product['name']} to cart!'),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
