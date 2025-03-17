import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../location/location_picker_screen.dart';
import '../payment/payment_screen.dart';
import 'order_status_screen.dart'; // Add this import

class BookingDetailsScreen extends StatefulWidget {
  final String serviceName;
  final double amount;
  final String serviceType; // Add this
  final String description; // Add this
  final String? uploadedImageUrl;

  const BookingDetailsScreen({
    Key? key,
    required this.serviceName,
    required this.amount,
    this.serviceType = '', // Default value
    this.description = '', // Default value
    this.uploadedImageUrl,
  }) ; 

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDetails = false;
  LatLng? selectedLocation;
  String? selectedAddress;
  bool _isMounted = true; // Track if widget is mounted

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

   // Create booking in Firestore and return the doc ID
  Future<String?> _createBooking() async {
    try {
      // Firebase Authentication: Get current logged in user
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // If not logged in, return null or show an error
        return null;
      }
       // Firebase Firestore: Create reference to 'bookings' collection
      final CollectionReference bookingsRef =
          FirebaseFirestore.instance.collection('bookings');
      final docRef = bookingsRef.doc(); // Create Firestore document reference
      final referenceCode = docRef.id; // Use Firestore document ID as reference code

      // Prepare data for Firestore document
      final bookingData = {
        'customer_id': currentUser.uid,  // Store Firebase user ID
        'provider_id': null, // set later by the service provider
        'providerName': '',  // set later by the service provider
        'referenceCode': referenceCode,
        'serviceName': widget.serviceName,
        'serviceType': widget.serviceType,
        'description': widget.description,
        'amount': widget.amount,
        'bookingDate':
            selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,  // Firebase Timestamp
        'bookingTime':
            selectedTime != null ? selectedTime!.format(context) : null,
        'location': selectedAddress,
        'status': 'Pending',
        'createdAt': Timestamp.now(),  // Firebase server timestamp
        'imageUrl': widget.uploadedImageUrl,  // Store the image URL in the booking document
      
    };
      // Firebase Firestore: Write data to the database
      await docRef.set(bookingData);
      return docRef.id;  // Return Firebase document ID
    } catch (e) {
      // Use a logger instead of print in production
      debugPrint('Error creating booking: $e');
      return null;
    }
  
    }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result['coordinates'] as LatLng;
        selectedAddress = result['address'] as String;

        
      });
    }
  }
   // Add payment method and navigation with mounted check
  Future<void> _addPaymentMethod() async {
    if (selectedDate == null || selectedTime == null || selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

     setState(() {
      _isLoading = true;
    });
    
    // Firebase: Create booking record in Firestore
    String? bookingId = await _createBooking();
    
    // Check if widget is still mounted before using context
    if (!_isMounted) return;
    
    setState(() {
      _isLoading = false;
    }); 

    if (bookingId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            amount: widget.amount,
            bookingId: bookingId,  // Pass Firebase document ID
            onPaymentSuccess: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderStatusScreen(
                    bookingId: bookingId,
                    address: selectedAddress!,
                    serviceType: widget.serviceType,
                    jobRole: widget.serviceName,
                    selectedDate: selectedDate!,
                    selectedTime: selectedTime!,
                    description: widget.description,
                    uploadedImageUrl: widget.uploadedImageUrl, // Pass the image URL properly
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.serviceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your Date & Time?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Date Selection
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD7C2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate != null
                          ? DateFormat('MMM d, yyyy').format(selectedDate!)
                          : 'Select your Date',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Time Selection
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1F5D3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Select your Time',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Updated Location Selection
            InkWell(
              onTap: () => _selectLocation(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFB7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedLocation != null
                                ? 'Selected Location'
                                : 'Select your Location',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedAddress != null &&
                        selectedAddress!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        selectedAddress!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Total Amount Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Rs ${widget.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                showDetails = !showDetails;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.orange[300],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  showDetails
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.orange[300],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showDetails) ...[
                    const SizedBox(height: 16),
                    // Add your detailed breakdown here
                    const Text('Service charge: Rs 800.00'),
                    const Text('Tax: Rs 200.00'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pay Order Button
            ElevatedButton(
              onPressed: () {
                if (selectedDate == null ||
                    selectedTime == null ||
                    selectedAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Debug prints to verify data
                print('Service Type: ${widget.serviceType}');
                print('Description: ${widget.description}');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      amount: widget.amount,
                      onPaymentSuccess: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderStatusScreen(
                              address: selectedAddress!,
                              serviceType: widget.serviceType,
                              jobRole: widget.serviceName,
                              selectedDate: selectedDate!,
                              selectedTime: selectedTime!,
                              description: widget.description,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pay order',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
