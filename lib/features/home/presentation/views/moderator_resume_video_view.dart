import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ModeratorResumeVideoView extends StatefulWidget {
  const ModeratorResumeVideoView({super.key});

  @override
  State<ModeratorResumeVideoView> createState() => _ModeratorResumeVideoViewState();
}

class _ModeratorResumeVideoViewState extends State<ModeratorResumeVideoView> {
  final _formKey = GlobalKey<FormState>();
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resume & Video Intro",
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
                "Upload Resume / CV",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Simulate file picking
                  setState(() {
                    _fileName = "resume_john_doe.pdf";
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.grey.withOpacity(0.5), style: BorderStyle.solid),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 50, color: _fileName != null ? Colors.green : AppColors.gold),
                      const SizedBox(height: 15),
                      Text(
                        _fileName ?? "Tap to Upload PDF/DOCX",
                        style: GoogleFonts.poppins(
                          color: _fileName != null ? AppColors.navyBlue : AppColors.grey,
                          fontWeight: _fileName != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Video Introduction Link",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
              ),
              const SizedBox(height: 5),
              Text(
                "Provide a link to your introduction video (YouTube, Drive, etc.)",
                style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) => value == null || value.isEmpty ? 'Video link is required' : null,
                decoration: InputDecoration(
                  hintText: "https://youtu.be/...",
                  filled: true,
                  fillColor: AppColors.white,
                  prefixIcon: const Icon(Icons.link, color: AppColors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.navyBlue)),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_fileName == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload your resume")));
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Documents Submitted Successfully!")));
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Submit Documents",
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
