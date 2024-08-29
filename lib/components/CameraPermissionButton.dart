import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CameraPermissionButton extends StatelessWidget {
  String imagePathSelected;
  final void Function(String) onImageSelected;

  CameraPermissionButton({
    required this.imagePathSelected,
    required this.onImageSelected,
  });

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
            XFile? compressedImage = await _compressImage(File(image.path));
            if (compressedImage != null) {
              imagePathSelected = compressedImage.path;
              onImageSelected(compressedImage.path);
            }
          }
        } else if (status.isDenied || status.isPermanentlyDenied) {
          _showPermissionDialog(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text("Pilih"),
      ),
    );
  }

  Future<XFile?> _compressImage(File file) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
    );

    if (compressedFile != null && await compressedFile.length() <= 1024 * 1024) {
      return compressedFile;
    } else {
      return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 50,
      );
    }
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
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Allow Permission'),
          ),
        ],
      ),
    );
  }
}
