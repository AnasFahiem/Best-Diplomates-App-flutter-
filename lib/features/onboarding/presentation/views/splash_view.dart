import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/views/login_view.dart'; // Updated
import '../../../../features/home/presentation/views/home_view.dart'; // Updated
import '../../../../features/admin/presentation/views/admin_dashboard_view.dart'; // Updated
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import 'onboarding_view.dart'; // Anticipating change

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
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
        nextScreen = const AdminDashboardView(); // Updated
      } else {
        nextScreen = const HomeView(); // Updated
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      nextScreen = seenOnboarding ? const LoginView() : const OnboardingView(); // Updated
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
