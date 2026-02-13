import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/responsive_layout.dart';
import 'representative_details_form_view.dart';

import 'video_portfolio_view.dart';

class CountryRepresentativeDetailsView extends StatefulWidget {
  const CountryRepresentativeDetailsView({super.key});

  @override
  State<CountryRepresentativeDetailsView> createState() => _CountryRepresentativeDetailsViewState();
}

class _CountryRepresentativeDetailsViewState extends State<CountryRepresentativeDetailsView> {
  bool _isExpanded = false;
  bool _isStep1Completed = false;
  bool _isStep2Completed = false;

  final String _fullDescription = 
      "As a Country Representative, you will be the face of Best Diplomats in your nation. "
      "You will lead delegations, organize local chapters, and facilitate diplomatic simulations that empower young leaders. "
      "This role requires strong communication skills, a passion for international relations, and a commitment to our mission of crafting future leaders.\n\n"
      "Responsibilities include:\n"
      "• Recruiting and mentoring delegates for international conferences.\n"
      "• Promoting Best Diplomats events and initiatives on social media and local networks.\n"
      "• Acting as a liaison between the headquarters and your local community.\n"
      "• Organizing pre-departure sessions and training for your delegation.\n"
      "• Representing your country with pride and professionalism at our global summits.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Country Representative",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.padding(context, mobile: 20, tablet: 32, desktop: 40),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. About this Position
            FadeInDown(
              child: Container(
                padding: ResponsiveUtils.padding(context, mobile: 20, tablet: 24, desktop: 28),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.gold),
                        const SizedBox(width: 10),
                        Text(
                          "About this Position",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isExpanded ? _fullDescription : "${_fullDescription.substring(0, 150)}...",
                        style: GoogleFonts.poppins(color: AppColors.grey, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _isExpanded ? "Read Less" : "Read More",
                            style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                          ),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.primaryBlue,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: Text(
                "Steps to Apply",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 20),

            // Step 1
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildStepCard(
                stepNumber: "1",
                title: "Add / Edit Details",
                description: "Provide details about your social media, education, and work experience.",
                icon: Icons.edit_note,
                isCompleted: _isStep1Completed, 
                onTap: () async {
                   final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RepresentativeDetailsFormView()),
                  );
                  if (result == true) {
                    setState(() {
                      _isStep1Completed = true;
                    });
                  }
                },
              ),
            ),
            
            const SizedBox(height: 20),

            // Step 2
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildStepCard(
                stepNumber: "2",
                title: "Add Video Portfolio",
                description: "Record a short video explaining why you are the best fit for this role. (Required)",
                icon: Icons.videocam,
                isCompleted: _isStep2Completed,
                isRequired: true,
                isLocked: !_isStep1Completed, // Locked if Step 1 is not done
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VideoPortfolioView()),
                  );
                  if (result == true) {
                    setState(() {
                      _isStep2Completed = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: null, // Disabled until steps are complete
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey, // Disabled color initially
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            "Submit Application",
            style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isCompleted = false,
    bool isRequired = false,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete the previous step first.")),
        );
      } : onTap,
      child: Container(
        padding: ResponsiveUtils.padding(context, mobile: 20, tablet: 24, desktop: 28),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.lightGrey : AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
          border: isRequired && !isLocked ? Border.all(color: AppColors.gold.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLocked 
                  ? AppColors.grey.withOpacity(0.3) 
                  : (isCompleted ? Colors.green.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLocked
                  ? const Icon(Icons.lock, size: 20, color: AppColors.grey)
                  : (isCompleted 
                      ? const Icon(Icons.check, color: Colors.green)
                      : Text(stepNumber, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue))),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title, 
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: isLocked ? AppColors.grey : AppColors.primaryBlue
                        )
                      ),
                      if (isRequired && !isLocked) ...[
                        const SizedBox(width: 5),
                        Text("*", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(description, style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (!isLocked)
             const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
