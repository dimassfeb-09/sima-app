import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/components/CameraPermissionButton.dart';
import 'package:project/components/Toast.dart';
import 'package:project/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/UploadPhotoCard.dart';
import '../helpers/notification_senders.dart';
import '../models/Nearby.dart';
import '../models/Reports.dart';
import '../models/User.dart' as usr;
import '../components/HereMap.dart';
import '../services/upload_image.dart';

class ReportFireFighter extends StatelessWidget {
  const ReportFireFighter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController selectedIncidentController = TextEditingController();
    final TextEditingController incidentController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final Supabase supabase = Supabase.instance;
    final UploadImage uploadImage = UploadImage();

    final Rx<GeoCoordinates> coordinates = GeoCoordinates(0, 0).obs;
    final RxString streetName = "".obs;
    final RxString imagePathSelected = "".obs;
    final RxBool isDetectionFire = false.obs;
    final RxBool isLoadingUploadImage = false.obs;
    final RxBool isSuccessSendReport = false.obs;
    final RxString currentLoadingStatus = ''.obs;
    final RxBool isLoading = false.obs;
    final RxBool isIncidentControllerFieldActive = false.obs;

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

    Future<Nearby?> getNearbyLocations(double latitude, double longitude, String instanceType) async {
      try {
        final response = await supabase.client.rpc('get_nearby_locations', params: {
          'current_lat': latitude,
          'current_lng': longitude,
          'p_instance_type': instanceType,
          'limit_location': 1
        });

        if (response == null) return null;

        final organizationId = response[0]['organization_id'];
        final distance = response[0]['distance'];

        return Nearby(organizationId: organizationId, distance: distance);
      } catch (e) {
        throw Exception('Error get nearby locations: $e');
      }
    }

    Future<void> insertReportAssignments(int reportId, Nearby? nearby) async {
      try {
        await supabase.client.from('report_assignments').insert(
          {
            'report_id': reportId,
            'organization_id': nearby?.organizationId,
            'distance': nearby?.distance,
            'status': 'pending',
          },
        ).eq('id', reportId);
      } catch (e) {
        throw Exception('Error updating nearby locations: $e');
      }
    }

    Future<void> handlePredictFirePhoto(String imagePath) async {
      isLoadingUploadImage.value = true;
      try {
        XFile? fileCompres = await compressImage(File(imagePath), resolution: ImageResolution.p720);
        if (fileCompres != null) {
          final postPredictFire = await uploadImage.postPredictFire(fileCompres.path);
          if (postPredictFire != null && postPredictFire.probability > 0.8) {
            isDetectionFire.value = true;
          } else {
            isDetectionFire.value = false;
          }
        }

        return;
      } catch (e) {
        ToastUtils.showError('Gagal upload gambar: $e');
      } finally {
        isLoadingUploadImage.value = false;
      }
    }

    Future<void> reportFireFighter() async {
      isLoading.value = true;

      if (!validateRequiredFields()) {
        isLoading.value = false;
        return;
      }

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

        final Reports report = Reports(
          title: incidentController.text,
          description: descriptionController.text,
          latitude: coordinates.value.latitude,
          longitude: coordinates.value.longitude,
          userId: userId,
          status: 'pending',
          address: streetName.value,
          imageUrl: uploadPhotos?.imageUrl,
          type: 'firefighter',
        );

        int? reportId = await report.insertReport();

        if (reportId != null) {
          currentLoadingStatus.value = 'Sedang mencari instansi terdekat...';
          final nearbyLocations = await getNearbyLocations(
            coordinates.value.latitude,
            coordinates.value.longitude,
            'firefighter',
          );

          currentLoadingStatus.value = 'Sedang mengirim laporan ke instansi...';
          await insertReportAssignments(
            reportId,
            nearbyLocations,
          );
          await sendNotificationInsertData(
            title: incidentController.text,
            description: descriptionController.text,
            nearby: nearbyLocations,
            reportId: reportId,
          );
        }

        isSuccessSendReport.value = true;
        ToastUtils.showSuccess('Laporan pemadam kebakaran berhasil dikirim');
        Get.back();
      } catch (e) {
        isSuccessSendReport.value = false;
        ToastUtils.showError('Gagal mengirim laporan: $e');
      } finally {
        isLoading.value = false;
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
              DropdownSearch<String>(
                selectedItem: selectedIncidentController.text.isNotEmpty ? selectedIncidentController.text : null,
                items: (filter, loadProps) => ["Kebakaran", "Lainnya"],
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? 'Pilih Jenis Insiden',
                    style: TextStyle(
                      color: selectedItem == null ? Colors.grey : Colors.black,
                    ),
                  );
                },
                onChanged: (value) {
                  selectedIncidentController.text = value ?? '';
                  incidentController.text = (value != "Lainnya" ? value : '')!;
                  isIncidentControllerFieldActive.value = (value == "Lainnya");
                },
              ),
              const SizedBox(height: 10),
              Obx(
                () => isIncidentControllerFieldActive.value
                    ? TextField(
                        controller: incidentController,
                        decoration: const InputDecoration(
                          hintText: "Contoh: Kebakaran",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      )
                    : const SizedBox(),
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
                            : const Text(
                                "Foto telah diambil",
                                style: TextStyle(color: Colors.white),
                              );
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
              child: Obx(
                () => Text(
                  isLoading.value
                      ? currentLoadingStatus.value
                      : isSuccessSendReport.value
                          ? 'Berhasil Kirim!'
                          : "Kirim Laporan Pemadam Sekarang",
                  style: TextStyle(color: isLoading.value ? Colors.black : Colors.white),
                ),
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
