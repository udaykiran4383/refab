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

  final List<String> _categories = [
    'All', 'Bags', 'Toys', 'Home Decor', 'Clothing', 'Accessories'
  ];

  final List<String> _sortOptions = [
    'Featured', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Newest'
  ];

  // Placeholder products
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Eco Tote Bag',
      'price': 299.0,
      'category': 'Bags',
      'imageUrl': '/placeholder.svg?height=200&width=200',
      'rating': 4.5,
    },
    {
      'name': 'Recycled Toy Bear',
      'price': 199.0,
      'category': 'Toys',
      'imageUrl': '/placeholder.svg?height=200&width=200',
      'rating': 4.2,
    },
    {
      'name': 'Wall Hanging',
      'price': 149.0,
      'category': 'Home Decor',
      'imageUrl': '/placeholder.svg?height=200&width=200',
      'rating': 4.8,
    },
    {
      'name': 'Cotton Scarf',
      'price': 249.0,
      'category': 'Clothing',
      'imageUrl': '/placeholder.svg?height=200&width=200',
      'rating': 4.1,
    },
    {
      'name': 'Laptop Sleeve',
      'price': 399.0,
      'category': 'Accessories',
      'imageUrl': '/placeholder.svg?height=200&width=200',
      'rating': 4.6,
    },
    {
      'name': 'Decorative Cushion',
      'price': 179.0,
      'category': 'Home Decor',
      'imageUrl': '/placeholder.svg?height=200&width=200',
      'rating': 4.3,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products.where((p) {
      final inCategory = _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final inPrice = (p['price'] as double) >= _priceRange.start && (p['price'] as double) <= _priceRange.end;
      return inCategory && inPrice;
    }).toList();
    if (_sortBy == 'Price: Low to High') {
      filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
    } else if (_sortBy == 'Price: High to Low') {
      filtered.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
    } else if (_sortBy == 'Rating') {
      filtered.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
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
          
          // Sort and Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} products found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260,
                        mainAxisExtent: 320,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          name: product['name'],
                          price: product['price'],
                          imageUrl: product['imageUrl'],
                          rating: product['rating'],
                          onTap: () {},
                          onAddToCart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${product['name']} to cart!')),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Price Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                labels: RangeLabels('₹${_priceRange.start.toInt()}', '₹${_priceRange.end.toInt()}'),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _priceRange = const RangeValues(0, 1000);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
