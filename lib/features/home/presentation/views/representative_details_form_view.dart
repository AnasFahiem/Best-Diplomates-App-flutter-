import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class RepresentativeDetailsFormView extends StatefulWidget {
  const RepresentativeDetailsFormView({super.key});

  @override
  State<RepresentativeDetailsFormView> createState() => _RepresentativeDetailsFormViewState();
}

class _RepresentativeDetailsFormViewState extends State<RepresentativeDetailsFormView> {
  String _selectedRole = 'Student'; // Default
  final List<String> _roles = ['Student', 'Employee', 'Business Person'];

  // Form Key
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Representative Details",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
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

              const SizedBox(height: 30),
              _buildSectionTitle("Share Your Vision"),
              const SizedBox(height: 15),
              _buildVisionSection(),

              const SizedBox(height: 40),
               SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Details Saved Successfully!")),
                      );
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
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
        color: AppColors.primaryBlue,
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
          Text("I'm a", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
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
             // For Employee and Business Person
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
        children: [
          _buildTextField("Facebook Profile Link", prefixIcon: Icons.facebook),
          const SizedBox(height: 15),
          _buildTextField("Twitter/X Profile Link", prefixIcon: Icons.link), // Generic link icon for X
          const SizedBox(height: 15),
          _buildTextField("Instagram Profile Link", prefixIcon: Icons.camera_alt),
          const SizedBox(height: 15),
          _buildTextField("LinkedIn Profile Link", prefixIcon: Icons.business),
        ],
      ),
    );
  }

  Widget _buildVisionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: TextFormField(
        maxLines: 5,
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        decoration: _inputDecoration("Share your thoughts...").copyWith(
          hintText: "Tell us about your vision...",
          alignLabelWithHint: true,
        ),
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
        borderSide: const BorderSide(color: AppColors.primaryBlue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
