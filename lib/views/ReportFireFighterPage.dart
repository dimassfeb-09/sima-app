import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:project/components/Toast.dart';
import 'package:project/models/ReportFireFighterModel.dart';
import 'package:project/utils/colors.dart';
import '../components/UploadPhotoCard.dart';
import '../models/User.dart' as usr;
import '../components/HereMap.dart';
import '../services/upload_image.dart';

class ReportFireFighter extends StatelessWidget {
  const ReportFireFighter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController incidentController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final UploadImage uploadImage = UploadImage();

    final Rx<GeoCoordinates> coordinates = GeoCoordinates(0, 0).obs;
    final RxString streetName = "".obs;
    final RxString imagePathSelected = "".obs;
    final RxBool isDetectionFire = false.obs;
    final RxBool isLoadingUploadImage = false.obs;
    final RxBool isSuccessSendReport = false.obs;

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

    Future<void> handlePredictFirePhoto(String imagePath) async {
      isLoadingUploadImage.value = true;
      try {
        final postPredictFire = await uploadImage.postPredictFire(imagePath);

        if (postPredictFire != null && postPredictFire.probability > 0.8) {
          isDetectionFire.value = true;
        } else {
          isDetectionFire.value = false;
        }
      } catch (e) {
        ToastUtils.showError('Gagal upload gambar: $e');
      } finally {
        isLoadingUploadImage.value = false;
      }
    }

    Future<void> reportFireFighter() async {
      if (!validateRequiredFields()) return;

      isLoadingUploadImage.value = true;
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

        if (incidentController.text.toLowerCase().contains('kebakaran')) {
          await handlePredictFirePhoto(imagePathSelected.value);
        }

        final uploadPhotos = await uploadImage.postUploadPhotos(imagePathSelected.value);

        final ReportFireFighterModel report = ReportFireFighterModel(
          title: incidentController.text,
          description: descriptionController.text,
          latitude: coordinates.value.latitude,
          longitude: coordinates.value.longitude,
          userId: userId,
          status: 'pending',
          address: streetName.value,
          imageUrl: uploadPhotos?.imageUrl,
        );

        await report.insertReport();
        isSuccessSendReport.value = true;
        ToastUtils.showSuccess('Laporan pemadam kebakaran berhasil dikirim');
        Get.back();
      } catch (e) {
        isSuccessSendReport.value = false;
        ToastUtils.showError('Gagal mengirim laporan: $e');
      } finally {
        isLoadingUploadImage.value = false;
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
              UploadPhotoCard(
                onImageSelected: (imagePath) async {
                  imagePathSelected.value = imagePath;
                  if (incidentController.text.toLowerCase().contains('kebakaran')) {
                    await handlePredictFirePhoto(imagePath);
                  }
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
                    child: Obx(
                      () {
                        if (imagePathSelected.value.isEmpty) {
                          return const Text("Belum ambil foto", style: TextStyle(color: Colors.white));
                        }

                        return incidentController.text.toLowerCase().contains("kebakaran")
                            ? Text(
                                isDetectionFire.value
                                    ? "Terdeteksi kebakaran"
                                    : isLoadingUploadImage.value
                                        ? 'Sedang pengecekan foto'
                                        : 'Tidak terdeteksi kebakaran',
                                style: const TextStyle(color: Colors.white))
                            : const Text("Foto telah diambil", style: TextStyle(color: Colors.white));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HereMapCustom(
            geoCoordinates: coordinates,
            streetName: streetName,
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextButton(
              onPressed: !isLoadingUploadImage.value ? reportFireFighter : null,
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
                        : "Kirim Laporan Pemadam Sekarang",
                style: TextStyle(color: isLoadingUploadImage.value ? Colors.black : Colors.white),
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
