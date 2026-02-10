import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await remoteDataSource.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password, required String firstName, required String lastName}) async {
    return await remoteDataSource.signUp(
      email: email, 
      password: password, 
      data: {
        'first_name': firstName,
        'last_name': lastName,
      },
    );
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  bool get isLoggedIn => remoteDataSource.currentSession != null;

  @override
  User? get currentUser => remoteDataSource.currentUser;
}
