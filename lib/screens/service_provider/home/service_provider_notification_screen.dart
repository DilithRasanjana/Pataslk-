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

  Widget _buildNotificationCard({
    required Map<String, dynamic> notification, 
    required String notificationId
  }) {
    final DateTime createdAt = (notification['createdAt'] as Timestamp).toDate();
    final String formattedTime = DateFormat('dd MMM, hh:mm a').format(createdAt);
    final String title = notification['title'] ?? 'Notification';
    final String message = notification['message'] ?? '';
    final String type = notification['type'] ?? 'general';
    final String? bookingId = notification['bookingId'];
    final double? amount = notification['amount'];
    
    // Choose icon based on notification type
    IconData notificationIcon;
    Color iconColor;
    
    switch (type) {
      case 'payment':
        notificationIcon = Icons.payments;
        iconColor = Colors.green;
        break;
      case 'new_booking':
        notificationIcon = Icons.assignment;
        iconColor = Colors.blue;
        break;
      case 'status_change':
        notificationIcon = Icons.update;
        iconColor = Colors.orange;
        break;
      default:
        notificationIcon = Icons.notifications;
        iconColor = Colors.blue[700]!;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              if (bookingId != null) {
                _navigateToBookingDetails(bookingId);
              }
            },
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              radius: 24,
              child: Icon(notificationIcon, color: iconColor),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(message),
                const SizedBox(height: 8),
                Text(
                  formattedTime,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    _deleteNotification(notificationId);
                  },
                ),
              ],
            ),
          ),
          
          // If this is a payment notification, show the amount
          if (type == 'payment' && amount != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Rs ${amount.toStringAsFixed(2)} added to your account',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Assets-main/Assets-main/No notofications.png',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceProviderHomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Go to Home',
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

   // Firebase batch operation to mark multiple notifications as read
  Future<void> _markNotificationsAsRead(List<QueryDocumentSnapshot> notifications) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (final doc in notifications) {
      final notificationData = doc.data() as Map<String, dynamic>;
      if (notificationData['read'] != true) {
        batch.update(doc.reference, {'read': true});
      }
    }
    
    await batch.commit();
  }
  
  // Firebase delete operation to remove a notification
  Future<void> _deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('provider_notifications')
        .doc(notificationId)
        .delete();
  }
  
  void _navigateToBookingDetails(String bookingId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProviderOrderDetailScreen(
          bookingId: bookingId,
        ),
      ),
    );
  }
}

