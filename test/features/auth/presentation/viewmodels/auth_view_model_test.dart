import 'package:flutter_test/flutter_test.dart';
import 'package:best_diplomats/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:best_diplomats/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldThrowError = false;
  bool shouldThrowAuthException = false;
  
  User? _mockUser;
  bool _isLoggedIn = false;

  void setMockUser(User user) {
    _mockUser = user;
    _isLoggedIn = true;
  }

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    if (shouldThrowError) throw Exception('Unexpected error');
    if (shouldThrowAuthException) throw const AuthException('Invalid login credentials');
    
    _isLoggedIn = true;
    _mockUser = User(
      id: '123',
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
    );
    return AuthResponse(
      session: Session(
        accessToken: 'token', 
        tokenType: 'bearer', 
        user: _mockUser!,
      ), 
      user: _mockUser!,
    );
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password, required String fullName}) async {
    if (shouldThrowError) throw Exception('Unexpected error');
    if (shouldThrowAuthException) throw const AuthException('Signup failed');

    _isLoggedIn = true;
    _mockUser = User(
      id: '123',
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      appMetadata: {},
      userMetadata: {'full_name': fullName},
      aud: 'authenticated',
    );
    return AuthResponse(
      session: Session(
        accessToken: 'token', 
        tokenType: 'bearer', 
        user: _mockUser!,
      ), 
      user: _mockUser!,
    );
  }

  @override
  Future<void> signOut() async {
    _isLoggedIn = false;
    _mockUser = null;
  }

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  User? get currentUser => _mockUser;
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
    expect(viewModel.currentUser, null);
  });

  test('login success', () async {
    final result = await viewModel.login('test@example.com', 'password');
    expect(result, true);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, null);
    expect(viewModel.currentUser?.email, 'test@example.com');
  });

  test('login failure with AuthException', () async {
    mockRepository.shouldThrowAuthException = true;
    final result = await viewModel.login('test@example.com', 'password');
    expect(result, false);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, 'Invalid login credentials');
  });

  test('signup success', () async {
    final result = await viewModel.signup('Test User', 'test@example.com', 'password');
    expect(result, true);
    expect(viewModel.isLoading, false);
    expect(viewModel.errorMessage, null);
    expect(viewModel.currentUser?.userMetadata?['full_name'], 'Test User');
  });

  test('signOut clears user', () async {
    await viewModel.login('test@example.com', 'password');
    expect(viewModel.currentUser, isNotNull);
    
    await viewModel.signOut();
    expect(viewModel.currentUser, null);
  });
}
