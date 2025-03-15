import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatusScreen extends StatelessWidget {
  final String address;
  final String serviceType;
  final String jobRole;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String description;

  const OrderStatusScreen({
    Key? key,
    required this.address,
    required this.serviceType,
    required this.jobRole,
    required this.selectedDate,
    required this.selectedTime,
    required this.description,
  }) : super(key: key);

  String _extractDistrict(String address) {
    // Look for the word "District" in the address
    final List<String> parts = address.split(',');
    for (String part in parts) {
      part = part.trim();
      if (part.contains('District')) {
        return part;
      }
    }
    return 'District not specified';
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
              // Status Section
              Row(
                children: [
                  const Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We have received your order and will get back\nto you as soon as the order is reviewed.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Address Section with actual address
              _buildInfoSection(
                'Address:',
                address,
              ),

              // District Section (new)
              _buildInfoSection(
                'District:',
                district,
              ),

              // Service Type Section with null check
              _buildInfoSection(
                'Service Type:',
                serviceType.isNotEmpty ? serviceType : 'Not specified',
              ),

              // Job Role Section
              _buildInfoSection(
                'Job Role:',
                jobRole,
              ),

              // Order Date Section with formatted date and time
              _buildInfoSection(
                'Order Date:',
                '${DateFormat('MMM d, yyyy').format(selectedDate)} at ${selectedTime.format(context)}',
              ),

              // Details Section with description
              _buildInfoSection(
                'Details:',
                description.isNotEmpty
                    ? description
                    : 'No description provided',
              ),

              // Attachments Section
              _buildInfoSection('Attachments', ''),

              // Service Charge Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Service charge:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Rs 1000.00',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            // Show bill details
                          },
                          child: Row(
                            children: const [
                              Text(
                                'Bill Details',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to home screen
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to home screen
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.isNotEmpty ? content : 'No description provided',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
