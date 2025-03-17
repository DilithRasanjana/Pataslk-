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