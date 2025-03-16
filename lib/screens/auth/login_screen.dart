import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './verification_screen.dart';
// Import helper for Firebase Authentication operations
import '../../utils/firebase_auth_helper.dart';
// Import helper for Firebase Firestore database operations
import '../../utils/firebase_firestore_helper.dart';
import './signup_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});
  
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}
  
class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  // Firebase Authentication helper instance
  final FirebaseAuthHelper _authHelper = FirebaseAuthHelper();
  // Firebase Firestore helper instance
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  bool _isLoading = false;
  int _phoneAttempts = 0;

  /// Formats the raw phone number to E.164 format for Firebase Authentication.
  String _formatPhoneNumber(String raw) => FirebaseAuthHelper.formatPhoneNumber(raw);

  /// Validates the phone number.
  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Expect exactly 9 digits.
    final cleanDigits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDigits.length != 9) {
      return 'Please enter a valid 9-digit mobile number';
    }
    return null;
  }

  /// Login using phone number with Firebase Authentication.
  void _loginWithPhone() async {
    final validation = _validatePhone(_phoneController.text);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation)),
      );
      return;
    }
    
    String fullPhone = _formatPhoneNumber(_phoneController.text);

    setState(() {
      _isLoading = true;
    });

    // Firebase Firestore: Check if a customer exists by phone number
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You'll receive an SMS with the verification code shortly."),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      // Firebase Authentication: Start phone number verification process
      await _authHelper.verifyPhoneNumber(
        phoneNumber: fullPhone,
        // Firebase Authentication: Handle successful SMS code sending
        onCodeSent: (String verificationId, int? forceResendingToken) {
          setState(() {
            _isLoading = false;
            _phoneAttempts = 0;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CustomerVerificationScreen(
                verificationId: verificationId,  // Firebase verification ID for SMS authentication
                isSignUpFlow: false,
                phone: fullPhone,
                resendToken: forceResendingToken,  // Firebase token for resending verification code
              ),
            ),
          );
        },
        // Firebase Authentication: Handle verification errors
        onError: (String error) {
          _phoneAttempts++;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } catch (e) {
      // Handle Firebase Authentication exceptions
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Use the second logo for login screen
              Center(
                child: Image.asset(
                  'assets/Assets-main/Assets-main/logo 2.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              // Sign in text
              const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              // Phone number field
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
                    // Country code with flag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Updated Flag Image
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
                    // Vertical divider
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.grey.shade400,
                    ),
                    // Phone number input
                    Expanded(
                      child: TextFormField(
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
              // Sign In button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement actual login logic
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Sign in with text
              const Center(
                child: Text(
                  'Sign in with',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    'https://www.google.com',
                    FontAwesomeIcons.google,
                    context,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    'https://www.facebook.com',
                    FontAwesomeIcons.facebookF,
                    context,
                    color: const Color(0xFF1877F2),
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    'https://www.apple.com',
                    FontAwesomeIcons.apple,
                    context,
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Create account text
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Create a New Account? ',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildSocialButton(String url, IconData icon, BuildContext context,
      {Color? color}) {
    return InkWell(
      onTap: () {
        // TODO: Implement social login
      },
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
}
