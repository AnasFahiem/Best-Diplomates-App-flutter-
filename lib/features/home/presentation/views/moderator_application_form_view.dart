import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ModeratorApplicationFormView extends StatefulWidget {
  const ModeratorApplicationFormView({super.key});

  @override
  State<ModeratorApplicationFormView> createState() => _ModeratorApplicationFormViewState();
}

class _ModeratorApplicationFormViewState extends State<ModeratorApplicationFormView> {
  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Employee/Self Employed'];
  
  bool _attendedBestDiplomats = false;
  bool _attendedRelatedConferences = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Representative", // User requested title
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Work / Education Details"),
              const SizedBox(height: 15),
              _buildWorkEducationSection(),
              
              const SizedBox(height: 30),
              _buildSectionTitle("Social Media Profiles"),
              const SizedBox(height: 15),
              _buildSocialMediaSection(),

              const SizedBox(height: 40),
               SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Application Details Saved!")),
                      );
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Save Details",
                    style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.navyBlue,
      ),
    );
  }

  Widget _buildWorkEducationSection() {
    return Container(
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
          Text("I'm a", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: _inputDecoration(null),
            items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
            onChanged: (val) => setState(() => _selectedRole = val!),
          ),
          const SizedBox(height: 20),
          
          if (_selectedRole == 'Student') ...[
             _buildTextField("Educational Institution", isRequired: true),
             const SizedBox(height: 15),
             _buildTextField("Educational Qualification", isRequired: true),
          ] else ...[
             _buildTextField("Educational Qualification", isRequired: true),
             const SizedBox(height: 15),
             _buildTextField("Job Role", isRequired: true),
             const SizedBox(height: 15),
             _buildTextField("Company Name", isRequired: true),
          ]
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Container(
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
          _buildTextField("LinkedIn Profile Link", prefixIcon: Icons.business),
          const SizedBox(height: 20),
          
          CheckboxListTile(
            value: _attendedBestDiplomats,
            onChanged: (val) => setState(() => _attendedBestDiplomats = val!),
            title: Text("Have you previously attended a Best Diplomats Conference?", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.navyBlue)),
            activeColor: AppColors.navyBlue,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: _attendedRelatedConferences,
            onChanged: (val) => setState(() => _attendedRelatedConferences = val!),
            title: Text("Have you attended any related conferences previously?", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.navyBlue)),
            activeColor: AppColors.navyBlue,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 20),
          Text(
            "What makes you an ideal candidate for the role of conference moderator?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.navyBlue, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            "Please provide a detailed description explaining your leadership skills, experience in public speaking, and ability to manage diplomatic simulations.",
            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextFormField(
            maxLines: 6,
            validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
            decoration: _inputDecoration(null).copyWith(
              hintText: "Enter your answer here (not to exceed 500 words)...",
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {bool isRequired = false, IconData? prefixIcon}) {
    return TextFormField(
      validator: isRequired ? (value) => value == null || value.isEmpty ? '$label is required' : null : null,
      decoration: _inputDecoration(null).copyWith(
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.grey) : null,
        label: Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Text(label, style: const TextStyle(color: AppColors.grey)), 
              if (isRequired) const Text(" *", style: TextStyle(color: Colors.red))
            ]
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.grey),
      filled: true,
      fillColor: AppColors.lightGrey.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.navyBlue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
