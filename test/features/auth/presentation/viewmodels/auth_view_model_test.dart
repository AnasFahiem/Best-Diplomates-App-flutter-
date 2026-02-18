import 'package:flutter_test/flutter_test.dart';
import 'package:best_diplomats/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:best_diplomats/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldThrowError = false;
  bool shouldReturnNull = false;
  
  Map<String, dynamic>? _mockProfile;
  bool _isLoggedIn = false;

  @override
  Future<Map<String, dynamic>?> signIn({required String username, required String password}) async {
    if (shouldThrowError) throw Exception('Unexpected error');
    if (shouldReturnNull) return null;
    
    _isLoggedIn = true;
    _mockProfile = {
      'id': '123',
      'username': username,
      'login_password': password,
      'first_name': 'Test',
      'last_name': 'User',
    };
    return _mockProfile;
  }

  @override
  Future<void> signOut() async {
    _isLoggedIn = false;
    _mockProfile = null;
  }

  @override
  Future<void> deleteAccount() async {
    _isLoggedIn = false;
    _mockProfile = null;
  }

  @override
  Future<void> resetPasswordForEmail({required String email}) async {
    if (shouldThrowError) throw Exception('Failed to send reset email');
  }

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  Map<String, dynamic>? get currentUserProfile => _mockProfile;
}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(authRepository: mockRepository);
  });

  test('Initial state checks', () {
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, null);
    expect(viewModel.currentUserProfile, null);
  });

  test('login success with valid credentials', () async {
    final result = await viewModel.login('FD-testuser', 'TestPass123');
    expect(result, true);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, null);
    expect(viewModel.currentUserProfile?['username'], 'FD-testuser');
  });

  test('login failure with invalid credentials', () async {
    mockRepository.shouldReturnNull = true;
    final result = await viewModel.login('wrong-user', 'wrongpass');
    expect(result, false);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, 'Invalid username or password');
  });

  test('login failure with unexpected error', () async {
    mockRepository.shouldThrowError = true;
    final result = await viewModel.login('test', 'password');
    expect(result, false);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, 'An unexpected error occurred');
  });

  test('signOut clears user profile', () async {
    await viewModel.login('FD-testuser', 'TestPass123');
    expect(viewModel.currentUserProfile, isNotNull);
    
    await viewModel.signOut();
    expect(viewModel.currentUserProfile, null);
  });
}
