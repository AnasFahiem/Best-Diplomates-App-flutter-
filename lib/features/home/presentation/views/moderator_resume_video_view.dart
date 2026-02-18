import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/application_view_model.dart';

class ModeratorResumeVideoView extends StatefulWidget {
  const ModeratorResumeVideoView({super.key});

  @override
  State<ModeratorResumeVideoView> createState() => _ModeratorResumeVideoViewState();
}

class _ModeratorResumeVideoViewState extends State<ModeratorResumeVideoView> {
  final _formKey = GlobalKey<FormState>();
  final _resumeController = TextEditingController();
  final _videoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appVm = context.read<ApplicationViewModel>();
    final existing = appVm.modApplication;
    if (existing != null) {
      _resumeController.text = existing['resume_url'] ?? '';
      _videoController.text = existing['video_link'] ?? '';
    }
  }

  @override
  void dispose() {
    _resumeController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resume & Video",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resume
                  Text("Resume / CV Link", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                  const SizedBox(height: 5),
                  Text(
                    "Paste a link to your resume (Google Drive, Dropbox, etc.)",
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _resumeController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.description, color: AppColors.grey),
                      hintText: "https://drive.google.com/...",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Video
                  Text("Video Introduction Link *", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                  const SizedBox(height: 5),
                  Text(
                    "Submit a short video introducing yourself.",
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _videoController,
                    validator: (value) => value == null || value.isEmpty ? 'Video link is required' : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.videocam, color: AppColors.grey),
                      hintText: "https://youtube.com/...",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: appVm.isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: appVm.isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : Text(
                              "Submit",
                              style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthViewModel>().currentUserProfile?['id']?.toString();
    if (userId == null) return;

    final appVm = context.read<ApplicationViewModel>();
    final resumeUrl = _resumeController.text.trim().isNotEmpty ? _resumeController.text.trim() : null;
    final success = await appVm.saveModeratorResumeVideo(userId, resumeUrl, _videoController.text.trim());

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submitted successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appVm.errorMessage ?? "Failed to save"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
