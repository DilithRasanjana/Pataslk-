import 'package:flutter/material.dart';
import 'add_photos_screen.dart';
import 'booking_details_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceName;
  final String serviceType;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    required this.serviceType,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDraft = false;

  String get _headerImage {
    switch (widget.serviceName) {
      case 'AC Repair':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/ac%20repair.png';
      case 'Beauty':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/beauty.jpg';
      case 'Appliance':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/applience%20service.jpg';
      case 'Painting':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/painting%20service.jpg';
      case 'Cleaning':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/cleaning%20service.jpg';
      case 'Plumbing':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/plumbing%20service.jpg';
      case 'Electronics':
        return 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/electrical%20service.jpg';
      default:
        return '';
    }
  }

  String get _serviceTitle {
    return '${widget.serviceName} ${widget.serviceType}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Header Image
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_headerImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Title
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Text(
                    _serviceTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Photos Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPhotosScreen(
                            serviceName: widget.serviceName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE5D9),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate_outlined),
                        SizedBox(width: 8),
                        Text(
                          'Add photos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description Section
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue[800],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description Text Editor
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.format_bold),
                                onPressed: () {},
                                color: Colors.grey[700],
                              ),
                              IconButton(
                                icon: const Icon(Icons.format_italic),
                                onPressed: () {},
                                color: Colors.grey[700],
                              ),
                              IconButton(
                                icon: const Icon(Icons.format_underline),
                                onPressed: () {},
                                color: Colors.grey[700],
                              ),
                              IconButton(
                                icon: const Icon(Icons.insert_emoticon),
                                onPressed: () {},
                                color: Colors.grey[700],
                              ),
                              IconButton(
                                icon: const Icon(Icons.link),
                                onPressed: () {},
                                color: Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            hintText: 'Enter description...',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Service Charge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service charge:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Rs 1000.00',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.orange[400],
                          ),
                          Text(
                            'Bill Details',
                            style: TextStyle(
                              color: Colors.orange[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() => _isDraft = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Draft saved'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: const Text('Save Draft'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsScreen(
                                  serviceName: widget.serviceName,
                                  amount:
                                      1000.00, // TODO: Replace with actual service amount
                                  serviceType:
                                      widget.serviceType, // Pass service type
                                  description: _descriptionController
                                      .text, // Pass description
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
