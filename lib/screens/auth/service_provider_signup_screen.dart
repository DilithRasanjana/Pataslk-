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

  // Job role dropdown field.
  final List<String> _jobRoles = [
    'AC Repair',
    'Beauty',
    'Appliance',
    'Painting',
    'Cleaning',
    'Plumbing',
    'Electronics',
    'Shifting',
    "Men's Salon"
  ];
  String _selectedJobRole = 'AC Repair';

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
      
      // Show a loading dialog.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Sending verification code..."),
                ],
              ),
            ),
          );
        },
      );
      
      // Firebase Authentication: Start phone verification process
      await _authHelper.verifyPhoneNumber(
        phoneNumber: fullPhone,
        // Firebase Authentication: Handle successful SMS code sending
        onCodeSent: (String verificationId, int? forceResendingToken) {
          setState(() {
            _isProcessing = false;
          });
          Navigator.of(context).pop(); // Close loading dialog.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ServiceProviderVerificationScreen(
                verificationId: verificationId,  // Firebase verification ID for SMS authentication
                isSignUpFlow: true,
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                email: _emailController.text.trim(),
                phone: fullPhone,
                jobRole: _selectedJobRole,
                resendToken: forceResendingToken,  // Firebase token for resending verification code
              ),
            ),
          );
        },
        // Firebase Authentication: Handle verification errors
        onError: (String error) {
          setState(() {
            _isProcessing = false;
          });
          Navigator.of(context).pop(); // Close loading dialog.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const ServiceProviderLoginScreen()),
            );
          },
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
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please fill in the form to continue',
                  style:
                      TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your first name';
                    if (value.length < 2)
                      return 'First name must be at least 2 characters';
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your last name';
                    if (value.length < 2)
                      return 'Last name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone Number Field (with static "+94")
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '+94',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: 'Enter your 9-digit mobile number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter your phone number';
                          if (value.length != 9)
                            return 'Mobile number must be 9 digits';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!isValidEmail(value))
                      return 'Please enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Job Role Dropdown
                const Text(
                  'Job Role',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedJobRole,
                      items: _jobRoles
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedJobRole = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) =>
                                const ServiceProviderLoginScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an Account? ',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
