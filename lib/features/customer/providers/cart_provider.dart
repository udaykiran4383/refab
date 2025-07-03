import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_model.dart';

class CartNotifier extends StateNotifier<Map<String, Map<String, dynamic>>> {
  CartNotifier() : super({});

  void addToCart(ProductModel product) {
    state = {
      ...state,
      product.id: {
        'product': product,
        'quantity': (state[product.id]?['quantity'] ?? 0) + 1,
      },
    };
  }

  void removeFromCart(String productId) {
    if (!state.containsKey(productId)) return;
    final currentQty = state[productId]!['quantity'] as int;
    if (currentQty <= 1) {
      final newState = {...state}..remove(productId);
      state = newState;
    } else {
      state = {
        ...state,
        productId: {
          ...state[productId]!,
          'quantity': currentQty - 1,
        },
      };
    }
  }

  void clearCart() {
    state = {};
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Map<String, dynamic>>>(
  (ref) => CartNotifier(),
); 