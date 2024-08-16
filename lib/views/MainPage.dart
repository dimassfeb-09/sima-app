import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/utils/colors.dart';

import 'HistoryPage.dart';
import 'HomePage.dart';
import 'ProfilePage.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final RxInt currentIndexPage = 0.obs;
  final RxString title = "Layanan Emergency".obs;

  @override
  Widget build(BuildContext context) {
    // Update title based on the current index outside of the build process
    ever(currentIndexPage, (index) {
      switch (index) {
        case 0:
          title.value = "Layanan Emergency";
          break;
        case 1:
          title.value = "Riwayat Laporan";
          break;
        case 2:
          title.value = "Pengaturan Profile";
          break;
        default:
          title.value = "Layanan Emergency";
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            title.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
      ),
      body: Obx(() {
        // Change the body based on the current index
        switch (currentIndexPage.value) {
          case 0:
            return const HomePage();
          case 1:
            return HistoryPage();
          case 2:
            return const ProfilePage();
          default:
            return const HomePage();
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: currentIndexPage.value,
          onTap: (value) {
            currentIndexPage.value = value;
          },
          selectedItemColor: blueAccentLight,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              tooltip: "Beranda",
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              tooltip: "Riwayat",
              label: "Riwayat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_outlined),
              tooltip: "Profile",
              label: "Profile",
            ),
          ],
        );
      }),
    );
  }
}
