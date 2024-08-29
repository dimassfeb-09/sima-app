import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:project/helpers/notification_senders.dart';
import 'package:project/models/Nearby.dart';
import 'package:project/services/upload_image.dart';
import 'package:project/utils/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/HereMap.dart';
import '../components/Toast.dart';
import '../components/UploadPhotoCard.dart';
import '../models/Reports.dart';
import '../models/User.dart' as usr;

class ReportAmbulancePage extends StatelessWidget {
  ReportAmbulancePage({super.key});

  final Supabase supabase = Supabase.instance;

  final TextEditingController incidentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final UploadImage uploadImage = UploadImage();

  final Rx<GeoCoordinates> coordinates = GeoCoordinates(0, 0).obs;
  final RxString streetName = ''.obs;
  final RxString imagePathSelected = ''.obs;
  final RxString currentLoadingStatus = ''.obs;

  final RxBool isLoading = false.obs;
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

    if (streetName.value.isEmpty) {
      ToastUtils.showError('Tunggu, sedang mengambil alamat');
      return false;
    }

    return true;
  }

  Future<UploadPhotosResponse?> uploadImageHandler() async {
    isLoadingUploadImage.value = true;
    try {
      final postUploadPhotos = await uploadImage.postUploadPhotos(imagePathSelected.value);
      return postUploadPhotos;
    } catch (e) {
      ToastUtils.showError('Gagal mengunggah gambar: $e');
      return null;
    } finally {
      isLoadingUploadImage.value = false;
    }
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

  Future<void> reportAmbulance(String instanceType) async {
    isLoading.value = true;

    if (!validateRequiredFields()) {
      isLoading.value = false;
      return;
    }

    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final usr.User user = usr.User();

      if (firebaseAuth.currentUser == null) {
        throw Exception('User is not authenticated');
      }

      final int? userId = await user.getUserIdByUID(firebaseAuth.currentUser!.uid);
      if (userId == null) {
        ToastUtils.showError('User ID tidak ditemukan');
        isSuccessSendReport.value = false;
        return;
      }

      currentLoadingStatus.value = 'Sedang mengunggah gambar...';
      final postUploadPhoto = await uploadImageHandler();

      if (postUploadPhoto != null && postUploadPhoto.status) {
        currentLoadingStatus.value = 'Sedang menyimpan laporan...';
        final Reports report = Reports(
          title: incidentController.text,
          description: descriptionController.text,
          latitude: coordinates.value.latitude,
          longitude: coordinates.value.longitude,
          userId: userId,
          status: 'pending',
          address: streetName.value,
          imageUrl: postUploadPhoto.imageUrl,
          type: 'ambulance',
        );

        final reportId = await report.insertReport();
        if (reportId != null) {
          currentLoadingStatus.value = 'Sedang mencari instansi terdekat...';
          final nearbyLocations = await getNearbyLocations(
            coordinates.value.latitude,
            coordinates.value.longitude,
            instanceType,
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
        ToastUtils.showSuccess('Laporan berhasil dikirim');
        Get.back();
      } else {
        isSuccessSendReport.value = false;
        ToastUtils.showError('Gagal mengirim laporan, coba lagi');
      }
    } catch (e) {
      isSuccessSendReport.value = false;
      ToastUtils.showError('Gagal mengirim laporan: $e');
    } finally {
      final endTime = DateTime.now();
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lapor Ambulan",
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
                  hintText: "contoh: serangan jantung",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
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
                  hintText: "Terjadi serangan jantung pada Ibu saya",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
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
              onPressed: !isLoadingUploadImage.value ? () => reportAmbulance('ambulance') : null,
              style: TextButton.styleFrom(
                backgroundColor: isLoading.value ? grayAccent : blueAccent,
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
                          : "Kirim Laporan Ambulan Sekarang",
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
