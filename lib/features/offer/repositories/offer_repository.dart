import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/features/offer/models/offer_model.dart';

class OfferRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OfferModel>> getOffers() {
    return _firestore.collection('offers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OfferModel.fromDocument(doc)).toList();
    });
  }
}
