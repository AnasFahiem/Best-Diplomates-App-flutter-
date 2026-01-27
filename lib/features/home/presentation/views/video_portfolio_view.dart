import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class VideoPortfolioView extends StatefulWidget {
  const VideoPortfolioView({super.key});

  @override
  State<VideoPortfolioView> createState() => _VideoPortfolioViewState();
}

class _VideoPortfolioViewState extends State<VideoPortfolioView> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video Portfolio",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Video Link",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
              ),
              const SizedBox(height: 10),
              Text(
                "Please provide a link to your video portfolio (e.g., YouTube, Google Drive, Vimeo). Make sure the link is accessible.",
                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _linkController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Video link is required';
                  }
                  // Basic URL validation
                  if (!Uri.parse(value).isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Video Link",
                  hintText: "https://...",
                  prefixIcon: const Icon(Icons.link, color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.navyBlue),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Video Portfolio Saved!")),
                      );
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Save & Continue",
                    style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
