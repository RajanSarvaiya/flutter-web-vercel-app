import 'package:flutter/material.dart';
import '../data/models/order.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [
    Order(
      id: 'ORD-2024-001',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.delivered,
      items: [
        OrderItem(
          productId: '1',
          productName: 'Classic Oxford Shirt',
          productImage: 'https://images.unsplash.com/photo-1598033129183-c4f50c7176c8?w=800',
          quantity: 1,
          price: 1299.0,
          size: 'M',
          color: 'White',
        ),
      ],
      totalAmount: 1299.0,
      shippingAddressId: 'addr1',
    ),
    Order(
      id: 'ORD-2024-002',
      date: DateTime.now().subtract(const Duration(hours: 12)),
      status: OrderStatus.shipped,
      items: [
        OrderItem(
          productId: '2',
          productName: 'Slim Fit Chinos',
          productImage: 'https://images.unsplash.com/photo-1624372333411-9e771092289f?w=800',
          quantity: 2,
          price: 1599.0,
          size: '32',
          color: 'Beige',
        ),
        OrderItem(
          productId: '3',
          productName: 'Linen Casual Shirt',
          productImage: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
          quantity: 1,
          price: 1899.0,
          size: 'L',
          color: 'Blue',
        ),
      ],
      totalAmount: 5097.0,
      shippingAddressId: 'addr2',
    ),
  ];

  List<Order> get orders => [..._orders];

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
