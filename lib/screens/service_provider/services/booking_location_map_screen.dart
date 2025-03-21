import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingLocationMapScreen extends StatefulWidget {
  final LatLng location;
  final String address;
  final String bookingId;
  final String customerName;

  const BookingLocationMapScreen({
    super.key,
    required this.location, 
    required this.address,
    required this.bookingId,
    this.customerName = "Customer",
  });

  /// Factory constructor to create from Firestore data
  factory BookingLocationMapScreen.fromFirestoreData({
    required Map<String, dynamic> bookingData,
    Key? key,
  }) {
    // Extract location data safely
    LatLng location;
    
    try {
      // First check if location is in nested format
      if (bookingData['location'] != null) {
        final locationData = bookingData['location'];
        
        // Case 1: location is a map with latitude/longitude
        if (locationData is Map) {
          final lat = locationData['latitude'];
          final lng = locationData['longitude'];
          if (lat != null && lng != null) {
            location = LatLng(
              lat is num ? lat.toDouble() : 0.0, 
              lng is num ? lng.toDouble() : 0.0
            );
          } else {
            location = LatLng(7.8731, 80.7718); // Default
          }
        } 
        // Case 2: location is directly a LatLng object (shouldn't happen but just in case)
        else if (locationData is LatLng) {
          location = locationData;
        }
        else {
          location = LatLng(7.8731, 80.7718); // Default
        }
      } 
      // Case 3: Check for direct latitude/longitude on booking
      else if (bookingData['latitude'] != null && bookingData['longitude'] != null) {
        final lat = bookingData['latitude'];
        final lng = bookingData['longitude'];
        location = LatLng(
          lat is num ? lat.toDouble() : 0.0, 
          lng is num ? lng.toDouble() : 0.0
        );
      } 
      else {
        // Default to central Sri Lanka if no valid location
        location = LatLng(7.8731, 80.7718);
      }
    } catch (e) {
      print('Error extracting location: $e');
      location = LatLng(7.8731, 80.7718); // Default on error
    }
    