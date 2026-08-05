import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/models/place_model.dart';

class PlaceService {
  Future<List<Place>> fetchPlaces() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('places')
        .get();
    return snapshot.docs.map((doc) => Place.fromDoc(doc)).toList();
  }
}