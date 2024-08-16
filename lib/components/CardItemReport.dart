import 'package:flutter/material.dart';

class CardItemReport extends StatelessWidget {
  final String title;
  final String createdAt;
  final String location;
  final String status;

  const CardItemReport({
    Key? key,
    required this.title,
    required this.createdAt,
    required this.location,
    required this.status,
  }) : super(key: key);

  Color _getBackgroundColorStatus(String status) {
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

  String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            capitalizeEachWord(title),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis, // Ensure long titles are truncated
            ),
            maxLines: 1, // Limit to a single line
          ),
          const SizedBox(height: 5),
          Text(
            createdAt,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            location,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              overflow: TextOverflow.ellipsis, // Ensure long locations are truncated
            ),
            maxLines: 1, // Limit to a single line
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: _getBackgroundColorStatus(status),
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
          ),
        ],
      ),
    );
  }
}
