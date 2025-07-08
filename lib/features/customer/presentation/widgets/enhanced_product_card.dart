import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../providers/customer_provider.dart';

class EnhancedProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showWishlistButton;
  final bool showAddToCartButton;

  const EnhancedProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showWishlistButton = true,
    this.showAddToCartButton = true,
  });

  @override
  ConsumerState<EnhancedProductCard> createState() => _EnhancedProductCardState();
}

class _EnhancedProductCardState extends ConsumerState<EnhancedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _isHovered ? 8 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),
                    _buildProductInfo(),
                    if (widget.showAddToCartButton) _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            image: DecorationImage(
              image: NetworkImage(widget.product.mainImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (widget.product.isLowStock)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Low Stock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (!widget.product.isInStock)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Out of Stock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (widget.showWishlistButton)
          Positioned(
            top: 8,
            right: widget.product.isInStock ? 8 : 80,
            child: _buildWishlistButton(),
          ),
      ],
    );
  }

  Widget _buildWishlistButton() {
    return Consumer(
      builder: (context, ref, child) {
        final wishlist = ref.watch(wishlistProvider('current_user_id'));
        
        return wishlist.when(
          data: (wishlistItems) {
            final isInWishlist = wishlistItems.contains(widget.product.id);
            
            return GestureDetector(
              onTap: () {
                final notifier = ref.read(wishlistNotifierProvider.notifier);
                if (isInWishlist) {
                  notifier.removeFromWishlist('current_user_id', widget.product.id);
                } else {
                  notifier.addToWishlist('current_user_id', widget.product.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isInWishlist ? Colors.red : Colors.grey,
                ),
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.category,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                widget.product.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              if (widget.product.rating != null) ...[
                Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 2),
                Text(
                  widget.product.rating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          if (widget.product.environmentalImpact != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.eco,
                  size: 12,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Eco-friendly',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.product.isInStock
                  ? () => _addToCart()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                widget.product.isInStock ? 'Add to Cart' : 'Out of Stock',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    final cartItem = CartItem(
      productId: widget.product.id,
      productName: widget.product.name,
      productImage: widget.product.mainImage,
      unitPrice: widget.product.price,
      quantity: 1,
      totalPrice: widget.product.price,
    );

    ref.read(cartNotifierProvider.notifier).addToCart('current_user_id', cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }
} 