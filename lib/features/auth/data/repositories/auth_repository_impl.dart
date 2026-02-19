import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  Map<String, dynamic>? _loggedInProfile;
  bool _isAdmin = false;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>?> signIn({required String username, required String password}) async {
    final profile = await remoteDataSource.loginWithCredentials(username: username, password: password);
    
    if (profile != null) {
      _loggedInProfile = profile;
      // Check role in profile for admin status
      final role = profile['role'] as String?;
      _isAdmin = role == 'admin';
    } else {
      _loggedInProfile = null;
      _isAdmin = false;
    }
    
    return profile;
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
