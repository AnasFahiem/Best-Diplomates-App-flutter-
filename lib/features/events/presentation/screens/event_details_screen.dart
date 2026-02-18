import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/data/models/conference_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final ConferenceModel conference;

  const EventDetailsScreen({super.key, required this.conference});

  /// Generate timeline entries from start/end dates
  List<_TimelineEntry> _generateTimeline() {
    final days = conference.endDate.difference(conference.startDate).inDays + 1;
    final entries = <_TimelineEntry>[];

    for (int i = 0; i < days; i++) {
      final date = conference.startDate.add(Duration(days: i));
      final dayNum = i + 1;

      String title;
      String subtitle;
      IconData icon;

      if (i == 0) {
        title = 'Day $dayNum — Arrival & Registration';
        subtitle = 'Check-in, badge collection, and welcome reception';
        icon = Icons.flight_land;
      } else if (i == days - 1) {
        title = 'Day $dayNum — Closing Ceremony';
        subtitle = 'Final session, certificate distribution, and farewell';
        icon = Icons.emoji_events;
      } else if (i == 1) {
        title = 'Day $dayNum — Opening Ceremony';
        subtitle = 'Keynote address, delegation introductions, and orientation';
        icon = Icons.campaign;
      } else {
        title = 'Day $dayNum — Committee Sessions';
        subtitle = 'Diplomatic simulations, debates, and working sessions';
        icon = Icons.groups;
      }

      entries.add(_TimelineEntry(
        date: date,
        title: title,
        subtitle: subtitle,
        icon: icon,
      ));
    }

    return entries;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final timeline = _generateTimeline();
    final durationDays = conference.endDate.difference(conference.startDate).inDays + 1;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            iconTheme: const IconThemeData(color: AppColors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                conference.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    conference.imageUrl.isNotEmpty
                        ? conference.imageUrl
                        : "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?q=80&w=1000&auto=format&fit=crop",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confirmed registration badge
                  FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Registration Confirmed",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green[800]),
                                ),
                                Text(
                                  "You are registered for this conference.",
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Quick Info Grid
                  FadeInUp(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.calendar_today,
                            "Date",
                            "${_formatDate(conference.startDate)} – ${_formatDate(conference.endDate)}, ${conference.endDate.year}",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.location_on,
                            "Location",
                            conference.location,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 50),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            Icons.schedule,
                            "Duration",
                            "$durationDays Days",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            Icons.verified,
                            "Status",
                            conference.isHappeningSoon ? "Happening Soon" : "Upcoming",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Description
                  if (conference.description.isNotEmpty) ...[
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "About This Conference",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              conference.description,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Conference Timeline
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Conference Timeline",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(timeline.length, (index) {
                          final entry = timeline[index];
                          final isLast = index == timeline.length - 1;
                          final isToday = _isToday(entry.date);
                          final isPast = entry.date.isBefore(DateTime.now()) && !isToday;

                          return _buildTimelineItem(
                            entry: entry,
                            isLast: isLast,
                            isToday: isToday,
                            isPast: isPast,
                            index: index,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required _TimelineEntry entry,
    required bool isLast,
    required bool isToday,
    required bool isPast,
    required int index,
  }) {
    final dotColor = isToday
        ? AppColors.gold
        : isPast
            ? Colors.green
            : AppColors.primaryBlue;

    final lineColor = isPast ? Colors.green.withValues(alpha: 0.3) : AppColors.primaryBlue.withValues(alpha: 0.2);

    return FadeInLeft(
      delay: Duration(milliseconds: 80 * index),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline rail
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: isToday ? 18 : 14,
                    height: isToday ? 18 : 14,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 3)
                          : null,
                      boxShadow: isToday
                          ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 8)]
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: lineColor,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Content card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.gold.withValues(alpha: 0.08) : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday ? Border.all(color: AppColors.gold, width: 1.5) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(entry.icon, size: 18, color: isToday ? AppColors.gold : AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isToday ? AppColors.gold : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "TODAY",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        if (isPast)
                          const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatFullDate(entry.date),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntry {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;

  _TimelineEntry({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
