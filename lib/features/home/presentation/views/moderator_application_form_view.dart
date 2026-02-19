import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/application_view_model.dart';

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
  final _institutionController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _jobRoleController = TextEditingController();
  final _companyController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _candidateStatementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final userId = context.read<AuthViewModel>().currentUserProfile?['id']?.toString();
    if (userId == null) return;

    final appVm = context.read<ApplicationViewModel>();
    appVm.loadModeratorApplication(userId).then((_) {
      final app = appVm.modApplication;
      if (app != null && mounted) {
        setState(() {
          _selectedRole = app['role_type'] ?? 'Student';
          _institutionController.text = app['institution'] ?? '';
          _qualificationController.text = app['qualification'] ?? '';
          _jobRoleController.text = app['job_role'] ?? '';
          _companyController.text = app['company_name'] ?? '';
          _linkedinController.text = app['linkedin_link'] ?? '';
          _attendedBestDiplomats = app['attended_future_diplomats'] ?? false;
          _attendedRelatedConferences = app['attended_related_conferences'] ?? false;
          _candidateStatementController.text = app['candidate_statement'] ?? '';
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
    _linkedinController.dispose();
    _candidateStatementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Moderator Application",
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
                  _buildSectionTitle("Work / Education Details"),
                  const SizedBox(height: 15),
                  _buildWorkEducationSection(),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Social Media & Experience"),
                  const SizedBox(height: 15),
                  _buildSocialMediaSection(),

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
                              "Save Application",
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
      'role_type': _selectedRole,
      'institution': _institutionController.text,
      'qualification': _qualificationController.text,
      'job_role': _jobRoleController.text,
      'company_name': _companyController.text,
      'linkedin_link': _linkedinController.text,
      'attended_future_diplomats': _attendedBestDiplomats,
      'attended_related_conferences': _attendedRelatedConferences,
      'candidate_statement': _candidateStatementController.text,
    };

    final appVm = context.read<ApplicationViewModel>();
    final success = await appVm.saveModeratorApplication(data);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application Saved Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appVm.errorMessage ?? "Failed to save application"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue));
  }

  Widget _buildWorkEducationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("I'm a", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("LinkedIn Profile Link", controller: _linkedinController, prefixIcon: Icons.business),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: _attendedBestDiplomats,
            onChanged: (val) => setState(() => _attendedBestDiplomats = val!),
            title: Text(
              "Have you previously attended a Future Diplomats Conference?",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primaryBlue),
            ),
            activeColor: AppColors.primaryBlue,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: _attendedRelatedConferences,
            onChanged: (val) => setState(() => _attendedRelatedConferences = val!),
            title: Text(
              "Have you attended any related conferences previously?",
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primaryBlue),
            ),
            activeColor: AppColors.primaryBlue,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 20),
          Text(
            "What makes you an ideal candidate for the role of conference moderator?",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            "Please provide a detailed description explaining your leadership skills, experience in public speaking, and ability to manage diplomatic simulations.",
            style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _candidateStatementController,
            maxLines: 6,
            validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
            decoration: _inputDecoration(null).copyWith(
              hintText: "Enter your response here...",
              alignLabelWithHint: true,
            ),
          ),
        ],
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
          ],
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
