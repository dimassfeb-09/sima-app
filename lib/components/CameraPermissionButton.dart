import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../views/ConfirmTakePicture.dart';

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
            XFile? compressedImage = await compressImage(File(image.path), resolution: ImageResolution.p720);
            if (compressedImage != null) {
              imagePathSelected = compressedImage.path;
              onImageSelected(compressedImage.path);

              Get.to(
                () => ConfirmTakePicture(
                  imagePath: imagePathSelected,
                  onImageSelected: onImageSelected,
                ),
              );
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

enum ImageResolution {
  p480,
  p720, // 720p resolution
  p1080, // 1080p resolution
  p4K // 4K resolution
}

Future<XFile?> compressImage(File file, {ImageResolution resolution = ImageResolution.p1080}) async {
  final Directory tempDir = await getTemporaryDirectory();
  final String targetPath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

  // Set default resolution parameters
  int minWidth;
  int minHeight;
  int quality;

  // Set resolution based on the selected option
  switch (resolution) {
    case ImageResolution.p480:
      minWidth = 1280;
      minHeight = 480;
      quality = 25;
      break;
    case ImageResolution.p720:
      minWidth = 1280;
      minHeight = 720;
      quality = 50;
      break;
    case ImageResolution.p1080:
      minWidth = 1920;
      minHeight = 1080;
      quality = 85;
      break;
    case ImageResolution.p4K:
      minWidth = 3840;
      minHeight = 2160;
      quality = 100;
      break;
    default:
      minWidth = 1920;
      minHeight = 1080;
      quality = 85;
  }

  // Compress image
  XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: quality,
    minWidth: minWidth,
    minHeight: minHeight,
  );

  // Check file size, compress further if necessary
  const int maxFileSizeInBytes = 700 * 1024; // 700 KB
  if (compressedFile != null) {
    int fileSize = await compressedFile.length();

    // Reduce quality progressively if the size is above the limit
    while (fileSize > maxFileSizeInBytes && quality > 20) {
      quality -= 10;
      compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (compressedFile != null) {
        fileSize = await compressedFile.length();
      }
    }
  }

  return compressedFile;
}
