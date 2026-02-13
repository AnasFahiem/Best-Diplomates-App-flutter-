import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/responsive_layout.dart';
import 'country_representative_details_view.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'moderator_details_view.dart';
import '../viewmodels/home_view_model.dart';
import '../../data/models/opportunity_model.dart';

class OpportunitiesView extends StatelessWidget {
  const OpportunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isOpportunitiesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        if (viewModel.opportunitiesErrorMessage != null) {
          return Center(child: Text(viewModel.opportunitiesErrorMessage!));
        }

        final opportunities = viewModel.opportunities;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Illustrated Header
              _buildHeader(),

              const SizedBox(height: 20),

              // 2. Inspiring Quote
              Padding(
                padding: ResponsiveUtils.horizontalPadding(context, mobile: 20, tablet: 32, desktop: 40),
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
                padding: ResponsiveUtils.horizontalPadding(context, mobile: 16, tablet: 24, desktop: 32),
                child: Column(
                  children: opportunities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final opportunity = entry.value;
                    return Column(
                      children: [
                        FadeInUp(
                          delay: Duration(milliseconds: 200 * (index + 1)),
                          child: _buildOpportunityCard(
                            context: context,
                            opportunity: opportunity,
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
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
    required BuildContext context,
    required OpportunityModel opportunity,
  }) {
    IconData iconData;
    Color color;

    switch (opportunity.icon) {
      case 'public':
        iconData = Icons.public;
        color = Colors.blueAccent;
        break;
      case 'mic_external_on':
        iconData = Icons.mic_external_on;
        color = Colors.deepPurpleAccent;
        break;
      case 'volunteer_activism':
        iconData = Icons.volunteer_activism;
        color = Colors.teal;
        break;
      default:
        iconData = Icons.star;
        color = AppColors.gold;
    }

    return GestureDetector(
      onTap: opportunity.isComingSoon 
          ? null 
          : () {
              if (opportunity.type == 'country_rep') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CountryRepresentativeDetailsView()),
                );
              } else if (opportunity.type == 'moderator') {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModeratorDetailsView()),
                );
              }
            },
      child: Container(
        padding: ResponsiveUtils.padding(context, mobile: 20, tablet: 24, desktop: 28),
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
          border: opportunity.isComingSoon ? Border.all(color: AppColors.grey.withOpacity(0.3)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: opportunity.isComingSoon ? AppColors.grey.withOpacity(0.2) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                iconData,
                color: opportunity.isComingSoon ? AppColors.grey : color,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    opportunity.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                  if (!opportunity.isComingSoon) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "Learn More",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryBlue),
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
