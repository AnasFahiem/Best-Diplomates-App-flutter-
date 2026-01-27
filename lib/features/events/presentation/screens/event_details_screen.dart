import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.navyBlue,
            iconTheme: const IconThemeData(color: AppColors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "Diplomatic Summit 2024",
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.white, 
                    fontWeight: FontWeight.bold),
              ),
              background: Container(
                color: AppColors.navyBlue, // Placeholder
                child: const Center(
                  child: Icon(Icons.image, size: 100, color: Colors.white24),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Conference",
                            style: GoogleFonts.poppins(color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                         const SizedBox(width: 5),
                        Text("25 Oct, 2024", style: GoogleFonts.poppins(color: AppColors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      "About the Event",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      "Join us for the most prestigious diplomatic simulation of the year. This event brings together young leaders from over 50 countries to debate global issues, draft resolutions, and experience the life of a diplomat.\n\nKey Highlights:\n- Professional Networking\n- Guest Speakers\n- Award Ceremony",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),
                   const SizedBox(height: 30),
                   FadeInUp(
                     delay: const Duration(milliseconds: 300),
                     child: Text(
                      "Gallery",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                   ),
                   const SizedBox(height: 10),
                   SizedBox(
                     height: 100,
                     child: ListView.builder(
                       scrollDirection: Axis.horizontal,
                       itemCount: 4,
                       itemBuilder: (context, index) {
                         return Container(
                           width: 100,
                           margin: const EdgeInsets.only(right: 10),
                           decoration: BoxDecoration(
                             color: AppColors.grey.withOpacity(0.3),
                             borderRadius: BorderRadius.circular(10),
                           ),
                           child: const Icon(Icons.image, color: Colors.white),
                         );
                       },
                     ),
                   ),
                   const SizedBox(height: 100), // Spacing for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Register logic
          },
          child: const Text("REGISTER NOW"),
        ),
      ),
    );
  }
}
