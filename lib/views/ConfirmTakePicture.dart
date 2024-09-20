import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project/components/CameraPermissionButton.dart';
import 'package:project/components/Toast.dart';
import 'package:project/services/user_location.dart';

import '../utils/colors.dart';

class ConfirmTakePicture extends StatefulWidget {
  final String imagePath;
  final void Function(String imagePath) onImageSelected;

  ConfirmTakePicture({super.key, required this.imagePath, required this.onImageSelected});

  @override
  _ConfirmTakePictureState createState() => _ConfirmTakePictureState();
}

class _ConfirmTakePictureState extends State<ConfirmTakePicture> {
  late final Rx<Position?> position = Rx<Position?>(null);

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    UserLocation userLocation = UserLocation();
    try {
      Position currentPosition = await userLocation.getCurrentLocation();
      position.value = currentPosition;
    } catch (e) {
      ToastUtils.showError("Failed to get current position");
    }
  }

  Future<File?> _editPhoto(String imagePath) async {
    try {
      final start = DateTime.now();

      File imageFile = File(imagePath);

      // Compress image
      XFile? compressedImage = await compressImage(imageFile, resolution: ImageResolution.p720);
      if (compressedImage != null) {
        imageFile = File(compressedImage.path);
      }

      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Decode the image asynchronously
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize the image
      final img.Image resizedImage = img.copyResize(originalImage, width: 800);

      // Get formatted date and location
      String formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

      final Position? currentPosition = position.value;
      if (currentPosition == null) {
        throw Exception('Current position is null');
      }

      String locationString = await _getLocationAddress(currentPosition);

      String text = '$formattedDate\n'
          '${currentPosition.latitude}, ${currentPosition.longitude}\n$locationString';

      // Load font lazily
      img.BitmapFont font = img.arial24;

      const int margin = 10;
      const int backgroundHeight = 120;
      int x = margin;
      int y = resizedImage.height - backgroundHeight - margin;

      y = y < 0 ? 0 : y;

      // Draw shadow and text asynchronously
      img.dropShadow(resizedImage, x, y, 10);
      img.drawString(resizedImage, text,
          x: x + 5, y: y + 20, font: font, color: img.ColorRgb8(255, 255, 255)); // White text

      // Write the edited image to a temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String editedImagePath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_edited.jpg";
      final File editedImageFile = await File(editedImagePath).writeAsBytes(img.encodeJpg(resizedImage));

      // Measure execution time
      final end = DateTime.now();
      final duration = end.difference(start);
      print('Execution time: ${duration}');

      return editedImageFile;
    } catch (e) {
      print("Error processing image: $e");
      return null;
    }
  }

  Future<String> _getLocationAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;
      return "${place.street},\n${place.subLocality} ${place.locality} ${place.postalCode}";
    } catch (e) {
      return 'Unknown location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Gambar",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            widget.onImageSelected("");
            Get.back();
            ToastUtils.showSuccess("Pengambilan gambar dibatalkan.");
          },
        ),
      ),
      body: Center(
        child: Obx(
          () {
            if (position.value == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      "Sedang mengambil lokasi gambar...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            } else {
              return FutureBuilder<File?>(
                future: _editPhoto(widget.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    ToastUtils.showError("Gagal memproses gambar...");
                    Get.back();
                    return const SizedBox();
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    final editedImage = snapshot.data!;
                    return Column(
                      children: [
                        Image.file(editedImage),
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                                onPressed: () {
                                  widget.onImageSelected(editedImage.path);
                                  Get.back();
                                  ToastUtils.showSuccess("Gambar telah dikonfirmasi dan disimpan.");
                                },
                                child: const Text(
                                  "Konfirmasi",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                                onPressed: () {
                                  widget.onImageSelected("");
                                  Get.back();
                                  ToastUtils.showSuccess("Pengambilan gambar dibatalkan.");
                                },
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          "Sedang memproses gambar...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
