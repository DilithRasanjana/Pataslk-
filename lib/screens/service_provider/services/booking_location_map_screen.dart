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