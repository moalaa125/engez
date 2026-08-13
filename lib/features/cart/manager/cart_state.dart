import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}
