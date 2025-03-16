import 'package:flutter/material.dart';
// Firebase Authentication for user identity and session management
import 'package:firebase_auth/firebase_auth.dart';
// Firebase Firestore for database operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_card_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
    // Firebase Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase Auth instance for user authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedMethod;
  bool _isLoading = false;

  Widget _buildPaymentOption({
    required String title,
    required String imagePath,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedMethod == value ? const Color(0xFF0D47A1) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: RadioListTile(
        value: value,
        groupValue: _selectedMethod,
        onChanged: (String? value) {
          setState(() {
            _selectedMethod = value;
          });
        },
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            CachedNetworkImage(
              imageUrl: imagePath,
              height: 32,
              width: 50,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 32,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.credit_card,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        activeColor: const Color(0xFF0D47A1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildCreditCardOption() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddCardScreen()),
            ).then((_) {
              // Refresh the screen when returning from AddCardScreen
              setState(() {});
            });
            
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Add credit or debit card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreditCardOption(),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              _buildPaymentOption(
                title: 'PayPal',
                imagePath: 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/paypal.png',
                value: 'paypal',
              ),
              _buildPaymentOption(
                title: 'Google Pay',
                imagePath: 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/googleplay.png',
                value: 'google_pay',
              ),
              _buildPaymentOption(
                title: 'Apple Pay',
                imagePath: 'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/applepay.png',
                value: 'apple_pay',
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _selectedMethod != null
                    ? () {
                        // TODO: Handle payment method selection
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
