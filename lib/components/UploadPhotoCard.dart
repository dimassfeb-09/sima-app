import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CameraPermissionButton.dart';

class UploadPhotoCard extends StatelessWidget {
  final RxString imagePathSelected = ''.obs;
  final void Function(String imagePath) onImageSelected;

  UploadPhotoCard({
    Key? key,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(width: 0.3),
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final String imagePath = imagePathSelected.value;
            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
                  child: imagePath.isEmpty ? const Icon(Icons.camera_alt, color: Colors.grey) : null,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ambil gambar keadaan di lokasi',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
          CameraPermissionButton(
            onImageSelected: (String imagePath) {
              imagePathSelected.value = imagePath;
              onImageSelected(imagePath);
            },
            imagePathSelected: imagePathSelected.value,
          ),
        ],
      ),
    );
  }
}
