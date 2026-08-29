import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Branch({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Branch.fromMap(Map<String, dynamic> data) {
    return Branch(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Place {
  final String id;
  final String title;
  final double rating;
  final String category;
  final String imagePath;
  final String description;
  final String ownerId;
  final String location; // Keeping for backward compatibility
  final List<Branch> branches;
  final bool isOpen;

  Place({
    required this.id,
    required this.title,
    required this.rating,
    required this.category,
    required this.imagePath,
    this.description = '',
    this.ownerId = '',
    this.location = '',
    this.branches = const [],
    this.isOpen = true,
  });

  factory Place.fromDoc(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;

    String imgPath =
        data['imagePath'] ?? data['image_path'] ?? 'placeholder.png';

    List<Branch> branchesList = [];
    if (data['branches'] != null) {
      branchesList = List<Branch>.from(
          (data['branches'] as List).map((x) => Branch.fromMap(x)));
    }

    return Place(
      id: data['id'] ?? doc.id,
      title: data['title'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      imagePath: imgPath,
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      location: data['location'] ?? '',
      branches: branchesList,
      isOpen: data['isOpen'] ?? true,
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
      'branches': branches.map((x) => x.toMap()).toList(),
      'isOpen': isOpen,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
