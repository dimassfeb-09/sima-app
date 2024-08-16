import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:project/components/CameraPermissionButton.dart';
import 'package:project/components/Toast.dart';
import 'package:project/models/ReportFireFighterModel.dart';
import 'package:project/utils/colors.dart';
import '../models/User.dart' as usr;
import '../components/HereMap.dart';

class ReportFireFighter extends StatelessWidget {
  const ReportFireFighter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController incidentController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final Rx<GeoCoordinates> coordinates = GeoCoordinates(0, 0).obs;
    final RxString imagePathTakePicture = "".obs;
    final RxString streetName = "".obs;
    final RxBool isDetectionFire = false.obs;
    final RxBool isLoadingUploadImage = false.obs;

    Future<void> validateImageFireDetector(String imagePath) async {
      const String url = 'https://fire-detection.fly.dev/predict';

      try {
        isLoadingUploadImage.value = true;

        final dio.Dio dioInstance = dio.Dio();
        final dio.FormData formData = dio.FormData.fromMap({
          'file': await dio.MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
        });

        final dio.Response response = await dioInstance.post(
          url,
          data: formData,
          options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
        );

        if (response.statusCode == 200) {
          isDetectionFire.value = response.data["probability"] > 0.8;
        } else {
          print('Unexpected response status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred: $e');
      } finally {
        isLoadingUploadImage.value = false;
      }
    }

    bool validareRequiredFields() {
      if (incidentController.text.isEmpty) {
        ToastUtils.showSuccess('Jenis insiden tidak boleh kosong');
        return true;
      }

      if (descriptionController.text.isEmpty) {
        ToastUtils.showSuccess('Deskripsi insiden tidak boleh kosong');
        return true;
      }

      if (coordinates.value.latitude == 0 && coordinates.value.longitude == 0) {
        ToastUtils.showSuccess('Mohon tunggu, sedang mengambil lokasi anda');
        return true;
      }

      if (imagePathTakePicture.value.isEmpty) {
        ToastUtils.showSuccess('Foto bukti tidak boleh kosong');
        return true;
      }

      if (streetName.isEmpty) {
        ToastUtils.showSuccess('Tunggu, sedang mengambil alamat');
        return true;
      }

      return false;
    }

    void onImagePathChanged(String newPath) {
      if (newPath.isNotEmpty) {
        validateImageFireDetector(newPath);
      }
    }

    Future<void> reportFireFighter() async {
      try {
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        final usr.User user = usr.User();

        if (firebaseAuth.currentUser == null) {
          throw Exception('User is not authenticated');
        }

        final int? userId = await user.getUserIdByUID(firebaseAuth.currentUser!.uid);
        if (userId == null) {
          return ToastUtils.showError('User ID tidak ditemukan');
        }

        bool isFieldBlank = validareRequiredFields();
        if (isFieldBlank) return;

        final ReportFireFighterModel report = ReportFireFighterModel(
          title: incidentController.text,
          description: descriptionController.text,
          latitude: coordinates.value.latitude,
          longitude: coordinates.value.longitude,
          userId: userId,
          status: 'pending',
          address: streetName.value,
          imageUrl: '',
        );

        await report.insertReport();
        ToastUtils.showSuccess('Laporan pemadam kebakaran berhasil dikirim');
        return Get.back();
      } catch (e) {
        ToastUtils.showError('Gagal mengirim laporan: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lapor Pemadam Kebakaran",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Jenis Insiden"),
              const SizedBox(height: 10),
              TextField(
                controller: incidentController,
                decoration: const InputDecoration(
                  hintText: "Contoh: Kebakaran di Pasar Baru",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Deskripsi Insiden"),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  hintText: "Contoh: Terjadi kebakaran di Pasar Baru, blok A nomor 15",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              )
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.3),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() {
                          final String imagePath = imagePathTakePicture.value;
                          if (imagePath.isNotEmpty) {
                            onImagePathChanged(imagePath);
                          }
                          return CircleAvatar(
                            backgroundImage: imagePath.isNotEmpty ? FileImage(File(imagePath)) as ImageProvider : null,
                          );
                        }),
                        const SizedBox(width: 12),
                        const Text("Upload Foto Bukti"),
                      ],
                    ),
                    CameraPermissionButton(imagePathTakePicture: imagePathTakePicture),
                  ],
                ),
              ),
              Obx(
                () => imagePathTakePicture.value.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: redAccent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                          child: Obx(
                            () => Text(
                              isDetectionFire.value ? "Terdeteksi kebakaran" : "Tidak terdeteksi kebakaran",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HereMapCustom(
            geoCoordinates: coordinates,
            streetName: streetName,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: reportFireFighter,
            style: TextButton.styleFrom(
              backgroundColor: blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              "Kirim Laporan Pemadam Sekarang",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              backgroundColor: redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              "Batalkan Permintaan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
