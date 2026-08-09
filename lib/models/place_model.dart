import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String title;
  final double rating;
  final String category;
  final String imagePath;
  final String description; 
  final String ownerId;     
  final String location;    

  Place({
    required this.id,
    required this.title,
    required this.rating,
    required this.category,
    required this.imagePath,
    this.description = '',
    this.ownerId = '',
    this.location = '',
  });

  factory Place.fromDoc(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String imgPath = data['imagePath'] ?? data['image_path'] ?? 'placeholder.png';

    return Place(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      imagePath: imgPath,
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'rating': rating,
      'category': category,
      'imagePath': imagePath,
      'description': description,
      'ownerId': ownerId,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}