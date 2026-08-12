import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final double price;

  MenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.price,
  });

  factory MenuItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}