import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../events/presentation/screens/event_details_screen.dart';

class ConferencesView extends StatelessWidget {
  const ConferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Happening Soon Section
            FadeInLeft(
              child: Text(
                "Happening Soon",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildHappeningSoonCard(context, index);
                },
              ),
            ),
            
            const SizedBox(height: 30),

            // Scheduled Conferences Section
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: Text(
                "Scheduled Conferences",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildScheduledConferenceTile(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHappeningSoonCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventDetailsScreen()),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.navyBlue, // Placeholder for image
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                  child: Icon(Icons.event, color: Colors.white.withOpacity(0.5), size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Diplomatic Summit 2024",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.gold),
                      const SizedBox(width: 5),
                      Text("Oct 25, 2024", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledConferenceTile(BuildContext context, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 300 + (index * 100)),
      child: GestureDetector(
        onTap: () {
           Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventDetailsScreen()),
        );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.navyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.date_range, color: AppColors.navyBlue),
            ),
            title: Text(
              "Future Leaders Conference",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.navyBlue,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  "New York, USA",
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
                ),
                Text(
                  "Nov 12 - 15, 2024",
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.lightGrey),
          ),
        ),
      ),
    );
  }
}
