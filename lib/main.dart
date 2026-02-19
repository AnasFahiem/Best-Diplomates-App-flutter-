import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';

import 'features/auth/presentation/viewmodels/auth_view_model.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';

import 'features/home/presentation/viewmodels/home_view_model.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/profile/presentation/viewmodels/profile_view_model.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/home/presentation/viewmodels/application_view_model.dart';
import 'features/home/data/repositories/application_repository_impl.dart';
import 'features/home/data/datasources/application_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/notification_service.dart';
import 'features/chat/presentation/viewmodels/chat_view_model.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ewdsxnsxajmfbpoierqj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3ZHN4bnN4YWptZmJwb2llcnFqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMTU5MzgsImV4cCI6MjA4NTc5MTkzOH0.YpylbCyU2ySsVf_2mo4P96QXz6nGBW6MrxDb1aBTY7A',
  );

  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(
          authRepository: AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSourceImpl(
              supabaseClient: Supabase.instance.client,
            ),
          ),
        )),
        ChangeNotifierProvider(create: (_) => HomeViewModel(
          homeRepository: HomeRepositoryImpl(
            remoteDataSource: HomeRemoteDataSourceImpl(
              supabaseClient: Supabase.instance.client,
            ),
          ),
        )..fetchConferences()..fetchOpportunities()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(
          profileRepository: ProfileRepositoryImpl(
            Supabase.instance.client,
          ),
        )),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel(
          repository: ApplicationRepositoryImpl(
            remoteDataSource: ApplicationRemoteDataSourceImpl(
              supabaseClient: Supabase.instance.client,
            ),
          ),
        )),
        ChangeNotifierProvider(create: (_) => ChatViewModel(
          repository: ChatRepositoryImpl(
            remoteDataSource: ChatRemoteDataSourceImpl(
              supabaseClient: Supabase.instance.client,
            ),
          ),
        )),
      ],
      child: MaterialApp(
        title: 'Future Diplomats',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
