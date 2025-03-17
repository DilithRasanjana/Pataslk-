import 'dart:async';
// Firebase Firestore package for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Authentication package for user authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Helper utility for Firebase Authentication operations
import '../../utils/firebase_auth_helper.dart';
// Helper utility for Firestore database operations
import '../../utils/firebase_firestore_helper.dart';
import '../service_provider/home/service_provider_home_screen.dart';


class ServiceProviderVerificationScreen extends StatefulWidget {
  const ServiceProviderVerificationScreen({Key? key}) : super(key: key);

  @override
  State<ServiceProviderVerificationScreen> createState() =>
      _ServiceProviderVerificationScreenState();
}

class _ServiceProviderVerificationScreenState
    extends State<ServiceProviderVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  // Firebase Authentication helper instance
  final FirebaseAuthHelper _authHelper = FirebaseAuthHelper();
  // Firebase Firestore helper instance
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  bool _isVerifying = false;
  bool _isResending = false;
  String _errorMessage = '';

  Timer? _resendTimer;
  int _resendSeconds = 60;
  int? _localResendToken; // Local copy of resend token

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _completeSignUp() async {
    // Firebase Firestore: Save service provider data to 'serviceProviders' collection
    if (widget.firstName != null &&
        widget.lastName != null &&
        widget.email != null &&
        widget.phone != null &&
        widget.jobRole != null) {
      // Get current Firebase user after successful authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firebase Firestore: Save user profile data to database
        await _firestoreHelper.saveUserData(
          collection: 'serviceProviders',
          uid: user.uid,
          data: {
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'email': widget.email,
            'phone': widget.phone,
            'jobRole': widget.jobRole,
            'userType': 'serviceProvider',
            'createdAt': FieldValue.serverTimestamp(), // Firestore server timestamp
          },
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const ServiceProviderHomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = "User not signed in or missing details";
          _isVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not signed in")),
        );
      }
    }
  }
  void _verifyCode() async {
    String smsCode = _controllers.map((c) => c.text).join();
    if (smsCode.length != 6) {
      setState(() {
        _errorMessage = "Please enter the complete 6-digit code";
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      // Firebase Authentication: Verify OTP code and sign in the user
      var result = await _authHelper.signInWithOTP(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      if (result != null) {
        bool isNewUser = result["isNewUser"] as bool;
        if (widget.isSignUpFlow && isNewUser) {
          // Firebase: Complete sign up flow for new users by saving data to Firestore
          await _completeSignUp();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const ServiceProviderHomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Verification failed. The code may be incorrect.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }
  
    try {
      // Firebase Authentication: Resend verification code to the user's phone
      await _authHelper.verifyPhoneNumber(
        phoneNumber: widget.phone!,
        resendToken: _localResendToken,
        onCodeSent: (String newVerificationId, int? forceResendingToken) {
          // Firebase: Handle successful code resend
          setState(() {
            _isResending = false;
            _localResendToken = forceResendingToken;
          });
          for (var controller in _controllers) controller.clear();
          if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
          _startResendTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code resent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (String error) {
          // Firebase: Handle verification error
          setState(() {
            _isResending = false;
            _errorMessage = error;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isResending = false;
        _errorMessage = e.toString();
      });
    }
  }
        


  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (index == 5 && value.length == 1) {
      _verifyCode();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verification Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your account has been verified successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ServiceProviderLoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue to Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyCode() {
    String code = _controllers.map((controller) => controller.text).join();
    if (code.length == 6) {
      _showSuccessDialog();
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 4-digit code sent to your mobile number',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue[900]!),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onCodeChanged(value, index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t receive code? ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton(
                  onPressed: () {
                    // Resend code logic
                  },
                  child: const Text('Resend'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
