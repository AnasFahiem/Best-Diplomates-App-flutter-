import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import '../../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 4));
    
    if (!mounted) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final isLoggedIn = await authVM.checkAuthStatus(); // Restore session

    if (!mounted) return;

    Widget nextScreen;
    
    if (isLoggedIn) {
      if (authVM.isAdmin) {
        nextScreen = const AdminDashboardScreen();
      } else {
        nextScreen = const HomeScreen();
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      nextScreen = seenOnboarding ? const LoginScreen() : const OnboardingScreen();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                  // Glow removed
                ),
                child: Image.asset(
                  'assets/imagesUi/logo.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'FUTURE DIPLOMATS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28, // Reduced from 32
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 1000),
              child: Text(
                'CRAFTING FUTURE LEADERS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.gold,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
