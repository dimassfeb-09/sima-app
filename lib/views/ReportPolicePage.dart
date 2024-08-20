import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:project/services/upload_image.dart';
import 'package:project/utils/colors.dart';

import '../components/HereMap.dart';
import '../components/Toast.dart';
import '../components/UploadPhotoCard.dart';
import '../models/ReportPoliceModel.dart';
import '../models/User.dart' as usr;

class ReportPolicePage extends StatelessWidget {
  const ReportPolicePage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController incidentController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    UploadImage uploadImage = UploadImage();

    Rx<GeoCoordinates> coordinates = GeoCoordinates(0, 0).obs;
    RxString streetName = ''.obs;
    RxString imagePathSelected = ''.obs;
    final RxBool isSuccessSendReport = false.obs;
    final RxBool isLoadingUploadImage = false.obs;

    bool validateRequiredFields() {
      if (incidentController.text.isEmpty) {
        ToastUtils.showError('Jenis insiden tidak boleh kosong');
        return false;
      }

      if (descriptionController.text.isEmpty) {
        ToastUtils.showError('Deskripsi insiden tidak boleh kosong');
        return false;
      }

      if (imagePathSelected.value.isEmpty) {
        ToastUtils.showError('Ambil foto terlebih dahulu');
        return false;
      }

      if (coordinates.value.latitude == 0 && coordinates.value.longitude == 0) {
        ToastUtils.showError('Mohon tunggu, sedang mengambil lokasi anda');
        return false;
      }

      if (streetName.isEmpty) {
        ToastUtils.showError('Tunggu, sedang mengambil alamat');
        return false;
      }

      return true;
    }

    Future<UploadPhotosResponse?> uploadImageHandler() async {
      isLoadingUploadImage.value = true;
      try {
        return await uploadImage.postUploadPhotos(imagePathSelected.value);
      } catch (e) {
        ToastUtils.showError('Gagal mengunggah gambar: $e');
        return null;
      } finally {
        isLoadingUploadImage.value = false;
      }
    }

    Future<void> reportPolice() async {
      if (!validateRequiredFields()) return;

      try {
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        final usr.User user = usr.User();

        if (firebaseAuth.currentUser == null) {
          throw Exception('User is not authenticated');
        }

        final int? userId = await user.getUserIdByUID(firebaseAuth.currentUser!.uid);
        if (userId == null) {
          ToastUtils.showError('User ID tidak ditemukan');
          return;
        }

        final postUploadPhoto = await uploadImageHandler();

        if (postUploadPhoto != null && postUploadPhoto.status) {
          final ReportPoliceModel report = ReportPoliceModel(
            title: incidentController.text,
            description: descriptionController.text,
            latitude: coordinates.value.latitude,
            longitude: coordinates.value.longitude,
            userId: userId,
            status: 'pending',
            address: streetName.value,
            imageUrl: postUploadPhoto.imageUrl,
          );

          await report.insertReport();
          isSuccessSendReport.value = true;
          ToastUtils.showSuccess('Laporan ke polisi berhasil dikirim');
          Get.back();
        } else {
          isSuccessSendReport.value = false;
          ToastUtils.showError('Gagal mengirim laporan, coba lagi');
        }
      } catch (e) {
        isSuccessSendReport.value = false;
        ToastUtils.showError('Gagal mengirim laporan: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lapor Polisi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
                  hintText: "Contoh: Terjadi pencopetan",
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
                  hintText: "Terjadi pencopetan di Mixue Beji, Depok.",
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
          UploadPhotoCard(
            onImageSelected: (imagePath) {
              imagePathSelected.value = imagePath;
            },
          ),
          Obx(
            () => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: imagePathSelected.value.isEmpty ? redAccent : Colors.green.shade400,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Text(
                  imagePathSelected.value.isEmpty ? 'Ambil gambar terlebih dahulu.' : 'Berhasil ambil gambar.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          HereMapCustom(
            geoCoordinates: coordinates,
            streetName: streetName,
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextButton(
              onPressed: !isLoadingUploadImage.value ? reportPolice : null,
              style: TextButton.styleFrom(
                backgroundColor: isLoadingUploadImage.value ? grayAccent : blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                isLoadingUploadImage.value
                    ? "Sedang upload gambar"
                    : isSuccessSendReport.value
                        ? 'Berhasil Kirim!'
                        : "Kirim Laporan Polisi Sekarang",
                style: const TextStyle(color: Colors.white),
              ),
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
