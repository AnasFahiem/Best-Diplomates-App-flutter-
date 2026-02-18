import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/application_view_model.dart';

class VideoPortfolioView extends StatefulWidget {
  const VideoPortfolioView({super.key});

  @override
  State<VideoPortfolioView> createState() => _VideoPortfolioViewState();
}

class _VideoPortfolioViewState extends State<VideoPortfolioView> {
  final _formKey = GlobalKey<FormState>();
  final _videoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appVm = context.read<ApplicationViewModel>();
    final existing = appVm.repApplication;
    if (existing != null) {
      _videoController.text = existing['video_link'] ?? '';
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video Portfolio",
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
                  Text(
                    "Submit your video introduction link below.",
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _videoController,
                    validator: (value) => value == null || value.isEmpty ? 'Video link is required' : null,
                    decoration: InputDecoration(
                      labelText: "Video URL",
                      prefixIcon: const Icon(Icons.videocam, color: AppColors.grey),
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
                              "Submit Video",
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
    final success = await appVm.saveRepresentativeVideo(userId, _videoController.text.trim());

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video submitted successfully!"), backgroundColor: Colors.green),
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
