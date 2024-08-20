import 'package:flutter/material.dart';

import '../helpers/capitalize_each_word.dart';

class BadgeStatus extends StatelessWidget {
  final String status;

  const BadgeStatus({super.key, required this.status});

  Color _getBackgroundColorStatus() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade900;
      case 'process':
        return Colors.blueAccent;
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.redAccent;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: _getBackgroundColorStatus(),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        capitalizeEachWord(status),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
