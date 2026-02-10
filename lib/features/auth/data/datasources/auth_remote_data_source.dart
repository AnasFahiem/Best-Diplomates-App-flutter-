import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signInWithPassword({required String email, required String password});
  Future<AuthResponse> signUp({required String email, required String password, required Map<String, dynamic> data});
  Future<void> signOut();
  Session? get currentSession;
  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AuthResponse> signInWithPassword({required String email, required String password}) async {
    return await supabaseClient.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password, required Map<String, dynamic> data}) async {
    return await supabaseClient.auth.signUp(email: email, password: password, data: data);
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  User? get currentUser => supabaseClient.auth.currentUser;
}
