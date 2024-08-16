import 'package:flutter/material.dart';
import 'package:project/components/Toast.dart';
import 'package:project/models/User.dart';

import '../utils/colors.dart';

class ChangeEmailPage extends StatelessWidget {
  const ChangeEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    void handleChangeEmail() async {
      try {
        User user = User();
        await user.changeEmailUser(emailController.value.text, passwordController.value.text);
      } catch (e) {
        return ToastUtils.showError('Unexpected error: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ubah Email",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: "Masukkan email baru",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Konfirmasi kata sandi",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: handleChangeEmail,
              style: TextButton.styleFrom(
                backgroundColor: blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                "Ubah",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
