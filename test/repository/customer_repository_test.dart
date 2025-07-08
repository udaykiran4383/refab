import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/customer/data/repositories/customer_repository.dart';
import 'package:refab_app/features/customer/data/models/product_model.dart';
import 'package:refab_app/features/customer/data/models/order_model.dart';
import 'package:refab_app/features/customer/data/models/cart_model.dart';
import '../test_helper.dart';

void main() {
  group('CustomerRepository Tests', () {
    late CustomerRepository repository;
    late String testCustomerId;

    setUpAll(() async {
      print('🛒 [CUSTOMER_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestHelper.setupFirebaseForTesting();
      print('🛒 [CUSTOMER_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🛒 [CUSTOMER_TEST] Setting up test environment...');
      repository = CustomerRepository();
      testCustomerId = TestHelper.generateTestId('customer');
      print('🛒 [CUSTOMER_TEST] ✅ Test environment ready. Customer ID: $testCustomerId');
    });

    tearDown(() async {
      print('🛒 [CUSTOMER_TEST] Cleaning up test data...');
      await TestHelper.cleanupTestData('orders', 'customerId', testCustomerId);
      await TestHelper.cleanupTestData('cart', 'customerId', testCustomerId);
      print('🛒 [CUSTOMER_TEST] ✅ Test data cleaned up');
    });

    group('Product Management', () {
      test('should get all products', () async {
        print('🛒 [CUSTOMER_TEST] Testing get all products...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test product
        final testProduct = ProductModel(
          id: TestHelper.generateTestId('product'),
          name: 'Test Product',
          description: 'A test product for testing',
          price: 100.0,
          category: 'cotton',
          imageUrl: 'https://example.com/image.jpg',
          isAvailable: true,
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(testProduct.id)
            .set(testProduct.toJson());

        await TestHelper.waitForFirebaseOperations();

        final products = await repository.getAllProducts().first;
        expect(products, isNotEmpty);
        expect(products.any((p) => p.id == testProduct.id), isTrue);
        
        TestHelper.logTestSuccess('Get All Products');
      });

      test('should get products by category', () async {
        print('🛒 [CUSTOMER_TEST] Testing get products by category...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test products
        final cottonProduct = ProductModel(
          id: TestHelper.generateTestId('cotton_product'),
          name: 'Cotton Product',
          description: 'A cotton product',
          price: 150.0,
          category: 'cotton',
          imageUrl: 'https://example.com/cotton.jpg',
          isAvailable: true,
        );

        final silkProduct = ProductModel(
          id: TestHelper.generateTestId('silk_product'),
          name: 'Silk Product',
          description: 'A silk product',
          price: 300.0,
          category: 'silk',
          imageUrl: 'https://example.com/silk.jpg',
          isAvailable: true,
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(cottonProduct.id)
            .set(cottonProduct.toJson());

        await FirebaseFirestore.instance
            .collection('products')
            .doc(silkProduct.id)
            .set(silkProduct.toJson());

        await TestHelper.waitForFirebaseOperations();

        final cottonProducts = await repository.getProductsByCategory('cotton').first;
        expect(cottonProducts.any((p) => p.id == cottonProduct.id), isTrue);
        expect(cottonProducts.any((p) => p.id == silkProduct.id), isFalse);
        
        TestHelper.logTestSuccess('Get Products By Category');
      });

      test('should search products', () async {
        print('🛒 [CUSTOMER_TEST] Testing product search...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test product
        final testProduct = ProductModel(
          id: TestHelper.generateTestId('search_product'),
          name: 'Unique Search Product',
          description: 'A product for search testing',
          price: 200.0,
          category: 'cotton',
          imageUrl: 'https://example.com/search.jpg',
          isAvailable: true,
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(testProduct.id)
            .set(testProduct.toJson());

        await TestHelper.waitForFirebaseOperations();

        final searchResults = await repository.searchProducts('Unique Search').first;
        expect(searchResults.any((p) => p.id == testProduct.id), isTrue);
        
        TestHelper.logTestSuccess('Search Products');
      });
    });

    group('Cart Management', () {
      test('should add item to cart', () async {
        print('🛒 [CUSTOMER_TEST] Testing add item to cart...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final productId = TestHelper.generateTestId('cart_product');
        final quantity = 2;

        await repository.addToCart(testCustomerId, productId, quantity);
        
        await TestHelper.waitForFirebaseOperations();

        final cart = await repository.getCart(testCustomerId).first;
        expect(cart.items.any((item) => item.productId == productId), isTrue);
        
        TestHelper.logTestSuccess('Add Item To Cart');
      });

      test('should update cart item quantity', () async {
        print('🛒 [CUSTOMER_TEST] Testing update cart item quantity...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final productId = TestHelper.generateTestId('update_product');
        final initialQuantity = 1;
        final updatedQuantity = 3;

        // Add item to cart
        await repository.addToCart(testCustomerId, productId, initialQuantity);
        await TestHelper.waitForFirebaseOperations();

        // Update quantity
        await repository.updateCartItemQuantity(testCustomerId, productId, updatedQuantity);
        await TestHelper.waitForFirebaseOperations();

        final cart = await repository.getCart(testCustomerId).first;
        final item = cart.items.firstWhere((item) => item.productId == productId);
        expect(item.quantity, equals(updatedQuantity));
        
        TestHelper.logTestSuccess('Update Cart Item Quantity');
      });

      test('should remove item from cart', () async {
        print('🛒 [CUSTOMER_TEST] Testing remove item from cart...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final productId = TestHelper.generateTestId('remove_product');

        // Add item to cart
        await repository.addToCart(testCustomerId, productId, 1);
        await TestHelper.waitForFirebaseOperations();

        // Remove item
        await repository.removeFromCart(testCustomerId, productId);
        await TestHelper.waitForFirebaseOperations();

        final cart = await repository.getCart(testCustomerId).first;
        expect(cart.items.any((item) => item.productId == productId), isFalse);
        
        TestHelper.logTestSuccess('Remove Item From Cart');
      });

      test('should clear cart', () async {
        print('🛒 [CUSTOMER_TEST] Testing clear cart...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Add items to cart
        await repository.addToCart(testCustomerId, TestHelper.generateTestId('product1'), 1);
        await repository.addToCart(testCustomerId, TestHelper.generateTestId('product2'), 2);
        await TestHelper.waitForFirebaseOperations();

        // Clear cart
        await repository.clearCart(testCustomerId);
        await TestHelper.waitForFirebaseOperations();

        final cart = await repository.getCart(testCustomerId).first;
        expect(cart.items, isEmpty);
        
        TestHelper.logTestSuccess('Clear Cart');
      });
    });

    group('Order Management', () {
      test('should create order', () async {
        print('🛒 [CUSTOMER_TEST] Testing create order...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Add items to cart first
        final productId = TestHelper.generateTestId('order_product');
        await repository.addToCart(testCustomerId, productId, 2);
        await TestHelper.waitForFirebaseOperations();

        final order = await repository.createOrder(testCustomerId, 'Test Address');
        await TestHelper.waitForFirebaseOperations();

        expect(order.customerId, equals(testCustomerId));
        expect(order.status, equals('pending'));
        expect(order.items, isNotEmpty);
        
        TestHelper.logTestSuccess('Create Order');
      });

      test('should get customer orders', () async {
        print('🛒 [CUSTOMER_TEST] Testing get customer orders...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test order
        final testOrder = OrderModel(
          id: TestHelper.generateTestId('order'),
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: TestHelper.generateTestId('product'),
              quantity: 1,
              price: 100.0,
            ),
          ],
          totalAmount: 100.0,
          status: 'pending',
          shippingAddress: 'Test Address',
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(testOrder.id)
            .set(testOrder.toJson());

        await TestHelper.waitForFirebaseOperations();

        final orders = await repository.getCustomerOrders(testCustomerId).first;
        expect(orders.any((o) => o.id == testOrder.id), isTrue);
        
        TestHelper.logTestSuccess('Get Customer Orders');
      });

      test('should cancel order', () async {
        print('🛒 [CUSTOMER_TEST] Testing cancel order...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        // Create test order
        final testOrder = OrderModel(
          id: TestHelper.generateTestId('cancel_order'),
          customerId: testCustomerId,
          items: [
            OrderItem(
              productId: TestHelper.generateTestId('product'),
              quantity: 1,
              price: 100.0,
            ),
          ],
          totalAmount: 100.0,
          status: 'pending',
          shippingAddress: 'Test Address',
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(testOrder.id)
            .set(testOrder.toJson());

        await TestHelper.waitForFirebaseOperations();

        // Cancel order
        await repository.cancelOrder(testOrder.id);
        await TestHelper.waitForFirebaseOperations();

        final updatedOrder = await FirebaseFirestore.instance
            .collection('orders')
            .doc(testOrder.id)
            .get();

        expect(updatedOrder.data()?['status'], equals('cancelled'));
        
        TestHelper.logTestSuccess('Cancel Order');
      });
    });

    group('Customer Profile', () {
      test('should get customer profile', () async {
        print('🛒 [CUSTOMER_TEST] Testing get customer profile...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final profile = await repository.getCustomerProfile(testCustomerId).first;
        expect(profile, isNotNull);
        
        TestHelper.logTestSuccess('Get Customer Profile');
      });

      test('should update customer profile', () async {
        print('🛒 [CUSTOMER_TEST] Testing update customer profile...');
        
        if (!TestHelper.isFirebaseAvailable) {
          print('🛒 [CUSTOMER_TEST] ⚠️ Skipping test - Firebase not available');
          return;
        }

        final updates = {
          'name': 'Updated Customer Name',
          'phone': '+9876543210',
          'address': 'Updated Address',
        };

        await repository.updateCustomerProfile(testCustomerId, updates);
        await TestHelper.waitForFirebaseOperations();

        final updatedProfile = await repository.getCustomerProfile(testCustomerId).first;
        expect(updatedProfile.name, equals('Updated Customer Name'));
        
        TestHelper.logTestSuccess('Update Customer Profile');
      });
    });
  });
} 