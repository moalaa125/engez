import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final String address;
  final double latitude;
  final double longitude;

  const LocationLoaded({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [address, latitude, longitude];
}

class LocationError extends LocationState {
  final String errorMessage;

  const LocationError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
