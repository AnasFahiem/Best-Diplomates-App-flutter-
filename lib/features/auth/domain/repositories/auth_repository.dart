import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signIn({required String email, required String password});
  Future<AuthResponse> signUp({required String email, required String password, required String firstName, required String lastName});
  Future<void> signOut();
  bool get isLoggedIn;
  User? get currentUser;
}
