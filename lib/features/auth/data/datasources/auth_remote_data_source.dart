import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>?> loginWithCredentials({required String username, required String password});
  Future<void> changePassword({required String userId, required String newPassword});
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<String> resetPassword({required String username});

  Session? get currentSession;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Map<String, dynamic>?> loginWithCredentials({required String username, required String password}) async {
    final response = await supabaseClient
        .from('profiles')
        .select()
        .eq('username', username)
        .eq('login_password', password)
        .maybeSingle();

    return response;
  }

  @override
  Future<void> changePassword({required String userId, required String newPassword}) async {
    await supabaseClient
        .from('profiles')
        .update({
          'login_password': newPassword,
          'password_changed': true,
        })
        .eq('id', userId);
  }

  @override
  Future<void> signOut() async {
    // Clear any local session state if needed
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await supabaseClient.rpc('delete_user');
  }

  @override
  Future<String> resetPassword({required String username}) async {
    // Verify this username exists
    final user = await supabaseClient
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();

    if (user == null) {
      throw Exception('No account found with that username');
    }

    // Generate a random temporary password
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final tempPassword = List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();

    // Update login_password and force password change on next login
    await supabaseClient
        .from('profiles')
        .update({
          'login_password': tempPassword,
          'password_changed': false,
        })
        .eq('id', user['id']);

    return tempPassword;
  }



  @override
  Session? get currentSession => supabaseClient.auth.currentSession;
}
