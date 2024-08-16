import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:here_sdk/core.dart';
import 'package:project/components/HereMap.dart';
import 'package:project/utils/colors.dart';

import '../components/Toast.dart';
import '../models/ReportPoliceModel.dart';
import '../models/User.dart' as usr;

class ReportPolicePage extends StatelessWidget {
  const ReportPolicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController incidentController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    Rx<GeoCoordinates> coordinates = GeoCoordinates(0, 0).obs;
    RxString streetName = ''.obs;

    bool validateRequiredFields() {
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

      if (streetName.isEmpty) {
        ToastUtils.showSuccess('Tunggu, sedang mengambil alamat');
        return true;
      }

      return false;
    }

    Future<void> reportPolice() async {
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

        bool isFieldBlank = validateRequiredFields();
        if (isFieldBlank) return;

        final ReportPoliceModel report = ReportPoliceModel(
          title: incidentController.text,
          description: descriptionController.text,
          latitude: coordinates.value.latitude,
          longitude: coordinates.value.longitude,
          userId: userId,
          address: streetName.value,
        );

        await report.insertReport();
        ToastUtils.showSuccess('Laporan ke polisi berhasil dikirim');
        return Get.back();
      } catch (e) {
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
                  hintText: "Terjadi pencopetan",
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
                  hintText: "Terjadi pencopetan di Mixue Beji depok",
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
          HereMapCustom(
            geoCoordinates: coordinates,
            streetName: streetName,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: reportPolice,
            style: TextButton.styleFrom(
              backgroundColor: blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              "Kirim Laporan Polisi Sekarang",
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
