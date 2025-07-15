import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/customer_profile_model.dart';
import '../models/customer_analytics_model.dart';
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
                    ...(doc.data() as Map<String, dynamic>),
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
          ...(doc.data()! as Map<String, dynamic>),
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
        
        final existingIndex = items.indexWhere((cartItem) => cartItem['productId'] == item.productId);
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
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromJson({
          ...(doc.data()! as Map<String, dynamic>),
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

  // Customer Profile Management
  Future<void> createCustomerProfile(CustomerProfileModel profile) async {
    try {
      await _firestore.collection('customerProfiles').doc(profile.id).set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to create customer profile: $e');
    }
  }

  Stream<CustomerProfileModel?> getCustomerProfileStream(String customerId) {
    return _firestore
        .collection('customerProfiles')
        .doc(customerId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return CustomerProfileModel.fromJson({
              ...(doc.data()! as Map<String, dynamic>),
              'id': doc.id,
            });
          }
          return null;
        });
  }

  // Customer Analytics
  Future<void> updateCustomerAnalytics(String customerId, Map<String, dynamic> analytics) async {
    try {
      await _firestore.collection('customerAnalytics').doc(customerId).set({
        'customerId': customerId,
        ...analytics,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update customer analytics: $e');
    }
  }

  Future<CustomerAnalyticsModel?> getCustomerAnalytics(String customerId) async {
    try {
      final doc = await _firestore.collection('customerAnalytics').doc(customerId).get();
      if (doc.exists) {
        return CustomerAnalyticsModel.fromJson({
          ...(doc.data()! as Map<String, dynamic>),
          'customerId': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer analytics: $e');
    }
  }

  // Advanced Product Features
  Stream<List<ProductModel>> getTrendingProducts({int limit = 10}) {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  // Advanced Order Features
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<List<OrderModel>> getOrdersByStatus(String customerId, OrderStatus status) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromJson({
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders by status: $e');
    }
  }

  // Customer Search and Filter
  Stream<List<CustomerProfileModel>> searchCustomers({
    String? searchQuery,
    CustomerTier? tier,
    CustomerStatus? status,
    String? city,
    int limit = 20,
  }) {
    Query query = _firestore.collection('customerProfiles');
    
    if (tier != null) {
      query = query.where('tier', isEqualTo: tier.toString().split('.').last);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }
    
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    
    return query
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          var customers = snapshot.docs
              .map((doc) => CustomerProfileModel.fromJson({
                    ...(doc.data() as Map<String, dynamic>),
                    'id': doc.id,
                  }))
              .toList();
          
          if (searchQuery != null && searchQuery.isNotEmpty) {
            customers = customers.where((customer) =>
                customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                customer.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (customer.phone?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
            ).toList();
          }
          
          return customers;
        });
  }

  // Bulk Operations
  Future<void> bulkUpdateCustomerStatus(List<String> customerIds, CustomerStatus status) async {
    try {
      final batch = _firestore.batch();
      
      for (final customerId in customerIds) {
        final docRef = _firestore.collection('customerProfiles').doc(customerId);
        batch.update(docRef, {
          'status': status.toString().split('.').last,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk update customer status: $e');
    }
  }

  Future<void> bulkUpdateCustomerTier(List<String> customerIds, CustomerTier tier) async {
    try {
      final batch = _firestore.batch();
      
      for (final customerId in customerIds) {
        final docRef = _firestore.collection('customerProfiles').doc(customerId);
        batch.update(docRef, {
          'tier': tier.toString().split('.').last,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk update customer tier: $e');
    }
  }

  // Customer Analytics Dashboard
  Future<Map<String, dynamic>> getCustomerAnalyticsSummary() async {
    try {
      final customersSnapshot = await _firestore.collection('customerProfiles').get();
      final ordersSnapshot = await _firestore.collection('orders').get();
      
      final totalCustomers = customersSnapshot.docs.length;
      final totalOrders = ordersSnapshot.docs.length;
      
      double totalRevenue = 0;
      for (final doc in ordersSnapshot.docs) {
        final orderData = doc.data();
        if (orderData['status'] != 'cancelled') {
          totalRevenue += (orderData['totalAmount'] ?? 0).toDouble();
        }
      }
      
      final activeCustomers = customersSnapshot.docs
          .where((doc) => doc.data()['status'] == 'active')
          .length;
      
      final premiumCustomers = customersSnapshot.docs
          .where((doc) => doc.data()['tier'] == 'platinum' || doc.data()['tier'] == 'gold')
          .length;
      
      return {
        'totalCustomers': totalCustomers,
        'activeCustomers': activeCustomers,
        'premiumCustomers': premiumCustomers,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'customerRetentionRate': totalCustomers > 0 ? activeCustomers / totalCustomers : 0,
      };
    } catch (e) {
      throw Exception('Failed to get customer analytics summary: $e');
    }
  }

  // Customer Segmentation
  Future<Map<String, int>> getCustomerSegmentation() async {
    try {
      final snapshot = await _firestore.collection('customerProfiles').get();
      
      final segments = <String, int>{};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tier = data['tier'] ?? 'bronze';
        final status = data['status'] ?? 'active';
        
        final segment = '${tier}_${status}';
        segments[segment] = (segments[segment] ?? 0) + 1;
      }
      
      return segments;
    } catch (e) {
      throw Exception('Failed to get customer segmentation: $e');
    }
  }

  // Customer Notifications
  Future<void> sendCustomerNotification(String customerId, Map<String, dynamic> notification) async {
    try {
      await _firestore.collection('customerNotifications').add({
        'customerId': customerId,
        'title': notification['title'],
        'message': notification['message'],
        'type': notification['type'] ?? 'general',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send customer notification: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getCustomerNotifications(String customerId) {
    return _firestore
        .collection('customerNotifications')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                })
            .toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('customerNotifications').doc(notificationId).update({
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
} 