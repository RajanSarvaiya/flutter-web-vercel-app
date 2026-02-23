enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final String? size;
  final String? color;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
      'size': size,
      'color': color,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      size: map['size'],
      color: map['color'],
    );
  }
}

class Order {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingAddressId;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.shippingAddressId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status.name,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddressId': shippingAddressId,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      status: OrderStatus.values.byName(map['status']),
      items: List<OrderItem>.from(map['items']?.map((x) => OrderItem.fromMap(x)) ?? []),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      shippingAddressId: map['shippingAddressId'] ?? '',
    );
  }

  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.returned: return 'Returned';
    }
  }
}
