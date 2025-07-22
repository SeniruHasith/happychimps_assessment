import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../errors/failures.dart';

class LocationService {
  Future<bool> _handlePermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled. Please enable the services in your device settings to use this feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show rationale before requesting permission
      final bool shouldRequest = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs access to location to show you relevant products and services near you. '
            'Your location data will only be used within the app.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Allow'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ) ?? false;

      if (!shouldRequest) {
        return false;
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
            'Location permissions are permanently denied. Please enable them in your device settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      final hasPermission = await _handlePermission(context);
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw const LocationFailure(
        message: 'Failed to get current location',
      );
    }
  }

  Future<String> getCityName(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ?? place.subAdministrativeArea ?? 'Unknown';
      }

      return 'Unknown';
    } catch (e) {
      throw const LocationFailure(
        message: 'Failed to get city name from coordinates',
      );
    }
  }
} 