import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../customer/home/home_screen.dart';
import './verification_screen.dart';
import '../../utils/firebase_auth_helper.dart';
import '../../utils/firebase_firestore_helper.dart';
import './signup_screen.dart';
class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});
  
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}
  
class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuthHelper _authHelper = FirebaseAuthHelper();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  bool _isLoading = false;

  /// Formats the raw phone number (assumed 9 digits) to E.164 format.
  String _formatPhoneNumber(String raw) => '+94' + raw.trim();

  /// Login using phone number.
  void _loginWithPhone() async {
    String rawPhone = _phoneController.text;
    String fullPhone = _formatPhoneNumber(rawPhone);

    setState(() {
      _isLoading = true;
    });

    // Check if a customer with this phone number exists.
    bool exists = await _firestoreHelper.doesCustomerExistByPhone(phone: fullPhone);

    if (!exists) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No customer found with this phone number. Please sign up.")),
      );
      return;
    }

    // If exists, trigger phone verification.
    await _authHelper.verifyPhoneNumber(
      phoneNumber: fullPhone,
      onCodeSent: (String verificationId) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CustomerVerificationScreen(
              verificationId: verificationId,
              isSignUpFlow: false,
            ),
          ),
        );
      },
      onError: (String error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  /// Login using Google.
  /// For Google, immediately save/update the customer data and navigate to Home.
  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    var result = await _authHelper.signInWithGoogle();
    setState(() {
      _isLoading = false;
    });
    if (result != null) {
      User user = result["user"] as User;
      await _firestoreHelper.saveUserData(
        collection: 'customers',
        uid: user.uid,
        data: {
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'userType': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Google Sign‑In failed")));
    }
  }

  /// Builds a social button with the provided icon and action.
  Widget _buildSocialButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Image.asset(
                      'assets/Assets-main/Assets-main/logo 2.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Show "+94" as static text.
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/Assets-main/Assets-main/circle 1.png',
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
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey.shade400,
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
                      onPressed: _loginWithPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'Or sign in with',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        FontAwesomeIcons.google,
                        _loginWithGoogle,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 20),
                      // Additional social buttons can be added here.
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Create a New Account? ',
                        style: TextStyle(color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerSignUpScreen(),
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
    );
  }
}
