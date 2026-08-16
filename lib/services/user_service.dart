import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestOwnerRole(String uid) async {
    // Add pending request to ownerRequests collection
    await _firestore
        .collection('ownerRequests')
        .doc(uid)
        .set({'status': 'pending'}, SetOptions(merge: true));

    // Ensure user role is customer while pending
    await _firestore
        .collection('users')
        .doc(uid)
        .set({'role': 'customer'}, SetOptions(merge: true));
  }

  Future<bool> hasPendingOwnerRequest(String uid) async {
    final doc = await _firestore.collection('ownerRequests').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['status'] == 'pending';
    }
    return false;
  }
}
