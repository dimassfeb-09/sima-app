import 'package:flutter/material.dart';
import 'package:project/utils/colors.dart';

class CardImageView extends StatelessWidget {
  final String imageUrl;

  const CardImageView({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1.0, color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.image_not_supported, color: grayAccent),
          );
        },
      ),
    );
  }
}
