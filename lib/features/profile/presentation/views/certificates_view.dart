import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CertificatesView extends StatelessWidget {
  const CertificatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Certificates",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: AppColors.grey),
            const SizedBox(height: 20),
            Text(
              "No Certificates Yet",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your earned certificates will appear here.",
              style: GoogleFonts.poppins(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
