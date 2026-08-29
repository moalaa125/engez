import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String menuItemId;
  final String title;
  final double price;
  final int quantity;

  OrderItem({
    required this.menuItemId,
    required this.title,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String placeId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final int? estimatedPreparationTime;
  final DateTime? acceptedAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.placeId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.estimatedPreparationTime,
    this.acceptedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'placeId': placeId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'estimatedPreparationTime': estimatedPreparationTime,
      'acceptedAt': acceptedAt,
      'notes': notes,
    };
  }

  factory OrderModel.fromDocument(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: map['customerId'] ?? '',
      placeId: map['placeId'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] as List? ?? []).map((x) => OrderItem.fromMap(x)),
      ),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedPreparationTime: map['estimatedPreparationTime'] as int?,
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      notes: map['notes'] as String?,
    );
  }
}

