import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/auth_view_model.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return Scaffold(
                backgroundColor: AppColors.white,
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: FadeInDown(
                            child: Image.asset(
                              'assets/imagesUi/logo.png',
                              height: 120, 
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeInDown(
                          child: Text(
                            "Welcome Back",
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            "Enter your credentials to continue",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              FadeInUp(
                                delay: const Duration(milliseconds: 300),
                                child: TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    labelText: "Username / Email",
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInUp(
                                delay: const Duration(milliseconds: 400),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: AppColors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              FadeInUp(
                                delay:const Duration(milliseconds: 500),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.inter(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              FadeInUp(
                                delay: const Duration(milliseconds: 600),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: authViewModel.isLoading
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!.validate()) {
                                              bool success = await authViewModel.login(
                                                  _usernameController.text.trim(),
                                                  _passwordController.text);
                                              if (success && context.mounted) {
                                                if (authViewModel.mustChangePassword) {
                                                  // First login — force password change
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                                                  );
                                                } else if (authViewModel.isAdmin) {
                                                  // Admin user — redirect to admin dashboard
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                                                  );
                                                } else {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                                  );
                                                }
                                              } else if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(authViewModel.errorMessage ?? 'Login failed'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    child: authViewModel.isLoading
                                        ? const CircularProgressIndicator(color: AppColors.white)
                                        : Text(
                                            "LOGIN",
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInUp(
                                delay: const Duration(milliseconds: 700),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                                          );
                                      },
                                      child: Text(
                                        "Register",
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        );
  }
}
