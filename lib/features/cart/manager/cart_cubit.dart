import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  bool addItem(CartItem newItem) {
    if (state.items.isNotEmpty && state.items.first.placeId != newItem.placeId) {
      return false;
    }

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == newItem.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + newItem.quantity,
      );
    } else {
      items.add(newItem);
    }

    emit(CartState(items: items));
    return true;
  }

  void clearAndAddItem(CartItem newItem) {
    emit(CartState(items: [newItem]));
  }

  void incrementItem(String id) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    emit(CartState(items: items));
  }

  void decrementItem(String id) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    }
    emit(CartState(items: items));
  }

  void removeItem(String id) {
    final items = List<CartItem>.from(state.items)
      ..removeWhere((item) => item.id == id);
    emit(CartState(items: items));
  }

  void clearCart() {
    emit(const CartState());
  }
}
