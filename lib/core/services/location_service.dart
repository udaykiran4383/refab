import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    print('📍 [LOCATION SERVICE] Requesting location permission...');
    final status = await Permission.location.request();
    print('📍 [LOCATION SERVICE] Permission status: $status');
    return status == PermissionStatus.granted;
  }

  static Future<Position?> getCurrentLocation() async {
    print('📍 [LOCATION SERVICE] getCurrentLocation called');
    try {
      final hasPermission = await requestLocationPermission();
      print('📍 [LOCATION SERVICE] Has permission: $hasPermission');
      
      if (!hasPermission) {
        print('📍 [LOCATION SERVICE] Permission denied');
        return null;
      }

      print('📍 [LOCATION SERVICE] Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('📍 [LOCATION SERVICE] Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('📍 [LOCATION SERVICE] Error getting location: $e');
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    print('📍 [LOCATION SERVICE] Converting coordinates to address: $latitude, $longitude');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      print('📍 [LOCATION SERVICE] Placemarks found: ${placemarks.length}');
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
        print('📍 [LOCATION SERVICE] Address generated: $address');
        return address;
      }
      print('📍 [LOCATION SERVICE] No placemarks found');
      return null;
    } catch (e) {
      print('📍 [LOCATION SERVICE] Error in geocoding: $e');
      return null;
    }
  }

  static Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  static Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
