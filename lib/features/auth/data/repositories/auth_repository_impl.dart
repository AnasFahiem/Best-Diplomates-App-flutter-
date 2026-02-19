import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  Map<String, dynamic>? _loggedInProfile;
  bool _isAdmin = false;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>?> signIn({required String username, required String password, bool rememberMe = false}) async {
    final profile = await remoteDataSource.loginWithCredentials(username: username, password: password);
    
    if (profile != null) {
      _loggedInProfile = profile;
      // Check role in profile for admin status
      final role = profile['role'] as String?;
      _isAdmin = role == 'admin';

      // Persist login if requested
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', profile['id']);
      }
    } else {
      _loggedInProfile = null;
      _isAdmin = false;
    }
    
    return profile;
  }

  @override
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) return false;

      final profile = await remoteDataSource.getProfileById(userId);
      
      if (profile != null) {
        _loggedInProfile = profile;
        final role = profile['role'] as String?;
        _isAdmin = role == 'admin';
        return true;
      } else {
        // ID exists but profile not found (deleted?), clear storage
        await prefs.remove('user_id');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> changePassword({required String userId, required String newPassword}) async {
    await remoteDataSource.changePassword(userId: userId, newPassword: newPassword);
    _loggedInProfile = null; // Clear profile to force re-login
    _isAdmin = false;
  }



  @override
  bool get isAdmin => _isAdmin;

  @override
  Future<void> signOut() async {
    _loggedInProfile = null;
    _isAdmin = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    await remoteDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
  }

  @override
  Future<String> resetPassword({required String username}) async {
    return await remoteDataSource.resetPassword(username: username);
  }

  @override
  bool get isLoggedIn => _loggedInProfile != null;

  @override
  Map<String, dynamic>? get currentUserProfile => _loggedInProfile;
}
