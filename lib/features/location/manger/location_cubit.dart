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
      emit(LocationLoaded(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    } catch (e) {
      emit(const LocationError(errorMessage: 'فشل جلب العنوان'));
    }
  }

  String _extractAddress(Placemark place) {
    final List<String> parts = [];

    // Prioritize specific street or thoroughfare
    if (place.street != null && place.street!.trim().isNotEmpty && !place.street!.contains('Unnamed')) {
      parts.add(place.street!.trim());
    } else if (place.thoroughfare != null && place.thoroughfare!.trim().isNotEmpty) {
      parts.add(place.thoroughfare!.trim());
    }

    // Add neighborhood or sub-locality
    if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
      parts.add(place.subLocality!.trim());
    } else if (place.locality != null && place.locality!.trim().isNotEmpty) {
      parts.add(place.locality!.trim());
    }

    // If we found specific details, return them
    if (parts.isNotEmpty) {
      // Use Set to remove duplicates in case street is the same as subLocality
      return parts.toSet().toList().join('، ');
    }

    // Fallback to governorate/state
    if (place.administrativeArea != null && place.administrativeArea!.trim().isNotEmpty) {
      return place.administrativeArea!.trim();
    }

    return 'موقع غير معروف';
  }
}
