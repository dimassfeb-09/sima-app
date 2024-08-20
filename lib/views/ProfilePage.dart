import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/components/Toast.dart';
import 'package:project/models/User.dart';
import 'package:project/views/ChangeEmailPage.dart';
import 'package:project/views/ChangePasswordPage.dart';
import 'package:project/views/ChangePhonePage.dart';
import '../utils/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = User();
    final RxBool isLoading = false.obs;

    return Scaffold(
      body: FutureBuilder<UserDetail>(
        future: user.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            UserDetail userDetail = snapshot.data!;

            return ListView(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        maxRadius: 50,
                        minRadius: 30,
                        backgroundImage: userDetail.photoURL.isNotEmpty ? NetworkImage(userDetail.photoURL) : null,
                        child: userDetail.photoURL.isEmpty
                            ? Text(_getInitials(userDetail.displayName), style: const TextStyle(fontSize: 24))
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userDetail.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Text(
                        "Informasi Akun",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOptionRow(
                            icon: Icons.person_2_outlined,
                            label: "Nama",
                            value: userDetail.displayName,
                            isEditable: false,
                          ),
                          const Divider(thickness: 0.3),
                          _buildOptionRow(
                            icon: Icons.numbers,
                            label: "NIK",
                            value: userDetail.nik ?? 'gak ada',
                            isEditable: userDetail.nik == '',
                          ),
                          const Divider(thickness: 0.3),
                          _buildOptionRow(
                            icon: Icons.email_outlined,
                            label: "Email",
                            value: userDetail.email,
                            onTap: () {
                              if (userDetail.isSignInWithGoogle) {
                                return ToastUtils.showSuccess("Login menggunakan Google tidak dapat mengubah email.");
                              }
                              Get.to(() => const ChangeEmailPage());
                            },
                          ),
                          const Divider(thickness: 0.3),
                          _buildOptionRow(
                            icon: Icons.phone_outlined,
                            label: "Phone",
                            value: userDetail.phoneNumber.isEmpty ? 'Belum diatur' : userDetail.phoneNumber,
                            onTap: () {
                              Get.to(() => const ChangePhoneNumberPage());
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Text(
                        "Keamanan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: _buildOptionRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Kata Sandi',
                        onTap: () {
                          if (userDetail.isSignInWithGoogle) {
                            return ToastUtils.showSuccess("Login menggunakan Google tidak dapat mengubah kata sandi.");
                          }
                          Get.to(() => const ChangePasswordPage());
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Obx(
                    () => TextButton(
                      onPressed: isLoading.value
                          ? null
                          : () async {
                              isLoading.value = true;
                              try {
                                await user.signOutAccount();
                                ToastUtils.showSuccess("Berhasil keluar");
                                Get.offAllNamed('/login'); // Redirect to login page after logout
                              } catch (e) {
                                ToastUtils.showError('Gagal keluar: $e');
                              } finally {
                                isLoading.value = false;
                              }
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: isLoading.value ? grayAccent : redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Keluar",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    String? label,
    String? value,
    VoidCallback? onTap,
    bool isEditable = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              label ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: isEditable ? onTap : null,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            child: Row(
              children: [
                Text(value ?? ''),
                const SizedBox(width: 5),
                isEditable
                    ? const Icon(
                        Icons.edit,
                        size: 18,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else if (parts.length >= 2) {
      String firstInitial = parts[0][0].toUpperCase();
      String lastInitial = parts[parts.length - 1][0].toUpperCase();
      return '$firstInitial$lastInitial';
    }
    return '';
  }
}
