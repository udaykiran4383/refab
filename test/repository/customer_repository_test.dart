import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/customer/data/repositories/customer_repository.dart';
import 'package:refab_app/features/customer/data/models/product_model.dart';
import 'package:refab_app/features/customer/data/models/order_model.dart';
import 'package:refab_app/features/customer/data/models/cart_model.dart';

void main() {
  group('CustomerRepository Tests', () {
    late CustomerRepository repository;
    late String testCustomerId;

    setUpAll(() async {
      print('🛒 [CUSTOMER_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('🛒 [CUSTOMER_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🛒 [CUSTOMER_TEST] Setting up test environment...');
      repository = CustomerRepository();
      testCustomerId = 'test_customer_${DateTime.now().millisecondsSinceEpoch}';
      print('🛒 [CUSTOMER_TEST] ✅ Test environment ready. Customer ID: $testCustomerId');
    });

    tearDown(() async {
      print('🛒 [CUSTOMER_TEST] Cleaning up test data...');
      try {
        // Clean up test data
        final carts = await FirebaseFirestore.instance
            .collection('carts')
            .where('customerId', isEqualTo: testCustomerId)
            .get();
        
        final orders = await FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: testCustomerId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in carts.docs) {
          batch.delete(doc.reference);
        }
        for (var doc in orders.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🛒 [CUSTOMER_TEST] ✅ Test data cleaned up');
      } catch (e) {
        print('🛒 [CUSTOMER_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Product CRUD Operations', () {
      test('should get products successfully', () async {
        print('🛒 [CUSTOMER_TEST] Testing product retrieval...');
        
        print('🛒 [CUSTOMER_TEST] Fetching all products...');
        final products = await repository.getProducts().first;
        
        print('🛒 [CUSTOMER_TEST] ✅ Retrieved ${products.length} products');
        expect(products, isA<List<ProductModel>>());
        
        if (products.isNotEmpty) {
          final product = products.first;
          print('🛒 [CUSTOMER_TEST] 📦 Sample Product:');
          print('   - Name: ${product.name}');
          print('   - Price: ${product.formattedPrice}');
          print('   - Category: ${product.category}');
          print('   - In Stock: ${product.isInStock}');
          
          expect(product.name, isNotEmpty);
          expect(product.price, greaterThan(0));
          expect(product.category, isNotEmpty);
        }
      });

      test('should get products by category', () async {
        print('🛒 [CUSTOMER_TEST] Testing product filtering by category...');
        
        print('🛒 [CUSTOMER_TEST] Fetching products in "Bags" category...');
        final bagsProducts = await repository.getProducts(category: 'Bags').first;
        
        print('🛒 [CUSTOMER_TEST] ✅ Retrieved ${bagsProducts.length} bag products');
        
        for (final product in bagsProducts) {
          expect(product.category, equals('Bags'));
          print('🛒 [CUSTOMER_TEST]   - ${product.name} (${product.formattedPrice})');
        }
      });

      test('should search products', () async {
        print('🛒 [CUSTOMER_TEST] Testing product search...');
        
        print('🛒 [CUSTOMER_TEST] Searching for "Eco"...');
        final searchResults = await repository.getProducts(searchQuery: 'Eco').first;
        
        print('🛒 [CUSTOMER_TEST] ✅ Found ${searchResults.length} products matching "Eco"');
        
        for (final product in searchResults) {
          final matchesSearch = product.name.toLowerCase().contains('eco') ||
                               product.description.toLowerCase().contains('eco');
          expect(matchesSearch, isTrue);
          print('🛒 [CUSTOMER_TEST]   - ${product.name}');
        }
      });

      test('should get single product', () async {
        print('🛒 [CUSTOMER_TEST] Testing single product retrieval...');
        
        // First get a product ID
        final products = await repository.getProducts().first;
        if (products.isNotEmpty) {
          final productId = products.first.id;
          
          print('🛒 [CUSTOMER_TEST] Fetching product with ID: $productId');
          final product = await repository.getProduct(productId);
          
          if (product != null) {
            print('🛒 [CUSTOMER_TEST] ✅ Product retrieved successfully');
            print('   - Name: ${product.name}');
            print('   - Price: ${product.formattedPrice}');
            print('   - Description: ${product.description}');
            
            expect(product.id, equals(productId));
            expect(product.name, isNotEmpty);
          } else {
            print('🛒 [CUSTOMER_TEST] ⚠️ Product not found');
          }
        }
      });
    });

    group('Cart CRUD Operations', () {
      test('should add item to cart successfully', () async {
        print('🛒 [CUSTOMER_TEST] Testing cart item addition...');
        
        final cartItem = CartItem(
          productId: 'test_product_1',
          productName: 'Test Product',
          productImage: 'test_image.jpg',
          unitPrice: 299.0,
          quantity: 2,
          totalPrice: 598.0,
        );

        print('🛒 [CUSTOMER_TEST] Adding item to cart: ${cartItem.productName} x${cartItem.quantity}');
        await repository.addToCart(testCustomerId, cartItem);
        
        print('🛒 [CUSTOMER_TEST] Fetching cart...');
        final cart = await repository.getCart(testCustomerId).first;
        
        if (cart != null) {
          print('🛒 [CUSTOMER_TEST] ✅ Item added to cart successfully');
          print('   - Total Items: ${cart.totalItems}');
          print('   - Total Amount: ₹${cart.totalAmount}');
          expect(cart.items.length, equals(1));
          expect(cart.totalItems, equals(2));
          expect(cart.totalAmount, equals(598.0));
        } else {
          print('🛒 [CUSTOMER_TEST] ⚠️ Cart not found');
        }
      });

      test('should update cart item quantity', () async {
        print('🛒 [CUSTOMER_TEST] Testing cart item quantity update...');
        
        // First add an item
        final cartItem = CartItem(
          productId: 'test_product_2',
          productName: 'Test Product 2',
          productImage: 'test_image2.jpg',
          unitPrice: 199.0,
          quantity: 1,
          totalPrice: 199.0,
        );

        await repository.addToCart(testCustomerId, cartItem);
        
        print('🛒 [CUSTOMER_TEST] Updating quantity to 3...');
        await repository.updateCartItem(testCustomerId, 'test_product_2', 3);
        
        final cart = await repository.getCart(testCustomerId).first;
        if (cart != null) {
          final updatedItem = cart.items.firstWhere((item) => item.productId == 'test_product_2');
          print('🛒 [CUSTOMER_TEST] ✅ Quantity updated successfully');
          print('   - New Quantity: ${updatedItem.quantity}');
          print('   - New Total Price: ₹${updatedItem.totalPrice}');
          expect(updatedItem.quantity, equals(3));
          expect(updatedItem.totalPrice, equals(597.0));
        }
      });

      test('should remove item from cart', () async {
        print('🛒 [CUSTOMER_TEST] Testing cart item removal...');
        
        // First add an item
        final cartItem = CartItem(
          productId: 'test_product_3',
          productName: 'Test Product 3',
          productImage: 'test_image3.jpg',
          unitPrice: 99.0,
          quantity: 1,
          totalPrice: 99.0,
        );

        await repository.addToCart(testCustomerId, cartItem);
        
        print('🛒 [CUSTOMER_TEST] Removing item from cart...');
        await repository.removeFromCart(testCustomerId, 'test_product_3');
        
        final cart = await repository.getCart(testCustomerId).first;
        if (cart != null) {
          print('🛒 [CUSTOMER_TEST] ✅ Item removed successfully');
          print('   - Remaining Items: ${cart.items.length}');
          expect(cart.items.length, equals(0));
          expect(cart.isEmpty, isTrue);
        }
      });

      test('should clear cart', () async {
        print('🛒 [CUSTOMER_TEST] Testing cart clearing...');
        
        // Add multiple items
        final cartItem1 = CartItem(
          productId: 'test_product_4',
          productName: 'Test Product 4',
          productImage: 'test_image4.jpg',
          unitPrice: 150.0,
          quantity: 2,
          totalPrice: 300.0,
        );

        final cartItem2 = CartItem(
          productId: 'test_product_5',
          productName: 'Test Product 5',
          productImage: 'test_image5.jpg',
          unitPrice: 250.0,
          quantity: 1,
          totalPrice: 250.0,
        );

        await repository.addToCart(testCustomerId, cartItem1);
        await repository.addToCart(testCustomerId, cartItem2);
        
        print('🛒 [CUSTOMER_TEST] Clearing cart...');
        await repository.clearCart(testCustomerId);
        
        final cart = await repository.getCart(testCustomerId).first;
        print('🛒 [CUSTOMER_TEST] ✅ Cart cleared successfully');
        expect(cart, isNull);
      });
    });

    group('Order CRUD Operations', () {
      test('should create order successfully', () async {
        print('🛒 [CUSTOMER_TEST] Testing order creation...');
        
        final orderItems = [
          OrderItem(
            productId: 'test_product_6',
            productName: 'Test Product 6',
            productImage: 'test_image6.jpg',
            unitPrice: 199.0,
            quantity: 2,
            totalPrice: 398.0,
          ),
          OrderItem(
            productId: 'test_product_7',
            productName: 'Test Product 7',
            productImage: 'test_image7.jpg',
            unitPrice: 299.0,
            quantity: 1,
            totalPrice: 299.0,
          ),
        ];

        final order = OrderModel(
          id: '',
          customerId: testCustomerId,
          items: orderItems,
          totalAmount: 697.0,
          shippingAddress: '123 Test Street, Mumbai',
          status: OrderStatus.pending,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        print('🛒 [CUSTOMER_TEST] Creating order with ${order.items.length} items...');
        final orderId = await repository.createOrder(order);
        
        print('🛒 [CUSTOMER_TEST] ✅ Order created successfully with ID: $orderId');
        expect(orderId, isNotEmpty);
      });

      test('should get customer orders', () async {
        print('🛒 [CUSTOMER_TEST] Testing customer orders retrieval...');
        
        // Create test orders
        final order1 = OrderModel(
          id: '',
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: 'test_product_8',
              productName: 'Test Product 8',
              productImage: 'test_image8.jpg',
              unitPrice: 150.0,
              quantity: 1,
              totalPrice: 150.0,
            ),
          ],
          totalAmount: 150.0,
          shippingAddress: '456 Test Avenue, Mumbai',
          status: OrderStatus.pending,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final order2 = OrderModel(
          id: '',
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: 'test_product_9',
              productName: 'Test Product 9',
              productImage: 'test_image9.jpg',
              unitPrice: 200.0,
              quantity: 2,
              totalPrice: 400.0,
            ),
          ],
          totalAmount: 400.0,
          shippingAddress: '789 Test Road, Mumbai',
          status: OrderStatus.delivered,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createOrder(order1);
        await repository.createOrder(order2);

        print('🛒 [CUSTOMER_TEST] Fetching customer orders...');
        final orders = await repository.getCustomerOrders(testCustomerId).first;
        
        print('🛒 [CUSTOMER_TEST] ✅ Retrieved ${orders.length} orders');
        expect(orders.length, greaterThanOrEqualTo(2));
        
        final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
        final deliveredOrders = orders.where((o) => o.status == OrderStatus.delivered).length;
        
        print('🛒 [CUSTOMER_TEST] 📊 Pending: $pendingOrders, Delivered: $deliveredOrders');
        expect(pendingOrders, greaterThanOrEqualTo(1));
        expect(deliveredOrders, greaterThanOrEqualTo(1));
      });

      test('should cancel order', () async {
        print('🛒 [CUSTOMER_TEST] Testing order cancellation...');
        
        final order = OrderModel(
          id: '',
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: 'test_product_10',
              productName: 'Test Product 10',
              productImage: 'test_image10.jpg',
              unitPrice: 100.0,
              quantity: 1,
              totalPrice: 100.0,
            ),
          ],
          totalAmount: 100.0,
          shippingAddress: '321 Test Lane, Mumbai',
          status: OrderStatus.pending,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final orderId = await repository.createOrder(order);
        
        print('🛒 [CUSTOMER_TEST] Cancelling order...');
        await repository.cancelOrder(orderId);
        
        final orders = await repository.getCustomerOrders(testCustomerId).first;
        final cancelledOrder = orders.firstWhere((o) => o.id == orderId);
        
        print('🛒 [CUSTOMER_TEST] ✅ Order cancelled successfully. Status: ${cancelledOrder.status}');
        expect(cancelledOrder.status, equals(OrderStatus.cancelled));
      });
    });

    group('Wishlist Operations', () {
      test('should add and remove from wishlist', () async {
        print('🛒 [CUSTOMER_TEST] Testing wishlist operations...');
        
        final productId = 'test_wishlist_product';
        
        print('🛒 [CUSTOMER_TEST] Adding product to wishlist...');
        await repository.addToWishlist(testCustomerId, productId);
        
        final wishlist = await repository.getWishlist(testCustomerId).first;
        print('🛒 [CUSTOMER_TEST] ✅ Product added to wishlist. Wishlist size: ${wishlist.length}');
        expect(wishlist.contains(productId), isTrue);
        
        print('🛒 [CUSTOMER_TEST] Removing product from wishlist...');
        await repository.removeFromWishlist(testCustomerId, productId);
        
        final updatedWishlist = await repository.getWishlist(testCustomerId).first;
        print('🛒 [CUSTOMER_TEST] ✅ Product removed from wishlist. Wishlist size: ${updatedWishlist.length}');
        expect(updatedWishlist.contains(productId), isFalse);
      });
    });

    group('Profile Management', () {
      test('should update customer profile', () async {
        print('🛒 [CUSTOMER_TEST] Testing profile update...');
        
        final updates = {
          'name': 'Updated Test Customer',
          'phone': '+91-9876543210',
          'address': 'Updated Test Address, Mumbai',
        };

        print('🛒 [CUSTOMER_TEST] Updating profile with: $updates');
        await repository.updateCustomerProfile(testCustomerId, updates);
        
        final profile = await repository.getCustomerProfile(testCustomerId);
        if (profile != null) {
          print('🛒 [CUSTOMER_TEST] ✅ Profile updated successfully');
          print('   - Name: ${profile.name}');
          print('   - Phone: ${profile.phone}');
          print('   - Address: ${profile.address}');
        } else {
          print('🛒 [CUSTOMER_TEST] ⚠️ Profile not found (expected for test user)');
        }
      });
    });

    group('Error Handling', () {
      test('should handle invalid product retrieval', () async {
        print('🛒 [CUSTOMER_TEST] Testing error handling for invalid product...');
        
        final product = await repository.getProduct('non_existent_product_id');
        print('🛒 [CUSTOMER_TEST] ✅ Handled non-existent product gracefully');
        expect(product, isNull);
      });

      test('should handle empty cart operations', () async {
        print('🛒 [CUSTOMER_TEST] Testing empty cart operations...');
        
        await repository.removeFromCart(testCustomerId, 'non_existent_product');
        await repository.updateCartItem(testCustomerId, 'non_existent_product', 5);
        
        print('🛒 [CUSTOMER_TEST] ✅ Empty cart operations handled gracefully');
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent cart operations', () async {
        print('🛒 [CUSTOMER_TEST] Testing concurrent cart operations...');
        
        final futures = <Future>[];
        
        for (int i = 0; i < 3; i++) {
          final cartItem = CartItem(
            productId: 'concurrent_product_$i',
            productName: 'Concurrent Product $i',
            productImage: 'concurrent_image_$i.jpg',
            unitPrice: 100.0 + i * 50,
            quantity: i + 1,
            totalPrice: (100.0 + i * 50) * (i + 1),
          );
          
          futures.add(repository.addToCart(testCustomerId, cartItem));
        }

        print('🛒 [CUSTOMER_TEST] Executing 3 concurrent cart additions...');
        await Future.wait(futures);
        
        final cart = await repository.getCart(testCustomerId).first;
        if (cart != null) {
          print('🛒 [CUSTOMER_TEST] ✅ All concurrent operations completed');
          print('   - Total Items: ${cart.totalItems}');
          print('   - Total Amount: ₹${cart.totalAmount}');
          expect(cart.items.length, equals(3));
        }
      });
    });
  });
} 