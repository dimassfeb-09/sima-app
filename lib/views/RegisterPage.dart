import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:project/models/Auth.dart';
import 'package:project/utils/colors.dart';
import 'package:project/views/MainPage.dart';

import '../components/Toast.dart'; // Import the ToastUtils class

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Auth auth = Auth();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController nikController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    bool validateRequiredTextField() {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          nikController.text.isEmpty) {
        ToastUtils.showError("All fields are required");
        return false;
      }
      return true;
    }

    void handleRegisterWithEmail() async {
      if (!validateRequiredTextField()) {
        return;
      }

      try {
        final name = nameController.text;
        final nik = nikController.text;
        final email = emailController.text;
        final password = passwordController.text;

        AuthResult authResult = await auth.signUpWithEmailAndPassword(
          name: name,
          nik: nik,
          email: email,
          password: password,
        );

        if (authResult.isSuccess) {
          ToastUtils.showSuccess('Registration successful, please log in.');
          return Get.back();
        }

        return ToastUtils.showError(authResult.errorMessage ?? 'An unknown error occurred.');
      } catch (e) {
        ToastUtils.showError('Unexpected error: $e');
      }
    }

    void handleRegisterWithGoogle() async {
      try {
        AuthResult authResult = await auth.signUpWithGoogle();
        if (authResult.isSuccess) {
          ToastUtils.showSuccess('Registration successful, welcome.');
          return Get.offAll(() => MainPage());
        }

        return ToastUtils.showError(authResult.errorMessage ?? 'An unknown error occurred.');
      } catch (e) {
        ToastUtils.showError('Unexpected error: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pendaftaran Pengguna",
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Lengkap"),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Masukkan nama",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nomor Induk Penduduk (NIK)"),
              const SizedBox(height: 10),
              TextField(
                controller: nikController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Masukkan NIK",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Email"),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Masukkan email",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kata Sandi"),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Buat kata sandi",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: handleRegisterWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: blueAccent,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              "Daftar",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  endIndent: 8,
                ),
              ),
              Text(
                "OR",
                style: TextStyle(color: Colors.grey.shade500),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  indent: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: handleRegisterWithGoogle,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: Colors.grey.shade400), // Border color
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center align the content
              children: [
                SvgPicture.asset("assets/icon/google.svg"),
                const SizedBox(width: 8), // Spacing between icon and text
                const Text(
                  "Daftar dengan Google",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
