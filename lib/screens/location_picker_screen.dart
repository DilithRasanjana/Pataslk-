import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  String? _address;
  bool _isLoading = false;
  bool _mapReady = false;

  static const LatLng _sriLankaCenter = LatLng(7.8731, 80.7718);
  static const double _defaultZoom = 8.0;

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = [
            if (place.street?.isNotEmpty ?? false) place.street,
            if (place.subLocality?.isNotEmpty ?? false) place.subLocality,
            if (place.locality?.isNotEmpty ?? false) place.locality,
            if (place.administrativeArea?.isNotEmpty ?? false)
              place.administrativeArea,
            if (place.country?.isNotEmpty ?? false) place.country,
          ].where((element) => element != null).join(', ');
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _address = 'Unable to fetch address';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _getCurrentLocation();
      if (mounted && _mapReady) {
        final userLocation = LatLng(position.latitude, position.longitude);
        // Check if the coordinates are within Sri Lanka's bounding box
        if (_isWithinSriLanka(userLocation)) {
          setState(() => _selectedLocation = userLocation);
          _mapController.move(userLocation, 15.0);
          await _getAddressFromLatLng(userLocation);
        } else {
          // If outside Sri Lanka, stay at Sri Lanka center
          setState(() => _selectedLocation = _sriLankaCenter);
          _mapController.move(_sriLankaCenter, _defaultZoom);
        }
      }
    } catch (error) {
      debugPrint('Error getting location: $error');
      // Fallback to Sri Lanka center
      if (mounted && _mapReady) {
        setState(() => _selectedLocation = _sriLankaCenter);
        _mapController.move(_sriLankaCenter, _defaultZoom);
      }
    }
  }

  bool _isWithinSriLanka(LatLng position) {
    // Sri Lanka's approximate bounding box
    const minLat = 5.916667;
    const maxLat = 9.850000;
    const minLng = 79.683333;
    const maxLng = 81.883333;

    return position.latitude >= minLat &&
        position.latitude <= maxLat &&
        position.longitude >= minLng &&
        position.longitude <= maxLng;
  }

  void _showCoordinates(LatLng position) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize with Sri Lanka center
    _selectedLocation = _sriLankaCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'coordinates': _selectedLocation,
                  'address': _address ?? 'Unknown location'
                });
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _sriLankaCenter, // Always start with Sri Lanka
              initialZoom: _defaultZoom,
              minZoom: 4.0,
              maxZoom: 18.0,
              onMapReady: () {
                setState(() => _mapReady = true);
                _initializeLocation();
              },
              onTap: (tapPosition, point) async {
                if (_isWithinSriLanka(point)) {
                  setState(() => _selectedLocation = point);
                  await _getAddressFromLatLng(point);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please select a location within Sri Lanka'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Replace the existing zoom controls Positioned widget with this:
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          var currentCenter = _mapController.camera.center;
                          var currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            currentCenter,
                            currentZoom + 1,
                          );
                        },
                      ),
                      Container(
                        height: 1,
                        width: 20,
                        color: Colors.grey[300],
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          var currentCenter = _mapController.camera.center;
                          var currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            currentCenter,
                            currentZoom - 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      Text(
                        'Address:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _address ?? 'Fetching address...',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
