import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String title;
  final String imagePath;
  final double price;
  final int quantity;
  final String placeId;

  const CartItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.price,
    required this.placeId,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      title: title,
      imagePath: imagePath,
      price: price,
      placeId: placeId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, title, imagePath, price, quantity, placeId];
}
