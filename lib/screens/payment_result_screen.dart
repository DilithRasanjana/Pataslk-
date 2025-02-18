import 'package:flutter/material.dart';
import 'order_status_screen.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool success;

  const PaymentResultScreen({
    Key? key,
    required this.success,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: success ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              success ? Icons.check : Icons.close,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Status Text
          Text(
            success ? 'Payment Successful!' : 'Payment Failed!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            success
                ? 'Thank you for choosing our services.\nYour booking has been confirmed!'
                : 'Please try again or contact support.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Close the bottom sheet
                Navigator.pop(context);
                // Navigate to order status screen
                if (success) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderStatusScreen(),
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
                'DONE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
