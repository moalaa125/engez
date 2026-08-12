import 'package:equatable/equatable.dart';
import 'package:engez/models/place_model.dart';

abstract class PlaceState extends Equatable {
  const PlaceState();
  @override
  List<Object> get props => [];
}

class PlaceInitial extends PlaceState {}

class PlaceLoading extends PlaceState {}

class PlaceLoaded extends PlaceState {
  final List<Place> places;
  const PlaceLoaded(this.places);
  @override
  List<Object> get props => [places];
}

// حدث خطأ
class PlaceError extends PlaceState {
  final String message;
  const PlaceError(this.message);
  @override
  List<Object> get props => [message];
}

class PlaceAdding extends PlaceState {}

class PlaceAddedSuccess extends PlaceState {
  final String message;
  const PlaceAddedSuccess(this.message);
  @override
  List<Object> get props => [message];
}