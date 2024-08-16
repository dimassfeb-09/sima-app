import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/auth_interface.dart';

class AuthResult {
  String? uid;
  bool isSuccess;
  String? errorMessage;
  AuthResult({this.uid, required this.isSuccess, this.errorMessage});
}

class Auth implements AuthInterface {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(
        isSuccess: userCredential.user != null,
        uid: userCredential.user?.uid,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(isSuccess: false, errorMessage: _handleAuthException(e));
    } catch (e) {
      return AuthResult(isSuccess: false, errorMessage: 'Error during sign in: $e');
    }
  }

  @override
  Future<AuthResult> signUpWithEmailAndPassword({
    required String name,
    required String nik,
    required String email,
    required String password,
  }) async {
    try {
      // Create a new user with email and password
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with display name
      await userCredential.user?.updateProfile(displayName: name);

      // Insert user data into Supabase
      await _supabaseClient.from('users').insert({
        'uid': userCredential.user?.uid,
        'full_name': name,
        'email': email,
        'nik': nik,
      }).onError(
        (error, stackTrace) async {
          await userCredential.user?.delete();
          return AuthResult(
            isSuccess: false,
            errorMessage: 'Failed to insert user data: ${error?.toString() ?? ''}',
          );
        },
      );

      return AuthResult(
        uid: userCredential.user?.uid,
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _handleAuthException(e),
      );
    } catch (e) {
      print(e); // Log unexpected errors for debugging
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Error during sign up: $e',
      );
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(isSuccess: false, errorMessage: 'Sign in aborted by user.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return AuthResult(
        uid: userCredential.user?.uid,
        isSuccess: userCredential.user != null,
      );
    } catch (e) {
      return AuthResult(isSuccess: false, errorMessage: 'Error during Google sign in: $e');
    }
  }

  @override
  Future<AuthResult> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(isSuccess: false, errorMessage: 'Sign in aborted by user.');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return AuthResult(
        uid: userCredential.user?.uid,
        isSuccess: userCredential.user != null,
      );
    } catch (e) {
      print(e);
      return AuthResult(isSuccess: false, errorMessage: 'Error during Google sign up: $e');
    }
  }

  Future<AuthResult> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return AuthResult(isSuccess: true);
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'Error during sign out: $e',
      );
    }
  }

  /// Maps FirebaseAuthException codes to user-friendly error messages.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'operation-not-allowed':
        return 'Signing in with email and password is not enabled.';
      case 'user-disabled':
        return 'The user account has been disabled by an administrator.';
      case 'user-not-found':
        return 'There is no user record corresponding to this email.';
      case 'wrong-password':
        return 'The password is invalid or the user does not have a password.';
      default:
        return 'An undefined error occurred: ${e.message}';
    }
  }
}
