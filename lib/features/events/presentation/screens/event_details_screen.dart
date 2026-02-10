import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/data/models/conference_model.dart';

class EventDetailsScreen extends StatefulWidget {
  final ConferenceModel conference;

  const EventDetailsScreen({super.key, required this.conference});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    // Conference stock video
    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse('https://videos.pexels.com/video-files/855564/855564-hd_1920_1080_25fps.mp4'));
    _videoPlayerController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: false,
          looping: true,
          placeholder: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.conference.imageUrl.isNotEmpty 
                      ? widget.conference.imageUrl 
                      : "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?q=80&w=1000&auto=format&fit=crop",
                  fit: BoxFit.cover,
                ),
                Container(color: Colors.black.withOpacity(0.4)),
                const Center(child: Icon(Icons.play_circle_fill, color: AppColors.white, size: 50)),
              ],
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                "Video Unavailable",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            iconTheme: const IconThemeData(color: AppColors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.conference.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.white, 
                    fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                    widget.conference.imageUrl.isNotEmpty 
                        ? widget.conference.imageUrl 
                        : "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?q=80&w=1000&auto=format&fit=crop",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                   // Invitation Warning
                   FadeInDown(
                     child: Container(
                       padding: const EdgeInsets.all(15),
                       decoration: BoxDecoration(
                         color: Colors.orange.withOpacity(0.1),
                         border: Border.all(color: Colors.orange),
                         borderRadius: BorderRadius.circular(10),
                       ),
                       child: Row(
                         children: [
                           const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
                           const SizedBox(width: 15),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   "Invitation Required",
                                   style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.orange[800]),
                                 ),
                                 Text(
                                   "You must have an official invitation to attend this conference.",
                                   style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[800]),
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(height: 25),

                  // Conference Details
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(Icons.calendar_today, "Date", 
                            "${widget.conference.startDate.day}/${widget.conference.startDate.month} - ${widget.conference.endDate.day}/${widget.conference.endDate.month}, ${widget.conference.endDate.year}"),
                        _buildDetailItem(Icons.location_on, "Location", widget.conference.location),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Documentary / Trailer
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Conference Highlights(Documentary)",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                              ? Chewie(controller: _chewieController!)
                              : const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Payment & Acceptance Status
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Status",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 15),
                        _buildStatusCard(
                          title: "Payment Status",
                          status: "Pending",
                          icon: Icons.payment,
                          color: Colors.orange,
                          actionLabel: "Pay Now",
                          onAction: () {},
                        ),
                         const SizedBox(height: 15),
                        _buildStatusCard(
                          title: "Letter of Acceptance",
                          status: "Not Issued",
                          icon: Icons.description,
                          color: AppColors.grey,
                          actionLabel: "Check Requirements",
                          onAction: null,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Icon(icon, color: AppColors.gold, size: 24),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12)),
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
    required IconData icon,
    required Color color,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12)),
                Text(status, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
        ],
      ),
    );
  }
}
