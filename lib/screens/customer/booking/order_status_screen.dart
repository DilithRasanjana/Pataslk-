import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services_screen.dart';

class OrderStatusScreen extends StatelessWidget {
  // Firebase Firestore: The document ID from the 'bookings' collection
  final String bookingId;
  final String address;
  final String serviceType;
  final String jobRole;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String description;
  // Firebase Storage: URL of the image stored in Firebase Storage
  final String? uploadedImageUrl;
  final String status;

  const OrderStatusScreen({
    Key? key,
    required this.bookingId,
    required this.address,
    required this.serviceType,
    required this.jobRole,
    required this.selectedDate,
    required this.selectedTime,
    required this.description,
    this.uploadedImageUrl,
    required this.status, 
  }) : super(key: key);

  String _extractDistrict(String address) {
    final List<String> parts = address.split(',');
    for (String part in parts) {
      part = part.trim();
      if (part.contains('District')) {
        return part;
      }
    }
    return 'District not specified';
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'InProgress':
        return Colors.blue;
      case 'PendingApproval':
        return Colors.amber;
      case 'Completed':
        return Colors.green;
      case 'Incomplete':
        return Colors.red;
      case 'Expired':
        return Colors.grey;
      case 'Draft':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  // Helper method to get status display text
  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'InProgress':
        return 'In Progress';
      case 'PendingApproval':
        return 'Pending Approval';
      default:
        return status;
    }
  }

  // Helper method to get status description
  String _getStatusDescription(String status) {
    switch (status) {
      case 'Pending':
        return 'Your order is still pending. The service provider has not yet started the job.';
      case 'InProgress':
        return 'Your service is currently in progress. The service provider is working on your request.';
      case 'PendingApproval':
        return 'The service provider has marked this job as complete. Please review and approve the completion.';
      case 'Completed':
        return 'This service has been successfully completed and approved.';
      case 'Incomplete':
        return 'This service was marked as incomplete. You can contact customer support for assistance.';
      case 'Expired':
        return 'This booking has expired due to no response or activity.';
      case 'Draft':
        return 'This is a draft booking that has not been submitted yet.';
      default:
        return 'Status information unavailable.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String district = _extractDistrict(address);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Order Status'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Section - Now using dynamic status
              Row(
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusDisplayText(status), // Use dynamic status
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusDescription(status), // Use dynamic status description
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              // Display booking details from Firestore document
              _buildInfoSection('Address:', address),
              _buildInfoSection('District:', district),
              _buildInfoSection('Service Type:', serviceType.isNotEmpty ? serviceType : 'Not specified'),
              _buildInfoSection('Job Role:', jobRole),
              _buildInfoSection('Order Date:', '${DateFormat('MMM d, yyyy').format(selectedDate)} at ${selectedTime.format(context)}'),
              _buildInfoSection('Details:', description.isNotEmpty ? description : 'No description provided'),
              _buildInfoSection('Attachments:', ''),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Service charge:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        Text(
                          'Rs 1000.00',
                          style: TextStyle(fontSize: 16, color: Colors.grey[800], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            // Show bill details if needed.
                          },
                          child: Row(
                            children: const [
                              Text('Bill Details', style: TextStyle(color: Colors.blue)),
                              Icon(Icons.keyboard_arrow_up, color: Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServicesScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Check Bookings',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            content.isNotEmpty ? content : 'No description provided',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
