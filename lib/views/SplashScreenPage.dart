import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming you are using GetX for navigation
import 'package:project/views/LoginPage.dart';
import 'package:project/views/MainPage.dart'; // Adjust the import according to your project structure

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    navigateToNextScreen();

    return Scaffold(
      backgroundColor: Colors.white, // Set a background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/image/logo_sima.png"), // Your logo
            const SizedBox(height: 20), // Spacing
            const Text("Waiting..."), // Optional loading indicator
          ],
        ),
      ),
    );
  }

  void navigateToNextScreen() {
    Timer(const Duration(seconds: 2), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.offAll(() => const LoginPage()); // Navigate to LoginPage
      } else {
        Get.offAll(() => MainPage()); // Navigate to MainPage
      }
    });
  }
}
