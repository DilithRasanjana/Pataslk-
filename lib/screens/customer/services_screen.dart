// Firebase Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication for user management
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'booking/order_status_screen.dart';
import 'home/home_screen.dart'; 

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  // Get current Firebase authenticated user
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _indexError = false;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      // If no user is logged in, show a placeholder or redirect to login.
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your bookings.'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bookings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          // Update the leading icon to navigate to HomeScreen
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Navigate to HomeScreen when back arrow is pressed
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue[900],
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
              Tab(text: 'Draft'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1) Upcoming tab
            _buildBookingsList(
              statusList: ['Pending', 'InProgress', 'PendingApproval'],
              emptyTitle: 'No Upcoming Orders',
              emptySubtitle:
                  'Currently you don\'t have any upcoming orders.\nPlace and track your orders from here.',
            ),
            // 2) History tab
            _buildBookingsList(
              statusList: ['Completed'],
              emptyTitle: 'No History Order',
              emptySubtitle:
                  'Currently you don\'t have any History order.\nPlace and track your orders from here.',
            ),
            // 3) Draft tab
            _buildBookingsList(
              statusList: ['Draft'],
              emptyTitle: 'No Draft Orders',
              emptySubtitle:
                  'Currently you don\'t have any draft orders.\nPlace and track your orders from here.',
            ),
          ],
        ),
      ),
    );
  }

/// Builds a list of bookings from Firestore for the current user, filtered by [statusList].
  Widget _buildBookingsList({
    required List<String> statusList,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    // Use a try-catch block with the query to handle index errors
    try {
      return StreamBuilder<QuerySnapshot>(
        // Firebase Firestore real-time stream for bookings
        stream: _getBookingsStream(statusList),
        builder: (context, snapshot) {
          // Handle Firestore index creation state
          if (_indexError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Setting up bookings...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a minute',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          }
          
          // Handle Firestore query errors
          if (snapshot.hasError) {
            // Check for Firestore index error specifically
            if (snapshot.error.toString().contains('FAILED_PRECONDITION') && 
                snapshot.error.toString().contains('index')) {
              // Set flag to show index creation message
              if (!_indexError) {
                setState(() {
                  _indexError = true;
                });
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Setting up bookings...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a minute',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              );
            }
            
            // Show other errors
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          // Process Firestore query results
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Show empty state if no bookings found.
            return _buildEmptyState(
              emptyTitle,
              emptySubtitle,
              'assets/Assets-main/Assets-main/service png.png',
            );
          }

// We have some bookings. Build a ListView.
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              _listenForStatusChanges(doc); // Listen for status changes
              return _buildBookingCard(doc, context);
            },
          );
        },
      );
    } catch (e) {
      // Catch any unexpected errors
      return Center(
        child: Text('An error occurred: $e'),
      );
    }
  }

  /// Gets the stream for bookings with error handling for missing indexes
  Stream<QuerySnapshot> _getBookingsStream(List<String> statusList) {
    try {
      // Try the original Firestore query with compound ordering and filtering
      return FirebaseFirestore.instance
          .collection('bookings')
          .where('customer_id', isEqualTo: _currentUser!.uid)
          .where('status', whereIn: statusList)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      // If Firestore query fails due to missing index, use a simpler query as fallback
      if (e.toString().contains('FAILED_PRECONDITION') && 
          e.toString().contains('index')) {
        setState(() {
          _indexError = true;
        });
        
        // Use a simpler Firestore query without the ordering
        return FirebaseFirestore.instance
            .collection('bookings')
            .where('customer_id', isEqualTo: _currentUser!.uid)
            .where('status', whereIn: statusList)
            .snapshots();
      }
      rethrow;
    }
  }

   /// Builds the empty state widget (when no bookings exist).
  Widget _buildEmptyState(String title, String subtitle, String imagePath) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 120,
            width: 120,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to HomeScreen instead of just popping
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Back to Home',  // Updated text for clarity
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }