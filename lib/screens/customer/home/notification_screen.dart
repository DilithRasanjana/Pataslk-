import 'package:flutter/material.dart';
// Firebase imports for Firestore database access
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication import for user management
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services_screen.dart';
import '../booking/order_status_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

   @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Firebase Auth instance for user authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _sortBy = 'recent';

  @override
  Widget build(BuildContext context) {
    // Get current authenticated Firebase user
    final User? currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
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
              'Notification',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Text(
              'Recent',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onSelected: (value) {
              // Handle filter selection
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Text('Recent'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Oldest'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
     
      body: StreamBuilder<QuerySnapshot>(
        // Firebase Firestore query to get user-specific notifications with ordering
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: _sortBy == 'recent')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          // Access Firebase documents from snapshot
          final notifications = snapshot.data?.docs ?? [];
          
          // Mark all unread notifications as read in Firestore
          _markNotificationsAsRead(notifications);
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              // Extract Firebase document data
              final notification = notifications[index].data() as Map<String, dynamic>;
              return _buildNotificationCard(
                notification: notification,
                notificationId: notifications[index].id,
              );
            },
          );
        },
      ),
    );
  }