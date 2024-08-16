import '../models/Auth.dart';

abstract class AuthInterface {
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthResult> signUpWithEmailAndPassword({
    required String name,
    required String nik,
    required String email,
    required String password,
  });

  Future<AuthResult> signInWithGoogle();

  Future<AuthResult> signUpWithGoogle();
}
