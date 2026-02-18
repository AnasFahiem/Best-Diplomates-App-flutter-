abstract class AuthRepository {
  Future<Map<String, dynamic>?> signIn({required String username, required String password});
  Future<void> changePassword({required String userId, required String newPassword});
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<String> resetPassword({required String username});
  bool get isLoggedIn;
  Map<String, dynamic>? get currentUserProfile;
}
