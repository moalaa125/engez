import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/repositories/place_repository.dart';
import 'place_state.dart';

class PlaceCubit extends Cubit<PlaceState> {
  final PlaceRepository _repository;

  PlaceCubit(this._repository) : super(PlaceInitial());

  Future<void> fetchPlaces() async {
    emit(PlaceLoading());
    try {
      final places = await _repository.fetchPlaces();
      emit(PlaceLoaded(places));
    } catch (e) {
      emit(PlaceError(e.toString()));
    }
  }

  Future<void> addPlace(Place place) async {
    emit(PlaceAdding());
    try {
      await _repository.addPlace(place);
      emit(PlaceAddedSuccess('تم إضافة المكان بنجاح'));
      await fetchPlaces();
    } catch (e) {
      emit(PlaceError(e.toString()));
    }
  }

  /// تحديث مكان
  Future<void> updatePlace(Place place) async {
    emit(PlaceAdding());
    try {
      await _repository.updatePlace(place);
      emit(PlaceAddedSuccess('تم تحديث المكان بنجاح'));
      await fetchPlaces();
    } catch (e) {
      emit(PlaceError(e.toString()));
    }
  }

  Future<void> refreshPlaces() async {
    await fetchPlaces();
  }
}