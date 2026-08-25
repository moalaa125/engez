import 'package:geolocator/geolocator.dart';
import 'package:engez/models/place_model.dart';

class DistanceUtils {
  static String calculateETA(double? userLat, double? userLng, Place place) {
    if (userLat == null || userLng == null || place.branches.isEmpty) {
      return 'غير متاح';
    }

    double shortestDistance = double.infinity;

    for (var branch in place.branches) {
      double distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        branch.latitude,
        branch.longitude,
      );
      if (distance < shortestDistance) {
        shortestDistance = distance;
      }
    }

    if (shortestDistance == double.infinity) return 'غير متاح';

    // Assumption: ~3 minutes per km (20 km/h) + 10 mins prep time
    int minutes = ((shortestDistance / 1000) * 3).ceil() + 10;
    
    return '$minutes دقيقة';
  }
}
