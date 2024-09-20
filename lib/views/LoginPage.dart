import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:project/utils/colors.dart';
import 'package:project/views/ForgotPasswordPage.dart';
import 'package:project/views/RegisterPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/Toast.dart';
import '../controller/LoginController.dart';
import '../models/Auth.dart';
import 'CompletedUserInfoPage.dart';
import 'HomePage.dart';
import 'MainPage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController loginController = LoginController();
    Auth auth = Auth();
    Supabase supabase = Supabase.instance;

    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    bool validateRequiredTextField() {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ToastUtils.showError("All fields are required");
        return false;
      }
      return true;
    }

    void handleLoginButton() async {
      if (!validateRequiredTextField()) {
        return;
      }

      loginController.setLoading(true);

      try {
        final email = emailController.value.text;
        final password = passwordController.value.text;

        AuthResult authResult = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (authResult.isSuccess) {
          ToastUtils.showSuccess('Login successful');
          Get.off(() => MainPage());
        } else {
          ToastUtils.showError(authResult.errorMessage ?? 'Login failed');
        }
      } catch (e) {
        ToastUtils.showError('Unexpected error: $e');
      } finally {
        loginController.setLoading(false);
      }
    }

    void handleLoginWithGoogle() async {
      loginController.setLoading(true);

      try {
        AuthResult authResult = await auth.signInWithGoogle();
        final String? uid = authResult.uid;

        if (authResult.isSuccess && uid != null) {
          final response = await supabase.client.from('users').select().eq('uid', uid).maybeSingle();

          if (response != null) {
            ToastUtils.showSuccess('Login successful, welcome.');
            Get.offAll(() => MainPage());
          } else {
            ToastUtils.showSuccess('Please complete your user info.');
            Get.offAll(() => const CompletedUserInfoPage());
          }
        } else {
          ToastUtils.showError(authResult.errorMessage ?? 'An unknown error occurred.');
        }
      } catch (e) {
        ToastUtils.showError('Unexpected error: $e');
      } finally {
        loginController.setLoading(false);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Masuk",
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
          const Text(
            "Masuk ke Akun Anda",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Silahkan masukkan email dan kata sandi Anda untuk masuk ke akun Anda.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Email"),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: "Masukkan email",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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
                  hintText: "Masukkan kata sandi",
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            child: GestureDetector(
              onTap: () {
                Get.to(() => const ForgotPasswordPage());
              },
              child: const Text(
                "Lupa Kata Sandi?",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            return TextButton(
              onPressed: loginController.isLoading.value ? null : handleLoginButton,
              style: TextButton.styleFrom(
                backgroundColor: loginController.isLoading.value ? Colors.grey : blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: loginController.isLoading.value
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(),
                    )
                  : const Text(
                      "Masuk",
                      style: TextStyle(color: Colors.white),
                    ),
            );
          }),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Obx(() {
            return TextButton(
              onPressed: loginController.isLoading.value ? null : handleLoginWithGoogle,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: loginController.isLoading.value
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icon/google.svg"),
                        const SizedBox(width: 8),
                        const Text(
                          "Masuk dengan Google",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
            );
          }),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Get.to(() => const RegisterPage());
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              "Daftar akun baru",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
