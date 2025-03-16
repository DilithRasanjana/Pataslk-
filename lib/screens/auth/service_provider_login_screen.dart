// Firebase Firestore package for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication package for user authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../service_provider/home/service_provider_home_screen.dart';
import 'service_provider_signup_screen.dart';
import 'service_provider_verification_screen.dart';
// Helper utility for Firebase Authentication operations
import '../../utils/firebase_auth_helper.dart';
// Helper utility for Firestore database operations
import '../../utils/firebase_firestore_helper.dart';

class ServiceProviderLoginScreen extends StatefulWidget {
  const ServiceProviderLoginScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderLoginScreen> createState() =>
      _ServiceProviderLoginScreenState();
}

class _ServiceProviderLoginScreenState extends State<ServiceProviderLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  // Firebase Authentication helper instance
  final FirebaseAuthHelper _authHelper = FirebaseAuthHelper();
  // Firebase Firestore helper instance
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  bool _isLoading = false;

  /// Helper method to format phone number with country code.
  String _formatPhoneNumber(String raw) {
    // For simplicity, just prepend +94. (Ensure your raw number has 9 digits.)
    return '+94' + raw.trim();
  }


  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 24,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/Assets-main/Assets-main/logo 2.png', // Updated to use local asset
                  height: 120,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/Assets-main/Assets-main/circle 1.png', // Updated to use local asset
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '+94',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServiceProviderHomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Sign in with',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          FontAwesomeIcons.google,
                          () {
                            // Google sign in will be implemented later
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          FontAwesomeIcons.facebook,
                          () {
                            // Facebook sign in will be implemented later
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          FontAwesomeIcons.apple,
                          () {
                            // Apple sign in will be implemented later
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Create a New Account? ',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ServiceProviderSignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.bold,
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
}
