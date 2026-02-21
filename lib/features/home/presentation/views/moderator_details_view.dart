import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/application_view_model.dart';
import 'application_status_view.dart';
import 'moderator_application_form_view.dart';
import 'moderator_resume_video_view.dart';

class ModeratorDetailsView extends StatefulWidget {
  const ModeratorDetailsView({super.key});

  @override
  State<ModeratorDetailsView> createState() => _ModeratorDetailsViewState();
}

class _ModeratorDetailsViewState extends State<ModeratorDetailsView> {
  bool _isExpanded = false;

  final String _fullDescription = 
      "As a Conference Moderator at Future Diplomats, you play a pivotal role in ensuring the smooth conduct of our diplomatic simulations. "
      "You are the bridge between the dais and the delegates, facilitating debate, maintaining order, and guiding the flow of the committee sessions.\n\n"
      "This position requires exceptional public speaking abilities, a deep understanding of Rules of Procedure (ROP), and the ability to handle high-pressure situations with grace and authority. "
      "Moderators are responsible for chairing sessions, evaluating delegate performance, and ensuring that all debates remain constructive and respectful.\n\n"
      "Key Responsibilities:\n"
      "• Facilitating committee sessions and moderating debates.\n"
      "• Enforcing the Rules of Procedure and maintaining decorum.\n"
      "• Guiding delegates in drafting resolutions and working papers.\n"
      "• Providing feedback and mentorship to delegates.\n"
      "• Collaborating with the Secretariat to ensure conference success.";

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  void _loadApplication() {
    final userId = context.read<AuthViewModel>().currentUserProfile?['id']?.toString();
    if (userId != null) {
      context.read<ApplicationViewModel>().loadModeratorApplication(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Conference Moderator",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVm, _) {
          final isStep1Completed = appVm.isModStep1Completed;
          final isStep2Completed = appVm.isModStep2Completed;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About this Position
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                            Expanded(
                              child: Text(
                                "About this Position",
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                overflow: TextOverflow.ellipsis,
                              ),
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

                // Step 1: Manage Your Application
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildStepCard(
                    stepNumber: "1",
                    title: "Manage Your Application",
                    description: "Fill in your personal details and previous experience.",
                    icon: Icons.assignment_ind,
                    isCompleted: isStep1Completed,
                    onTap: () async {
                       final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModeratorApplicationFormView()),
                      );
                      if (result == true) {
                        _loadApplication();
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 20),

                // Step 2: Resume & Video Introduction
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildStepCard(
                    stepNumber: "2",
                    title: "Resume & Video Intro",
                    description: "Upload your CV and a brief video introduction showcasing your skills.",
                    icon: Icons.video_library,
                    isCompleted: isStep2Completed,
                    isLocked: !isStep1Completed,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModeratorResumeVideoView()),
                      );
                      if (result == true) {
                        _loadApplication();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Step 3: Check Application status
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildStepCard(
                    stepNumber: "3",
                    title: "Check Application Status",
                    description: "Track the progress of your application and view results.",
                    icon: Icons.fact_check,
                    isLocked: !isStep2Completed,
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ApplicationStatusView()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked ? () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete the previous step first.")),
        );
      } : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.lightGrey : AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
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
                  Text(
                    title, 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: isLocked ? AppColors.grey : AppColors.primaryBlue
                    )
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
