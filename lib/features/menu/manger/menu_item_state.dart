import 'package:equatable/equatable.dart';
import 'package:engez/features/menu/models/menu_item_model.dart';

abstract class MenuItemState extends Equatable {
  const MenuItemState();
  @override
  List<Object> get props => [];
}

class MenuItemInitial extends MenuItemState {}

class MenuItemLoading extends MenuItemState {}

class MenuItemLoaded extends MenuItemState {
  final List<MenuItem> items;
  const MenuItemLoaded(this.items);
  @override
  List<Object> get props => [items];
}

class MenuItemError extends MenuItemState {
  final String message;
  const MenuItemError(this.message);
  @override
  List<Object> get props => [message];
}

class MenuItemAdding extends MenuItemState {}

class MenuItemAddedSuccess extends MenuItemState {
  final String message;
  const MenuItemAddedSuccess(this.message);
  @override
  List<Object> get props => [message];
}
