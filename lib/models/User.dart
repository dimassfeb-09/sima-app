import 'package:firebase_auth/firebase_auth.dart' as f_auth;
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
    String? phone = await _getPhoneFromSupabase(currentUser.uid);

    var userDetail = UserDetail(
      uid: currentUser.uid,
      displayName: currentUser.displayName ?? '',
      email: currentUser.email ?? '',
      nik: nik,
      phoneNumber: "+62$phone" ?? '',
      photoURL: currentUser.photoURL ?? '',
      isSignInWithGoogle: isGoogleSignIn,
    );

    return userDetail;
  }

  Future<String?> _getNikFromSupabase(String uid) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('users').select('nik').eq('uid', uid).single();

      return response['nik'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getPhoneFromSupabase(String uid) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('users').select('phone').eq('uid', uid).single();

      return response['phone'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<int?> getUserIdByUID(String uid) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('users').select('id').eq('uid', uid).single();
      return response['id'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createUser({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String nik,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('users').insert({
        'uid': uid,
        'full_name': fullName,
        'email': email,
        'nik': nik,
        'phone': phone,
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
      ToastUtils.showSuccess(
          "Password reset email sent. Please check your inbox.");
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

      f_auth.UserCredential userCredential =
          await user.reauthenticateWithCredential(credential);

      if (userCredential.user == null) {
        ToastUtils.showError('Failed to re-authenticate user.');
        return;
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      await user.sendEmailVerification();

      AuthResult authResult = await auth.signOut();

      if (authResult.isSuccess) {
        Get.offAll(() => const LoginPage());
        ToastUtils.showSuccess(
            "Email changed successfully. Please verify your new email.");
      } else {
        ToastUtils.showError(
            authResult.errorMessage ?? 'Unexpected error during sign out.');
      }
    } catch (e) {
      ToastUtils.showError('Unexpected error: $e');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
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

      f_auth.UserCredential userCredential =
          await user.reauthenticateWithCredential(credential);

      if (userCredential.user == null) {
        ToastUtils.showError('Failed to re-authenticate user.');
        return;
      }

      await user.updatePassword(newPassword);

      Auth auth = Auth();
      AuthResult authResult = await auth.signOut();

      if (authResult.isSuccess) {
        Get.offAll(() => const LoginPage());
        ToastUtils.showSuccess(
            "Password changed successfully. Please log in again.");
      } else {
        ToastUtils.showError(
            authResult.errorMessage ?? 'Unexpected error during sign out.');
      }
    } catch (e) {
      ToastUtils.showError('Unexpected error: $e');
    }
  }

  Future<void> changePhoneNumber(
      String newPhoneNumber, String currentPassword) async {
    final f_auth.FirebaseAuth auth = f_auth.FirebaseAuth.instance;

    try {
      f_auth.User? user = auth.currentUser;

      if (user == null) {
        ToastUtils.showError('No user is currently signed in.');
        return;
      }

      if (user.email == null) {
        ToastUtils.showError('Current user has no email.');
        return;
      }

      f_auth.AuthCredential credential = f_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      f_auth.UserCredential userCredential =
          await user.reauthenticateWithCredential(credential);

      if (userCredential.user == null) {
        ToastUtils.showError('Failed to re-authenticate user.');
        return;
      }

      final supabase = Supabase.instance.client;

      await supabase.from('users').update({
        'phone': newPhoneNumber,
      }).eq('uid', user.uid);

      ToastUtils.showSuccess('Phone number updated successfully in Supabase');
      Get.back();
    } catch (e) {
      print('Exception: $e');
      ToastUtils.showError('An unexpected error occurred: $e');
    }
  }
}
