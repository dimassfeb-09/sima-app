import 'package:firebase_auth/firebase_auth.dart' as f_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:project/components/Toast.dart';
import 'package:project/models/Auth.dart';
import 'package:project/views/LoginPage.dart';
import 'package:project/views/PasswordResetSuccessPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDetail {
  String uid;
  String displayName;
  String email;
  String? nik;
  String phoneNumber;
  String photoURL;
  bool isSignInWithGoogle;

  UserDetail({
    required this.uid,
    required this.displayName,
    required this.email,
    this.nik,
    required this.phoneNumber,
    required this.photoURL,
    this.isSignInWithGoogle = false,
  });

  UserDetail copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? nik,
    String? phoneNumber,
    String? photoURL,
    bool? isSignInWithGoogle,
  }) {
    return UserDetail(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      nik: nik ?? this.nik,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      isSignInWithGoogle: isSignInWithGoogle ?? this.isSignInWithGoogle,
    );
  }
}

class User {
  Future<UserDetail> getUserInfo() async {
    f_auth.FirebaseAuth auth = f_auth.FirebaseAuth.instance;
    f_auth.User? currentUser = auth.currentUser;

    if (currentUser == null) {
      ToastUtils.showError('No user is currently signed in.');
      return UserDetail(
        uid: '',
        displayName: '',
        email: '',
        nik: '',
        phoneNumber: '',
        photoURL: '',
        isSignInWithGoogle: false,
      );
    }

    List<f_auth.UserInfo> providerData = currentUser.providerData;
    bool isGoogleSignIn = providerData.any(
      (userInfo) => userInfo.providerId == 'google.com',
    );

    // Fetch the NIK from Supabase
    String? nik = await _getNikFromSupabase(currentUser.uid);

    var userDetail = UserDetail(
      uid: currentUser.uid,
      displayName: currentUser.displayName ?? '',
      email: currentUser.email ?? '',
      nik: nik,
      phoneNumber: currentUser.phoneNumber ?? '',
      photoURL: currentUser.photoURL ?? '',
      isSignInWithGoogle: isGoogleSignIn,
    );

    return userDetail;
  }

  Future<String?> _getNikFromSupabase(String uid) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('users').select('nik').eq('uid', uid).single();

      return response['nik'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<int?> getUserIdByUID(String uid) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('users').select('id').eq('uid', uid).single();
      return response['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createUser({
    required String uid,
    required String fullName,
    required String email,
    required String nik,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('users').insert({
        'uid': uid,
        'full_name': fullName,
        'email': email,
        'nik': nik,
        'account_type': 'user',
      });

      ToastUtils.showSuccess('User created successfully.');
      return true;
    } catch (e) {
      ToastUtils.showError('Error creating user: $e');
      return false;
    }
  }

  Future<void> signOutAccount() async {
    try {
      Auth auth = Auth();
      AuthResult authResult = await auth.signOut();

      if (authResult.isSuccess) {
        Get.offAll(() => const LoginPage());
        ToastUtils.showSuccess("Successfully logged out. See you later!");
      } else {
        ToastUtils.showError(authResult.errorMessage ?? 'Unexpected error');
      }
    } catch (e) {
      ToastUtils.showError('Unexpected error: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final f_auth.FirebaseAuth auth = f_auth.FirebaseAuth.instance;

      await auth.sendPasswordResetEmail(email: email);
      Get.to(() => const PasswordResetSuccessPage());
      ToastUtils.showSuccess("Password reset email sent. Please check your inbox.");
    } catch (e) {
      ToastUtils.showError('Error sending password reset email: $e');
    }
  }

  Future<void> changeEmailUser(String newEmail, String currentPassword) async {
    try {
      Auth auth = Auth();
      f_auth.FirebaseAuth firebaseAuth = f_auth.FirebaseAuth.instance;
      f_auth.User? user = firebaseAuth.currentUser;

      if (user == null) {
        ToastUtils.showError('No user is currently signed in.');
        return;
      }

      f_auth.AuthCredential credential = f_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      f_auth.UserCredential userCredential = await user.reauthenticateWithCredential(credential);

      if (userCredential.user == null) {
        ToastUtils.showError('Failed to re-authenticate user.');
        return;
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      await user.sendEmailVerification();

      AuthResult authResult = await auth.signOut();

      if (authResult.isSuccess) {
        Get.offAll(() => const LoginPage());
        ToastUtils.showSuccess("Email changed successfully. Please verify your new email.");
      } else {
        ToastUtils.showError(authResult.errorMessage ?? 'Unexpected error during sign out.');
      }
    } catch (e) {
      ToastUtils.showError('Unexpected error: $e');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      f_auth.FirebaseAuth firebaseAuth = f_auth.FirebaseAuth.instance;
      f_auth.User? user = firebaseAuth.currentUser;

      if (user == null) {
        ToastUtils.showError('No user is currently signed in.');
        return;
      }

      f_auth.AuthCredential credential = f_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      f_auth.UserCredential userCredential = await user.reauthenticateWithCredential(credential);

      if (userCredential.user == null) {
        ToastUtils.showError('Failed to re-authenticate user.');
        return;
      }

      await user.updatePassword(newPassword);

      Auth auth = Auth();
      AuthResult authResult = await auth.signOut();

      if (authResult.isSuccess) {
        Get.offAll(() => const LoginPage());
        ToastUtils.showSuccess("Password changed successfully. Please log in again.");
      } else {
        ToastUtils.showError(authResult.errorMessage ?? 'Unexpected error during sign out.');
      }
    } catch (e) {
      ToastUtils.showError('Unexpected error: $e');
    }
  }

  Future<void> changePhoneNumber(String newPhoneNumber, String currentPassword) async {
    final f_auth.FirebaseAuth auth = f_auth.FirebaseAuth.instance;

    try {
      f_auth.User? user = auth.currentUser;

      if (user == null) {
        ToastUtils.showError('No user is currently signed in.');
        return;
      }

      f_auth.AuthCredential credential = f_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      f_auth.UserCredential userCredential = await user.reauthenticateWithCredential(credential);

      if (userCredential.user == null) {
        ToastUtils.showError('Failed to re-authenticate user.');
        return;
      }

      await auth.verifyPhoneNumber(
        phoneNumber: newPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await user.updatePhoneNumber(credential);
          ToastUtils.showSuccess('Phone number updated successfully');
        },
        verificationFailed: (f_auth.FirebaseAuthException e) {
          ToastUtils.showError('Phone number verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          _showCodeInputDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout if needed
        },
      );

      ToastUtils.showSuccess('Phone number change process started successfully');
    } catch (e) {
      ToastUtils.showError('Error changing phone number: $e');
    }
  }

  void _showCodeInputDialog(String verificationId) {
    final TextEditingController codeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Enter SMS Code'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'SMS Code'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String smsCode = codeController.text;

              // Create a PhoneAuthCredential with the code
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              );

              try {
                // Update the phone number with the credential
                f_auth.User? user = f_auth.FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.updatePhoneNumber(credential);
                  ToastUtils.showSuccess("Phone number updated successfully.");
                  Get.back(); // Close the dialog
                }
              } catch (e) {
                ToastUtils.showError('Failed to verify code: $e');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
