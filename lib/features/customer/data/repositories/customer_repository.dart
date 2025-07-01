import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../../../auth/data/models/user_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products
  Stream<List<ProductModel>> getProducts({String? category, String? searchQuery}) {
    Query query = _firestore.collection('products').where('isAvailable', isEqualTo: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          var products = snapshot.docs
              .map((doc) => ProductModel.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList();
          
          if (searchQuery != null && searchQuery.isNotEmpty) {
            products = products.where((product) =>
                product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                product.description.toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();
          }
          
          return products;
        });
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // Cart Management
  Future<void> addToCart(String customerId, CartItem item) async {
    try {
      final cartRef = _firestore.collection('carts').doc(customerId);
      final cartDoc = await cartRef.get();
      
      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);
        
        final existingIndex = items.indexWhere((item) => item['productId'] == item.productId);
        if (existingIndex >= 0) {
          items[existingIndex]['quantity'] = (items[existingIndex]['quantity'] ?? 0) + item.quantity;
        } else {
          items.add(item.toJson());
        }
        
        await cartRef.update({
          'items': items,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        await cartRef.set({
          'customerId': customerId,
          'items': [item.toJson()],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> updateCartItem(String customerId, String productId, int quantity) async {
    try {
      final cartRef = _firestore.collection('carts').doc(customerId);
      final cartDoc = await cartRef.get();
      
      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);
        
        final existingIndex = items.indexWhere((item) => item['productId'] == productId);
        if (existingIndex >= 0) {
          if (quantity <= 0) {
            items.removeAt(existingIndex);
          } else {
            items[existingIndex]['quantity'] = quantity;
          }
        }
        
        await cartRef.update({
          'items': items,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  Future<void> removeFromCart(String customerId, String productId) async {
    try {
      final cartRef = _firestore.collection('carts').doc(customerId);
      final cartDoc = await cartRef.get();
      
      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);
        items.removeWhere((item) => item['productId'] == productId);
        
        await cartRef.update({
          'items': items,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> clearCart(String customerId) async {
    try {
      await _firestore.collection('carts').doc(customerId).delete();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  Stream<CartModel?> getCart(String customerId) {
    return _firestore
        .collection('carts')
        .doc(customerId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return CartModel.fromJson(doc.data()!);
          }
          return null;
        });
  }

  // Orders
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toJson());
      
      // Clear cart after successful order
      await clearCart(order.customerId);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Profile Management
  Future<void> updateCustomerProfile(String customerId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(customerId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update customer profile: $e');
    }
  }

  Future<UserModel?> getCustomerProfile(String customerId) async {
    try {
      final doc = await _firestore.collection('users').doc(customerId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer profile: $e');
    }
  }

  // Wishlist
  Future<void> addToWishlist(String customerId, String productId) async {
    try {
      await _firestore.collection('users').doc(customerId).update({
        'wishlist': FieldValue.arrayUnion([productId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String customerId, String productId) async {
    try {
      await _firestore.collection('users').doc(customerId).update({
        'wishlist': FieldValue.arrayRemove([productId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  Stream<List<String>> getWishlist(String customerId) {
    return _firestore
        .collection('users')
        .doc(customerId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            return List<String>.from(data['wishlist'] ?? []);
          }
          return <String>[];
        });
  }
} 