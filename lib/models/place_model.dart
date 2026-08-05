class Place {
  final String id;
  final String title;
  final double rating;
  final String category;
  final String imagePath;

  Place({
    required this.id,
    required this.title,
    required this.rating,
    required this.category,
    required this.imagePath,
  });

  factory Place.fromDoc(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String imgPath = data['image_path'] ?? 'placeholder.png'; 

    return Place(
      id: data['id'] ?? doc.id, 
      title: data['title'] ?? '', 
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      imagePath: imgPath,
    );
  }
}