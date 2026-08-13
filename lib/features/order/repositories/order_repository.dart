import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/features/order/models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').add(order.toMap());
  }

  Stream<List<OrderModel>> getCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromDocument(doc)).toList());
  }

  Stream<List<OrderModel>> getPlaceOrders(String placeId) {
    return _firestore
        .collection('orders')
        .where('placeId', isEqualTo: placeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromDocument(doc)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({'status': newStatus});
  }
}
