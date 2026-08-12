import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/features/menu/models/menu_item_model.dart';

class MenuItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MenuItem>> fetchMenuItems(String placeId) async {
    final snapshot = await _firestore
        .collection('places')
        .doc(placeId)
        .collection('menuItems')
        .get();
    return snapshot.docs.map((doc) => MenuItem.fromDoc(doc)).toList();
  }

  Future<void> addMenuItem(String placeId, MenuItem item) async {
    await _firestore
        .collection('places')
        .doc(placeId)
        .collection('menuItems')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> updateMenuItem(String placeId, MenuItem item) async {
    await _firestore
        .collection('places')
        .doc(placeId)
        .collection('menuItems')
        .doc(item.id)
        .update(item.toMap());
  }

  Future<void> deleteMenuItem(String placeId, String menuItemId) async {
    await _firestore
        .collection('places')
        .doc(placeId)
        .collection('menuItems')
        .doc(menuItemId)
        .delete();
  }
}