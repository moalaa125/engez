import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:engez/features/menu/models/menu_item_model.dart';
import 'package:engez/repositories/menu_item_repository.dart';
import 'menu_item_state.dart';

class MenuItemCubit extends Cubit<MenuItemState> {
  final MenuItemRepository _repository;
  final String placeId;

  MenuItemCubit(this._repository, this.placeId) : super(MenuItemInitial());

  Future<void> fetchMenuItems() async {
    emit(MenuItemLoading());
    try {
      final items = await _repository.fetchMenuItems(placeId);
      emit(MenuItemLoaded(items));
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    emit(MenuItemAdding());
    try {
      await _repository.addMenuItem(placeId, item);
      emit(MenuItemAddedSuccess('تم إضافة العنصر بنجاح'));
      await fetchMenuItems();
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> updateMenuItem(MenuItem item) async {
    emit(MenuItemAdding());
    try {
      await _repository.updateMenuItem(placeId, item);
      emit(MenuItemAddedSuccess('تم تحديث العنصر بنجاح'));
      await fetchMenuItems();
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }

  Future<void> deleteMenuItem(String menuItemId) async {
    emit(MenuItemLoading());
    try {
      await _repository.deleteMenuItem(placeId, menuItemId);
      await fetchMenuItems();
    } catch (e) {
      emit(MenuItemError(e.toString()));
    }
  }
}
