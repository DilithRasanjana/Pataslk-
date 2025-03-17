import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Helper class for Firebase Authentication operations
class FirebaseAuthHelper {
  // Firebase Auth: Initialize auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Validates and formats a phone number to E.164 format
  static String formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle Sri Lankan phone numbers (9 digits expected)
    if (digits.length == 9) {
      return '+94$digits'; // Add Sri Lanka country code
    }
    
    // If it already starts with country code
    if (phone.startsWith('+')) {
      return phone;
    }
    
    // Default case, assume Sri Lanka and add country code
    return '+94$digits';
  }

  /// Initiates phone number verification process
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? forceResendingToken) onCodeSent,
    required Function(String error) onError,
    int? resendToken,
  }) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber);
      debugPrint("Sending verification code to: $formattedPhone");
      
      // Firebase Auth: Start phone verification process
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Firebase Auth: Auto-verification callback (ignored in manual flow)
          debugPrint("Auto verification completed. (Manual flow, so ignoring auto sign-in.)");
        },
        verificationFailed: (FirebaseAuthException e) {
          // Firebase Auth: Error callback for verification failures
          debugPrint("Verification failed: ${e.code} - ${e.message}");
          onError(_getReadableError(e));
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          // Firebase Auth: Successful SMS code sent callback
          debugPrint("Verification code sent to $formattedPhone");
          onCodeSent(verificationId, forceResendingToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Firebase Auth: Timeout callback for SMS auto-retrieval
          debugPrint("Auto retrieval timeout. Verification ID: $verificationId");
        },
      );
    } catch (e) {
      debugPrint("Error in verifyPhoneNumber: $e");
      onError("An unexpected error occurred. Please try again.");
    }
  }

  /// Signs in user with verification code (OTP)
  Future<Map<String, dynamic>?> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (verificationId.isEmpty || smsCode.length != 6) {
        debugPrint("Error: Invalid verificationId or smsCode");
        return null;
      }
      // Firebase Auth: Create credential from verification ID and SMS code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Firebase Auth: Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      debugPrint("Sign in successful. User: ${userCredential.user?.uid}, isNewUser: $isNewUser");
      return {"user": userCredential.user, "isNewUser": isNewUser};
    } catch (e) {
      debugPrint("Error in signInWithOTP: $e");
      return null;
    }
  }
  
  /// Converts Firebase Auth error codes to user-friendly messages
  String _getReadableError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'The phone number format is incorrect. Please check and try again.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        // ...existing code for other error cases...
        default:
          return error.message ?? "Verification failed. Please try again later.";
      }
    }
    return error.toString();
  }
  
  /// Signs out the current user
  Future<void> signOut() async {
    // Firebase Auth: Sign out current user
    await _auth.signOut();
  }
}
