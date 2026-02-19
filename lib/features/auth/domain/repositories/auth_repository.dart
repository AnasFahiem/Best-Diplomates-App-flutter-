abstract class AuthRepository {
  Future<Map<String, dynamic>?> signIn({required String username, required String password, bool rememberMe = false});
  Future<void> changePassword({required String userId, required String newPassword});
  Future<bool> restoreSession();
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<String> resetPassword({required String username});

  bool get isLoggedIn;
  bool get isAdmin;
  Map<String, dynamic>? get currentUserProfile;
}
