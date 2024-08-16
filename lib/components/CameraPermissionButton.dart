import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/colors.dart';

class CameraPermissionButton extends StatelessWidget {
  final RxString imagePathTakePicture;

  CameraPermissionButton({required this.imagePathTakePicture});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        PermissionStatus status = await Permission.camera.request();

        if (status.isGranted) {
          final ImagePicker _picker = ImagePicker();
          final XFile? image = await _picker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.rear,
          );

          if (image != null) {
            imagePathTakePicture.value = image.path;
            print(imagePathTakePicture.value);
          }
        } else if (status.isDenied || status.isPermanentlyDenied) {
          _showPermissionDialog(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: grayAccent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text("Pilih"),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text('Please grant camera access to take pictures.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open app settings to allow permission
              Navigator.of(context).pop();
            },
            child: const Text('Allow Permission'),
          ),
        ],
      ),
    );
  }
}
