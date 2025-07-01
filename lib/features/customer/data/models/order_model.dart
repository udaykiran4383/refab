enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String customerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingAddress;
  final OrderStatus status;
  final String? paymentId;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    this.paymentId,
    required this.orderDate,
    this.deliveryDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerId: json['customerId'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      shippingAddress: json['shippingAddress'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      paymentId: json['paymentId'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null 
          ? DateTime.parse(json['deliveryDate']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'status': status.toString().split('.').last,
      'paymentId': paymentId,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    List<OrderItem>? items,
    double? totalAmount,
    String? shippingAddress,
    OrderStatus? status,
    String? paymentId,
    DateTime? orderDate,
    DateTime? deliveryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      unitPrice: json['unitPrice'].toDouble(),
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
} 