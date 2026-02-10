import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class SupportCenterView extends StatelessWidget {
  const SupportCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Support Center",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 80, color: AppColors.grey),
            const SizedBox(height: 20),
            Text(
              "No Support Requests",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Start a new request if you need help.",
              style: GoogleFonts.poppins(color: AppColors.grey),
            ),
             const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                ),
                child: Text(
                  "Contact Support",
                  style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
