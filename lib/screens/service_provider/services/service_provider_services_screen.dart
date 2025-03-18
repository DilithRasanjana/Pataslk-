import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'service_provider_order_detail_screen.dart'; 

class ServiceProviderServicesScreen extends StatelessWidget {
  const ServiceProviderServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderServicesScreen> createState() =>
      _ServiceProviderServicesScreenState();
}

class _ServiceProviderServicesScreenState
    extends State<ServiceProviderServicesScreen> {
  // Firebase Auth: Get current authenticated user
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  
  @override
  void initState() {
    super.initState();
    _listenForBookingStatusChanges();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your bookings.'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Bookings',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0D47A1),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
              Tab(text: 'Draft'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // UPCOMING: Pending, InProgress and PendingApproval (moved from History to Upcoming)
            _buildBookingsList(
              statusList: ['Pending', 'InProgress', 'PendingApproval'],
              emptyTitle: 'No Upcoming Order',
              emptyMessage:
                  'Currently you don\'t have any upcoming order.\nPlace and track your orders from here.',
            ),

            // HISTORY: Only Completed now
            _buildBookingsList(
              statusList: ['Completed'],
              emptyTitle: 'No History Order',
              emptyMessage:
                  'Currently you don\'t have any completed order.\nPlace and track your orders from here.',
            ),

            // DRAFT: Draft (unchanged)
            _buildBookingsList(
              statusList: ['Draft'],
              emptyTitle: 'No Draft Order',
              emptyMessage:
                  'Currently you don\'t have any draft order.\nPlace and track your orders from here.',
            ),
          ],
        ),
      ),
    );
  }

  
  /// Builds a list of bookings from Firestore for the current provider
  /// that match the given [statusList].
  Widget _buildBookingsList({
    required List<String> statusList,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    return StreamBuilder<QuerySnapshot>(
      // Firebase Firestore: Query bookings collection with multiple filters
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('provider_id', isEqualTo: _currentUser!.uid)
          .where('status', whereIn: statusList)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _buildEmptyState(emptyTitle, emptyMessage);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return _buildBookingCard(doc);
          },
        );
      },
    );

      }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(  // Changed from Image.network to Image.asset
            'assets/Assets-main/Assets-main/service png.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // View all services functionality will be added later
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View all services',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Bookings',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0D47A1),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
              Tab(text: 'Draft'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEmptyState(
              'No Upcoming Order',
              'Currently you don\'t have any upcoming order.\nPlace and track your orders from here.',
            ),
            _buildEmptyState(
              'No History Order',
              'Currently you don\'t have any History order.\nPlace and track your orders from here.',
            ),
            _buildEmptyState(
              'No Draft Order',
              'Currently you don\'t have any draft order.\nPlace and track your orders from here.',
            ),
          ],
        ),
      ),
    );
  }
}
