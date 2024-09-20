import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/Auth.dart';
import 'package:project/utils/colors.dart';
import 'package:project/views/HomePage.dart';
import 'package:project/views/LoginPage.dart';
import 'package:project/views/MainPage.dart';

import '../models/User.dart' as usr;
import '../components/Toast.dart';
import '../controller/RegisterController.dart';

class CompletedUserInfoPage extends StatefulWidget {
  const CompletedUserInfoPage({super.key});

  @override
  _CompletedUserInfoPageState createState() => _CompletedUserInfoPageState();
}

class _CompletedUserInfoPageState extends State<CompletedUserInfoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RegisterController registerController = RegisterController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      setState(() {
        emailController.text = currentUser.email ?? "";
        nameController.text = currentUser.displayName ?? "";
        // Optionally fetch additional details like NIK from your database
        // Example: nikController.text = fetchNIKFromDatabase(currentUser.uid);
      });
    }
  }

  bool validateRequiredFields() {
    if (nameController.text.isEmpty || nikController.text.isEmpty) {
      ToastUtils.showError("All fields are required");
      return false;
    }
    return true;
  }

  Future<void> handleCompleteUserInfo() async {
    if (!validateRequiredFields()) {
      return;
    }

    registerController.setLoading(true);

    try {
      final name = nameController.text;
      final nik = nikController.text;
      final email = emailController.text;

      // Check if the current user is null (not logged in)
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Create or update user information
        bool updateSuccess = await usr.User().createUser(
          uid: currentUser.uid,
          fullName: name,
          email: email,
          nik: nik,
        );

        if (updateSuccess) {
          ToastUtils.showSuccess('User info updated successfully.');
          Get.offAll(() => MainPage()); // Redirect to the home page and clear the navigation stack
        } else {
          ToastUtils.showError('Failed to update user information.');
        }
      } else {
        ToastUtils.showError('No user is currently logged in.');
        Get.offAll(() => const LoginPage()); // Redirect to the login page and clear the navigation stack
      }
    } catch (e) {
      print("ERROR: $e");
      ToastUtils.showError('Unexpected error: $e');
    } finally {
      registerController.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complete User Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildTextField("Email", emailController, "Masukkan email",
              enabled: false, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          buildTextField("Nama Lengkap", nameController, "Masukkan nama"),
          const SizedBox(height: 20),
          buildTextField("Nomor Induk Penduduk (NIK)", nikController, "Masukkan NIK",
              keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          Obx(() {
            return TextButton(
              onPressed: registerController.isLoading.value ? null : handleCompleteUserInfo,
              style: TextButton.styleFrom(
                backgroundColor: registerController.isLoading.value ? Colors.grey : blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: registerController.isLoading.value
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(),
                    )
                  : const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String hintText,
      {bool enabled = true, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
