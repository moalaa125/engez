import 'package:flutter_bloc/flutter_bloc.dart';
import 'select_category_state.dart';

class SelectCategoryCubit extends Cubit<SelectCategoryState> {
  SelectCategoryCubit() : super(SelectCategoryState(selectedIndex: 0));

  void selectCategory(int index) {
    emit(SelectCategoryState(selectedIndex: index));
  }
}
