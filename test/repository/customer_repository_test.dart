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
      print('\ud83d\uded2 [CUSTOMER_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('\ud83d\uded2 [CUSTOMER_TEST] \u2705 Firebase initialized');
    });
    setUp(() {
      print('\ud83d\uded2 [CUSTOMER_TEST] Setting up test environment...');
      repository = CustomerRepository();
      testCustomerId = 'test_customer_${DateTime.now().millisecondsSinceEpoch}';
      print('\ud83d\uded2 [CUSTOMER_TEST] \u2705 Test environment ready. Customer ID: $testCustomerId');
    });

    group('Product Management', () {
      test('should get products', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing get products...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test product
        final testProduct = ProductModel(
          id: 'test_product_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Test Product',
          description: 'A test product for testing',
          price: 100.0,
          category: 'cotton',
          imageUrl: 'https://example.com/image.jpg',
          isAvailable: true,
          stockQuantity: 10,
          images: ['https://example.com/image.jpg'],
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(testProduct.id)
            .set(testProduct.toJson());

        final products = await repository.getProducts().first;
        expect(products, isNotEmpty);
        expect(products.any((p) => p.id == testProduct.id), isTrue);
      });

      test('should get products by category', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing get products by category...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test products
        final cottonProduct = ProductModel(
          id: 'cotton_product_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Cotton Product',
          description: 'A cotton product',
          price: 150.0,
          category: 'cotton',
          imageUrl: 'https://example.com/cotton.jpg',
          isAvailable: true,
          stockQuantity: 5,
          images: ['https://example.com/cotton.jpg'],
          createdAt: DateTime.now(),
        );

        final silkProduct = ProductModel(
          id: 'silk_product_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Silk Product',
          description: 'A silk product',
          price: 300.0,
          category: 'silk',
          imageUrl: 'https://example.com/silk.jpg',
          isAvailable: true,
          stockQuantity: 3,
          images: ['https://example.com/silk.jpg'],
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(cottonProduct.id)
            .set(cottonProduct.toJson());

        await FirebaseFirestore.instance
            .collection('products')
            .doc(silkProduct.id)
            .set(silkProduct.toJson());

        final cottonProducts = await repository.getProducts(category: 'cotton').first;
        expect(cottonProducts.any((p) => p.id == cottonProduct.id), isTrue);
        expect(cottonProducts.any((p) => p.id == silkProduct.id), isFalse);
      });

      test('should search products', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing product search...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test product
        final testProduct = ProductModel(
          id: 'search_product_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Unique Search Product',
          description: 'A product for search testing',
          price: 200.0,
          category: 'cotton',
          imageUrl: 'https://example.com/search.jpg',
          isAvailable: true,
          stockQuantity: 8,
          images: ['https://example.com/search.jpg'],
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(testProduct.id)
            .set(testProduct.toJson());

        final searchResults = await repository.getProducts(searchQuery: 'Unique Search').first;
        expect(searchResults.any((p) => p.id == testProduct.id), isTrue);
      });
    });

    group('Cart Management', () {
      test('should add item to cart', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing add item to cart...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final productId = 'cart_product_${DateTime.now().millisecondsSinceEpoch}';
        final cartItem = CartItem(
          productId: productId,
          productName: 'Test Product',
          productImage: 'https://example.com/image.jpg',
          unitPrice: 100.0,
          quantity: 2,
          totalPrice: 200.0,
        );

        await repository.addToCart(testCustomerId, cartItem);
        
        final cart = await repository.getCart(testCustomerId).first;
        expect(cart?.items.any((item) => item.productId == productId), isTrue);
      });

      test('should update cart item quantity', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing update cart item quantity...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final productId = 'update_product_${DateTime.now().millisecondsSinceEpoch}';
        final initialQuantity = 1;
        final updatedQuantity = 3;

        // Add item to cart
        final cartItem = CartItem(
          productId: productId,
          productName: 'Test Product',
          productImage: 'https://example.com/image.jpg',
          unitPrice: 100.0,
          quantity: initialQuantity,
          totalPrice: 100.0,
        );
        await repository.addToCart(testCustomerId, cartItem);

        // Update quantity
        await repository.updateCartItem(testCustomerId, productId, updatedQuantity);

        final cart = await repository.getCart(testCustomerId).first;
        final item = cart?.items.firstWhere((item) => item.productId == productId);
        expect(item?.quantity, equals(updatedQuantity));
      });

      test('should remove item from cart', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing remove item from cart...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final productId = 'remove_product_${DateTime.now().millisecondsSinceEpoch}';

        // Add item to cart
        final cartItem = CartItem(
          productId: productId,
          productName: 'Test Product',
          productImage: 'https://example.com/image.jpg',
          unitPrice: 100.0,
          quantity: 1,
          totalPrice: 100.0,
        );
        await repository.addToCart(testCustomerId, cartItem);

        // Remove item
        await repository.removeFromCart(testCustomerId, productId);

        final cart = await repository.getCart(testCustomerId).first;
        expect(cart?.items.any((item) => item.productId == productId), isFalse);
      });

      test('should clear cart', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing clear cart...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Add items to cart
        final cartItem1 = CartItem(
          productId: 'product1_${DateTime.now().millisecondsSinceEpoch}',
          productName: 'Product 1',
          productImage: 'https://example.com/product1.jpg',
          unitPrice: 100.0,
          quantity: 1,
          totalPrice: 100.0,
        );
        final cartItem2 = CartItem(
          productId: 'product2_${DateTime.now().millisecondsSinceEpoch}',
          productName: 'Product 2',
          productImage: 'https://example.com/product2.jpg',
          unitPrice: 200.0,
          quantity: 2,
          totalPrice: 400.0,
        );
        await repository.addToCart(testCustomerId, cartItem1);
        await repository.addToCart(testCustomerId, cartItem2);

        // Clear cart
        await repository.clearCart(testCustomerId);

        final cart = await repository.getCart(testCustomerId).first;
        expect(cart?.items, isEmpty);
      });
    });

    group('Order Management', () {
      test('should create order', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing create order...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Add items to cart first
        final productId = 'order_product_${DateTime.now().millisecondsSinceEpoch}';
        final cartItem = CartItem(
          productId: productId,
          productName: 'Test Product',
          productImage: 'https://example.com/image.jpg',
          unitPrice: 100.0,
          quantity: 2,
          totalPrice: 200.0,
        );
        await repository.addToCart(testCustomerId, cartItem);

        final order = OrderModel(
          id: '',
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: productId,
              productName: 'Test Product',
              productImage: 'https://example.com/image.jpg',
              unitPrice: 100.0,
              quantity: 2,
              totalPrice: 200.0,
            ),
          ],
          totalAmount: 200.0,
          shippingAddress: 'Test Address, Mumbai',
          status: OrderStatus.pending,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final orderId = await repository.createOrder(order);

        expect(orderId, isNotEmpty);
      });

      test('should get customer orders', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing get customer orders...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test order
        final testOrder = OrderModel(
          id: 'order_${DateTime.now().millisecondsSinceEpoch}',
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: 'product_${DateTime.now().millisecondsSinceEpoch}',
              productName: 'Test Product',
              productImage: 'https://example.com/image.jpg',
              unitPrice: 100.0,
              quantity: 1,
              totalPrice: 100.0,
            ),
          ],
          totalAmount: 100.0,
          shippingAddress: 'Test Address, Mumbai',
          status: OrderStatus.pending,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(testOrder.id)
            .set(testOrder.toJson());

        final orders = await repository.getCustomerOrders(testCustomerId).first;
        expect(orders.any((o) => o.id == testOrder.id), isTrue);
      });

      test('should cancel order', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing cancel order...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test order
        final testOrder = OrderModel(
          id: 'cancel_order_${DateTime.now().millisecondsSinceEpoch}',
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: 'product_${DateTime.now().millisecondsSinceEpoch}',
              productName: 'Test Product',
              productImage: 'https://example.com/image.jpg',
              unitPrice: 100.0,
              quantity: 1,
              totalPrice: 100.0,
            ),
          ],
          totalAmount: 100.0,
          shippingAddress: 'Test Address, Mumbai',
          status: OrderStatus.pending,
          orderDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(testOrder.id)
            .set(testOrder.toJson());

        // Cancel order
        await repository.cancelOrder(testOrder.id);

        final updatedOrder = await FirebaseFirestore.instance
            .collection('orders')
            .doc(testOrder.id)
            .get();

        expect(updatedOrder.data()?['status'], equals('cancelled'));
      });
    });

    group('Profile Management', () {
      test('should get customer profile', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing get customer profile...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final profile = await repository.getCustomerProfile(testCustomerId);
        expect(profile, isNotNull);
      });

      test('should update customer profile', () async {
        print('\ud83d\uded2 [CUSTOMER_TEST] Testing update customer profile...');
        
        if (!Firebase.apps.isNotEmpty) {
          print('\ud83d\uded2 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final updates = {
          'name': 'Updated Customer Name',
          'phone': '+91-9876543210',
        };

        await repository.updateCustomerProfile(testCustomerId, updates);

        final updatedProfile = await repository.getCustomerProfile(testCustomerId);
        expect(updatedProfile?.name, equals('Updated Customer Name'));
      });
    });
  });
} 