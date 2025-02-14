import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'rating_screen.dart';
import 'refer_friend_screen.dart';
import 'contact_us_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Section
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint('Profile tapped'); // Debug print
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Your Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items
            _buildMenuItem(
              Icons.home_outlined,
              'Home',
              () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),

            _buildMenuItem(
              Icons.payment_outlined,
              'Payments Methods',
              () {
                // TODO: Implement payments methods navigation
              },
            ),

            _buildMenuItem(
              Icons.notifications_outlined,
              'Notification',
              () {
                // TODO: Implement notification navigation
              },
            ),

            _buildMenuItem(
              Icons.star_outline,
              'Rate',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RatingScreen()),
                );
              },
            ),

            _buildMenuItem(
              Icons.person_add_outlined,
              'Refer a Friend',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReferFriendScreen()),
                );
              },
            ),

            _buildMenuItem(
              Icons.support_agent_outlined,
              'Support',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                );
              },
            ),

            const Spacer(),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
