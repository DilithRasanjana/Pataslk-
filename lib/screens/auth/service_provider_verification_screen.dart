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
  final String verificationId;
  final bool isSignUpFlow;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? jobRole;
  final int? resendToken; // Optional resend token

  const ServiceProviderVerificationScreen({
    super.key,
    required this.verificationId,
    required this.isSignUpFlow,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.jobRole,
    this.resendToken,
  });

  @override
  State<ServiceProviderVerificationScreen> createState() =>
      _ServiceProviderVerificationScreenState();
}

class _ServiceProviderVerificationScreenState extends State<ServiceProviderVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());
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
  void initState() {
    super.initState();
    _localResendToken = widget.resendToken;
    _startResendTimer();
    debugPrint("Verification screen opened for phone: ${widget.phone}");
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
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

  void _resendCode() async {
    if (widget.phone == null) {
      setState(() {
        _errorMessage = 'Phone number is missing';
      });
      return;
    }
    
    setState(() {
      _isResending = true;
      _errorMessage = '';
    });

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

  void _onTextChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.length == 1 && index == 5) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Phone"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Code',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter the 6-digit code sent to ${widget.phone ?? "your mobile"}',
              style:
                  const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  height: 55,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onTextChanged(value, index),
                  ),
                ),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style:
                      const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_resendSeconds > 0
                    ? "Resend code in $_resendSeconds s"
                    : "Didn't receive a code?"),
                if (_resendSeconds == 0)
                  TextButton(
                    onPressed: !_isResending ? _resendCode : null,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Resend'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Verify',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
