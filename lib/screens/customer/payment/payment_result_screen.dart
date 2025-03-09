import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool success;
  final VoidCallback? onSuccess;

  const PaymentResultScreen({
    Key? key,
    required this.success,
    this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),