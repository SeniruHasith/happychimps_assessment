import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../errors/failures.dart';
import 'permission_handler.dart';

class LocationService {
  Future<Position> getCurrentPosition(BuildContext context) async {
    final hasPermission = await PermissionHandler.requestLocationPermission(context);
    if (!hasPermission) {
      throw const LocationFailure(
        message: 'Location permission is required to use this feature',
      );
    }

    try {
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