import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/auth_view_model.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // You'd typically use GetIt or Provider to access AuthViewModel, 
    // ensuring it's provided at the top level or here.
    // For now, I'll assume it's provided or I'll use ChangeNotifierProvider here locally for simplicity if not in main.
    return ChangeNotifierProvider(
        create: (_) => AuthViewModel(),
        child: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return Scaffold(
                backgroundColor: AppColors.white,
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        FadeInDown(
                          child: Text(
                            "Welcome Back",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                        ),
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            "Sign in to continue",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.grey,
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
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: "Email",
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                        return 'Please enter a valid email';
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
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                    prefixIcon: Icon(Icons.lock_outline),
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
                                    onPressed: () {},
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.poppins(
                                        color: AppColors.navyBlue,
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
                                                  _emailController.text,
                                                  _passwordController.text);
                                              if (success && context.mounted) {
                                                 Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                                  );
                                              }
                                            }
                                          },
                                    child: authViewModel.isLoading
                                        ? const CircularProgressIndicator(color: AppColors.gold)
                                        : const Text("LOGIN"),
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
                                      style: GoogleFonts.poppins(color: AppColors.grey),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                                          );
                                      },
                                      child: Text(
                                        "Sign Up",
                                        style: GoogleFonts.poppins(
                                          color: AppColors.navyBlue,
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
        )
    );
  }
}
