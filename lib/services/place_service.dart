import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/models/place_model.dart';

class PlaceService {
  Future<List<Place>> fetchPlaces() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('places')
        .get();
    return snapshot.docs.map((doc) => Place.fromDoc(doc)).toList();
  }


   Future<void> addPlace(Place place) async {
    await FirebaseFirestore.instance
        .collection('places')
        .doc(place.id)
        .set(place.toMap()); 
  }

  Future<void> updatePlace(Place place) async {
    await FirebaseFirestore.instance
        .collection('places')
        .doc(place.id)
        .update({
      'title': place.title,
      'category': place.category,
      'description': place.description,
      'imagePath': place.imagePath,
      'location': place.location,
    });
  }
}