import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/countries.dart' as intl_phone;
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/application_view_model.dart';

class RepresentativeDetailsFormView extends StatefulWidget {
  const RepresentativeDetailsFormView({super.key});

  @override
  State<RepresentativeDetailsFormView> createState() => _RepresentativeDetailsFormViewState();
}

class _RepresentativeDetailsFormViewState extends State<RepresentativeDetailsFormView> {
  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Employee', 'Business Person'];

  String? _selectedCountry;

  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _jobRoleController = TextEditingController();
  final _companyController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _visionController = TextEditingController();

  // Countries to exclude
  static const _excludedCountryCodes = {'IR', 'ET', 'IL'};

  List<String> _availableCountries = [];
  List<String> _takenCountries = [];

  @override
  void initState() {
    super.initState();
    _buildCountryList();
    _loadExistingData();
  }

  void _buildCountryList() {
    _availableCountries = intl_phone.countries
        .where((c) => !_excludedCountryCodes.contains(c.code))
        .map((c) => c.name)
        .toSet()
        .toList()
      ..sort();
  }

  void _loadExistingData() {
    final userId = context.read<AuthViewModel>().currentUserProfile?['id']?.toString();
    if (userId == null) return;

    final appVm = context.read<ApplicationViewModel>();
    appVm.loadRepresentativeApplication(userId).then((_) {
      final app = appVm.repApplication;
      if (app != null && mounted) {
        setState(() {
          _selectedCountry = app['country'];
          _selectedRole = app['role_type'] ?? 'Student';
          _institutionController.text = app['institution'] ?? '';
          _qualificationController.text = app['qualification'] ?? '';
          _jobRoleController.text = app['job_role'] ?? '';
          _companyController.text = app['company_name'] ?? '';
          _facebookController.text = app['facebook_link'] ?? '';
          _twitterController.text = app['twitter_link'] ?? '';
          _instagramController.text = app['instagram_link'] ?? '';
          _linkedinController.text = app['linkedin_link'] ?? '';
          _visionController.text = app['vision_statement'] ?? '';
        });
      }
      if (mounted) {
        setState(() {
          _takenCountries = appVm.takenCountries;
        });
      }
    });
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _qualificationController.dispose();
    _jobRoleController.dispose();
    _companyController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _visionController.dispose();
    super.dispose();
  }

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
      body: Consumer<ApplicationViewModel>(
        builder: (context, appVm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Selection
                  _buildSectionTitle("Select Your Country"),
                  const SizedBox(height: 15),
                  _buildCountrySection(),

                  const SizedBox(height: 30),
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
                      onPressed: appVm.isLoading ? null : _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: appVm.isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : Text(
                              "Save Details",
                              style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = context.read<AuthViewModel>().currentUserProfile?['id']?.toString();
    if (userId == null) return;

    final data = {
      'user_id': userId,
      'country': _selectedCountry ?? '',
      'role_type': _selectedRole,
      'institution': _institutionController.text,
      'qualification': _qualificationController.text,
      'job_role': _jobRoleController.text,
      'company_name': _companyController.text,
      'facebook_link': _facebookController.text,
      'twitter_link': _twitterController.text,
      'instagram_link': _instagramController.text,
      'linkedin_link': _linkedinController.text,
      'vision_statement': _visionController.text,
    };

    final appVm = context.read<ApplicationViewModel>();
    final success = await appVm.saveRepresentativeApplication(data);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Details Saved Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appVm.errorMessage ?? "Failed to save details"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
    );
  }

  Widget _buildCountrySection() {
    final currentUserId = context.read<AuthViewModel>().currentUserProfile?['id']?.toString();
    final ownCountry = context.read<ApplicationViewModel>().repApplication?['country']?.toString();

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
          Text("Country *", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
          const SizedBox(height: 5),
          Text(
            "Each country can only have one representative.",
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            isExpanded: true,
            decoration: _inputDecoration(null),
            hint: const Text("Select a country"),
            validator: (val) => val == null || val.isEmpty ? 'Country is required' : null,
            items: _availableCountries.map((country) {
              final isTaken = _takenCountries.contains(country) && country != ownCountry;
              return DropdownMenuItem<String>(
                value: country,
                enabled: !isTaken,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        country,
                        style: TextStyle(
                          color: isTaken ? AppColors.grey : Colors.black,
                        ),
                      ),
                    ),
                    if (isTaken)
                      Text(" (Taken)", style: GoogleFonts.poppins(fontSize: 11, color: Colors.red)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedCountry = val),
          ),
        ],
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
            _buildTextField("Educational Institution", controller: _institutionController, isRequired: true),
            const SizedBox(height: 15),
            _buildTextField("Educational Qualification", controller: _qualificationController, isRequired: true),
          ] else ...[
            _buildTextField("Educational Qualification", controller: _qualificationController, isRequired: true),
            const SizedBox(height: 15),
            _buildTextField("Job Role", controller: _jobRoleController, isRequired: true),
            const SizedBox(height: 15),
            _buildTextField("Company Name", controller: _companyController, isRequired: true),
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
          _buildTextField("Facebook Profile Link", controller: _facebookController, prefixIcon: Icons.facebook),
          const SizedBox(height: 15),
          _buildTextField("Twitter/X Profile Link", controller: _twitterController, prefixIcon: Icons.link),
          const SizedBox(height: 15),
          _buildTextField("Instagram Profile Link", controller: _instagramController, prefixIcon: Icons.camera_alt),
          const SizedBox(height: 15),
          _buildTextField("LinkedIn Profile Link", controller: _linkedinController, prefixIcon: Icons.business),
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
        controller: _visionController,
        maxLines: 5,
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        decoration: _inputDecoration("Share your thoughts...").copyWith(
          hintText: "Tell us about your vision...",
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {required TextEditingController controller, bool isRequired = false, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
