import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'country_representative_details_view.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'moderator_details_view.dart';

class OpportunitiesView extends StatelessWidget {
  const OpportunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Illustrated Header
          _buildHeader(),

          const SizedBox(height: 20),

          // 2. Inspiring Quote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "\"Leadership is not about a title or a designation. It's about impact, influence and inspiration.\"",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(width: 50, height: 3, color: AppColors.gold),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. Opportunities List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildOpportunityCard(
                    title: "Country Representative Programme",
                    description: "Step onto the global stage. Represent your nation, lead your delegation, and make your voice heard in international diplomatic simulations.",
                    icon: Icons.public,
                    color: Colors.blueAccent,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CountryRepresentativeDetailsView()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildOpportunityCard(
                    title: "Conferences Moderators",
                    description: "Command the room. Facilitate high-level debates, ensure parliamentary procedure, and guide the flow of diplomatic discourse.",
                    icon: Icons.mic_external_on,
                    color: Colors.deepPurpleAccent,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModeratorDetailsView()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildOpportunityCard(
                    title: "Volunteer Programme",
                    description: "Be the backbone of change. Join our organizing team to create unforgettable experiences.",
                    icon: Icons.volunteer_activism,
                    color: Colors.teal,
                    isComingSoon: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: AppColors.navyBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: AppColors.white.withOpacity(0.05),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: AppColors.gold.withOpacity(0.1),
            ),
          ),
          
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                      boxShadow: [
                         BoxShadow(
                          color: AppColors.gold.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.rocket_launch, size: 60, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 25),
                FadeInDown(
                 child: Text(
                    "Join Best Diplomats Team",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "and Shape the Future",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.gold,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: isComingSoon ? Border.all(color: AppColors.grey.withOpacity(0.3)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isComingSoon ? AppColors.grey.withOpacity(0.2) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: isComingSoon ? AppColors.grey : color,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isComingSoon ? AppColors.grey : AppColors.navyBlue,
                          ),
                        ),
                      ),
                      if (isComingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Coming Soon",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                  ),
                  if (!isComingSoon) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "Learn More",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, size: 14, color: AppColors.navyBlue),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
