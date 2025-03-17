import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'service_provider_home_screen.dart';
import '../services/service_provider_order_detail_screen.dart';

class ServiceProviderNotificationScreen extends StatefulWidget {
  const ServiceProviderNotificationScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderNotificationScreen> createState() => _ServiceProviderNotificationScreenState();
}

class _ServiceProviderNotificationScreenState extends State<ServiceProviderNotificationScreen> {
  // Firebase Auth instance to get current user
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _sortBy = 'recent';
  
  @override
  Widget build(BuildContext context) {
    // Get the current Firebase user
    final User? currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications')),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Notification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              child: Row(
                children: [
                  Text(
                    _sortBy == 'recent' ? 'Recent' : 'Oldest',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.blue[900],
                  ),
                ],
              ),
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
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
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore query to get provider-specific notifications with real-time updates
        stream: FirebaseFirestore.instance
            .collection('provider_notifications')
            .where('providerId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: _sortBy == 'recent')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final notifications = snapshot.data?.docs ?? [];
          
          // Firestore batch update to mark notifications as read
          _markNotificationsAsRead(notifications);
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
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
