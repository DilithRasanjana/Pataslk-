import 'package:flutter/material.dart';
import 'payment_result_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;

  void _processPayment() {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isProcessing = false);
      _showPaymentResult(true);
    });
  }

  void _showPaymentResult(bool success) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentResultScreen(
        success: success,
        onSuccess: () {
          Navigator.pop(context); // Close bottom sheet
          widget.onPaymentSuccess(); // Call the success callback
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/visa%20card.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Methods Section
              const Text(
                'or pay with',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              // Payment Options
              _buildPaymentOption(
                'PayPal',
                'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/paypal.png',
                'paypal',
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'Google Pay',
                'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/googleplay.png',
                'gpay',
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                'Apple Pay',
                'https://raw.githubusercontent.com/SDGP-CS80-ServiceProviderPlatform/Assets/refs/heads/main/applepay.png',
                'applepay',
              ),
              const SizedBox(height: 32),

              // Amount Display
              Text(
                'Total Amount: Rs ${widget.amount.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Pay Button
              ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildPaymentOption(String title, String imageUrl, String value) {
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? Colors.blue[900]!
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value.toString());
              },
              activeColor: Colors.blue[900],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 32,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
