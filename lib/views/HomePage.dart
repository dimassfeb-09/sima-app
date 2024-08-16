import 'package:flutter/material.dart';

import '../components/EmergencyCellularButton.dart';
import '../components/EmergencyOptions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Pilih Layanan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Gunakan aplikasi ini untuk menghubungi layanan darurat dengan cepat. Pilih layanan yang Anda butuhkan dari tombol di bawah ini. ",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),
        const Text(
          "Informasi Penggunaan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        EmergencyOptions(),
        const SizedBox(height: 16),
        const Text(
          "Aplikasi ini dirancang untuk memberikan akses cepat ke layanan darurat. Pastikan Anda memiliki koneksi internet yang stabil saat menggunakan aplikasi ini. Jika Anda tidak dapat mengakses internet, hubungi layanan darurat melalui telepon.",
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        const EmergencyCellularButton(
          label: "Lapor ke Polisi",
          phoneNumber: "110",
          backgroundColor: Colors.white,
          textColor: Colors.black,
        ),
        const SizedBox(height: 12),
        const EmergencyCellularButton(
          label: "Panggil Ambulans",
          phoneNumber: "119",
          backgroundColor: Colors.white,
          textColor: Colors.black,
        ),
        const SizedBox(height: 12),
        const EmergencyCellularButton(
          label: "Panggil Pemadam Kebakaran",
          phoneNumber: "113",
          backgroundColor: Colors.white,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
