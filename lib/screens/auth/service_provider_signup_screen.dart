// Firebase Firestore package for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication package for user authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'service_provider_login_screen.dart';
// Helper utility for Firebase Authentication operations
import '../../utils/firebase_auth_helper.dart';
// Helper utility for Firebase Firestore database operations
import '../../utils/firebase_firestore_helper.dart';
import '../service_provider/home/service_provider_home_screen.dart';
import './service_provider_verification_screen.dart';

class ServiceProviderSignupScreen extends StatefulWidget {
  const ServiceProviderSignupScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderSignupScreen> createState() =>
      _ServiceProviderSignupScreenState();
}

class _ServiceProviderSignupScreenState extends State<ServiceProviderSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  // Firebase Authentication helper instance
  final FirebaseAuthHelper _authHelper = FirebaseAuthHelper();
  // Firebase Firestore helper instance
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  bool _isProcessing = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    // Expect exactly 9 digits (without a leading 0)
    return RegExp(r'^[1-9]\d{8}$').hasMatch(phone);
  }

  /// Helper to format the input phone number to E.164 format.
  String formatPhoneNumber(String input) {
    String trimmed = input.trim().replaceAll(RegExp(r'\s+|-'), '');
    if (trimmed.startsWith('0')) {
      trimmed = trimmed.substring(1);
    }
    return '+94$trimmed';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Firebase Firestore: Check if user with this email already exists
      bool exists = await _firestoreHelper.doesUserExist(
        collection: 'serviceProviders',
        email: _emailController.text.trim(),
      );
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("User already exists. Please sign in.")),
        );
        return;
      }
      
      setState(() {
        _isProcessing = true;
      });
      
      String rawPhone = _phoneController.text;
      if (!isValidPhone(rawPhone)) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enter a valid 9-digit phone number")),
        );
        return;
      }
      
      String fullPhone = formatPhoneNumber(rawPhone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please fill in the form to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name Field
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mobile Number Field
                TextFormField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter your 10-digit mobile number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: '+94 ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ServiceProviderVerificationScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ServiceProviderLoginScreen(),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
