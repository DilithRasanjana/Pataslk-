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

     // Extract address safely
    final String address = bookingData['address'] as String? ?? 
                         (bookingData['location'] is Map ? 
                           bookingData['location']['address'] as String? : null) ?? 
                         'Address not available';
    
    // Extract booking ID and customer name
    final String bookingId = bookingData['bookingId'] as String? ?? 
                           bookingData['referenceCode'] as String? ?? 
                           'Unknown';
    final String customerName = bookingData['customerName'] as String? ?? 'Customer';
    
    return BookingLocationMapScreen(
      key: key,
      location: location,
      address: address,
      bookingId: bookingId,
      customerName: customerName,
    );
  } 

  @override
  State<BookingLocationMapScreen> createState() => _BookingLocationMapScreenState();
}

class _BookingLocationMapScreenState extends State<BookingLocationMapScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  double _currentZoom = 15.0;

  // Helper function to open map directions
  Future<void> _openMapDirections() async {
    final String googleMapsUrl = 
        'https://www.google.com/maps/dir/?api=1&destination=${widget.location.latitude},${widget.location.longitude}';
    
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps app')),
        );
      }
    }
  }
    