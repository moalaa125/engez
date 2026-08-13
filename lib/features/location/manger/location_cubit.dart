import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  Future<void> fetchCurrentLocation() async {
    emit(LocationLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const LocationError(errorMessage: 'خدمة الموقع مغلقة'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const LocationError(errorMessage: 'تم رفض الصلاحية'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const LocationError(errorMessage: 'الصلاحية مرفوضة نهائياً'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        emit(const LocationError(errorMessage: 'لم يتم العثور على عنوان'));
        return;
      }

      final address = _extractAddress(placemarks.first);
      emit(LocationLoaded(address: address));
    } catch (e) {
      emit(const LocationError(errorMessage: 'فشل جلب العنوان'));
    }
  }

  String _extractAddress(Placemark place) {
    final candidates = [
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate;
      }
    }

    return 'موقع غير معروف';
  }
}
