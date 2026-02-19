import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({required AuthRepository authRepository}) : _authRepository = authRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _authRepository.isAdmin;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authRepository.signIn(username: username, password: password);
      _isLoading = false;
      notifyListeners();

      if (profile != null) {
        return true;
      } else {
        _errorMessage = 'Invalid username or password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    notifyListeners();
  }

  Future<String?> resetPassword(String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tempPassword = await _authRepository.resetPassword(username: username);
      _isLoading = false;
      notifyListeners();
      return tempPassword;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.deleteAccount();
      await _authRepository.signOut();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic>? get currentUserProfile => _authRepository.currentUserProfile;

  /// Whether the user must change their password (first login with received credentials)
  bool get mustChangePassword {
    final profile = _authRepository.currentUserProfile;
    if (profile == null) return false;
    return profile['password_changed'] != true;
  }

  Future<bool> changePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authRepository.currentUserProfile?['id'];
      if (userId == null) {
        _errorMessage = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _authRepository.changePassword(userId: userId.toString(), newPassword: newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to change password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
