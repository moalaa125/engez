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

      await setLocaleIdentifier('ar_EG');
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

    String cleanText(String? text) {
      if (text == null) return '';
      // Remove Google Plus Codes like "Q2P2+R65" or "Q2P2+R65, "
      return text.replaceAll(RegExp(r'[A-Z0-9]{2,}\+[A-Z0-9]+\s*,?\s*'), '').trim();
    }

    final street = cleanText(place.street);
    if (street.isNotEmpty && !street.toLowerCase().contains('unnamed')) {
      parts.add(street);
    } else {
      final thoroughfare = cleanText(place.thoroughfare);
      if (thoroughfare.isNotEmpty && !thoroughfare.toLowerCase().contains('unnamed')) {
        parts.add(thoroughfare);
      }
    }

    final subLocality = cleanText(place.subLocality);
    if (subLocality.isNotEmpty) {
      parts.add(subLocality);
    } else {
      final locality = cleanText(place.locality);
      if (locality.isNotEmpty) {
        parts.add(locality);
      }
    }

    if (parts.isNotEmpty) {
      return parts.toSet().toList().join('، ');
    }

    final adminArea = cleanText(place.administrativeArea);
    if (adminArea.isNotEmpty) {
      return adminArea;
    }

    return 'موقع غير معروف';
  }
}
