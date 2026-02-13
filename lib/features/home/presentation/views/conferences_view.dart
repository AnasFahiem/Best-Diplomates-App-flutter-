import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../events/presentation/screens/event_details_screen.dart';
import '../viewmodels/home_view_model.dart';
import '../../data/models/conference_model.dart';

class ConferencesView extends StatelessWidget {
  const ConferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isConferencesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        if (viewModel.conferencesErrorMessage != null) {
          return Center(child: Text(viewModel.conferencesErrorMessage!));
        }

        // Sort conferences by date to find the nearest one
        final sortedConferences = List<ConferenceModel>.from(viewModel.conferences)
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

        final happeningSoon = <ConferenceModel>[];
        final scheduled = <ConferenceModel>[];

        if (sortedConferences.isNotEmpty) {
           // The first one is the nearest, so it goes to "Happening Soon"
           happeningSoon.add(sortedConferences.first);
           
           // The rest go to "Scheduled"
           if (sortedConferences.length > 1) {
             scheduled.addAll(sortedConferences.sublist(1));
           }
        }

        return ResponsiveContainer(
          child: SingleChildScrollView(
            child: ResponsivePadding(
              mobile: 16,
              tablet: 24,
              desktop: 32,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Happening Soon Section
                if (happeningSoon.isNotEmpty) ...[
                  FadeInLeft(
                    child: Text(
                      "Happening Soon",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: happeningSoon.length,
                      itemBuilder: (context, index) {
                        return _buildHappeningSoonCard(context, happeningSoon[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // Scheduled Conferences Section
                if (scheduled.isNotEmpty) ...[
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      "Scheduled Conferences",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scheduled.length,
                    itemBuilder: (context, index) {
                      return _buildScheduledConferenceTile(context, scheduled[index], index);
                    },
                  ),
                ],
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildHappeningSoonCard(BuildContext context, ConferenceModel conference) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailsScreen(conference: conference)),
        );
      },
      child: Container(
        width: context.responsiveValue(mobile: 300, tablet: 350, desktop: 400),
        margin: EdgeInsets.only(
          right: ResponsiveUtils.spacing(context, mobile: 15, tablet: 20, desktop: 24),
          bottom: 10,
        ),
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(conference.imageUrl.isNotEmpty 
                        ? conference.imageUrl 
                        : "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04"), // Fallback
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: ResponsiveUtils.padding(context, mobile: 12, tablet: 14, desktop: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conference.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.gold),
                      const SizedBox(width: 5),
                      Text(
                        "${conference.startDate.day}/${conference.startDate.month}/${conference.startDate.year}", // formatting needed
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
                      ),
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

  Widget _buildScheduledConferenceTile(BuildContext context, ConferenceModel conference, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 300 + (index * 100)),
      child: GestureDetector(
        onTap: () {
           Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailsScreen(conference: conference)),
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
            contentPadding: ResponsiveUtils.padding(context, mobile: 12, tablet: 16, desktop: 20),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.date_range, color: AppColors.primaryBlue),
            ),
            title: Text(
              conference.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.primaryBlue,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  conference.location,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
                ),
                Text(
                  "${conference.startDate.day}/${conference.startDate.month} - ${conference.endDate.day}/${conference.endDate.month}, ${conference.endDate.year}",
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
