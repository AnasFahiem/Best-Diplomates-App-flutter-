import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
// Removed unused import: user_profile.dart
import '../viewmodels/profile_view_model.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

class PassportDetailsView extends StatefulWidget {
  const PassportDetailsView({super.key});

  @override
  State<PassportDetailsView> createState() => _PassportDetailsViewState();
}

class _PassportDetailsViewState extends State<PassportDetailsView> {
  final _passportNumberController = TextEditingController();
  final _expiryDateController = TextEditingController(); 
  
  XFile? _pickedImage; 
  bool _hasChanges = false;
  bool _isUploading = false; // To track image upload status if explicit

  @override
  void initState() {
    super.initState();
    _addChangeListeners();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
       final userProfile = authViewModel.currentUserProfile;
       if (userProfile != null) {
          final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
          if (profileViewModel.userProfile == null) {
             profileViewModel.fetchProfile(userProfile['id']).then((_) {
                _populateControllers();
             });
          } else {
             _populateControllers();
          }
       }
    });
  }

  void _addChangeListeners() {
    void markChanged() {
      if (!_hasChanges) {
        setState(() => _hasChanges = true);
      }
    }
    _passportNumberController.addListener(markChanged);
    _expiryDateController.addListener(markChanged);
  }

  void _populateControllers() {
    final profile = Provider.of<ProfileViewModel>(context, listen: false).userProfile;
    if (profile != null) {
      // Only populate if empty to avoid overwriting user edits during re-builds
      if (_passportNumberController.text.isEmpty) {
         _passportNumberController.text = profile.passportNumber ?? '';
      }
      if (_expiryDateController.text.isEmpty) {
         _expiryDateController.text = profile.passportExpiryDate ?? '';
      }
      
      // Reset changes flag after initial population
      // But we need to do this carefully so listeners don't immediately set it true
      // The listeners trigger on text change. 
      // A simple workaround is to reset _hasChanges to false in the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) setState(() => _hasChanges = false);
      });
    }
  }

  @override
  void dispose() {
    _passportNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
        _isUploading = true;
      });
      
      if (mounted) {
         final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
         final userProfile = authViewModel.currentUserProfile;
         if (userProfile != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uploading image...')),
            );
            
            try {
               await Provider.of<ProfileViewModel>(context, listen: false)
                   .uploadPassportImage(userProfile['id'], pickedFile);
               
               if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passport image uploaded!'), backgroundColor: Colors.green),
                 );
                 setState(() {
                    _hasChanges = true; // Image changed implies need to save (though image itself is auto-saved to profile state, text fields might rely on this flow perception)
                    // Actually, uploadPassportImage updates the profile state in ViewModel.
                    // But for consistency with "Save Changes" button state:
                    _hasChanges = true; 
                    _isUploading = false;
                 });
               }
            } catch (e) {
               if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
                  );
                  setState(() => _isUploading = false);
               }
            }
         }
      }
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Format: MM/yyyy
      final formattedDate = "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      if (_expiryDateController.text != formattedDate) {
         _expiryDateController.text = formattedDate;
         // Listener will set _hasChanges = true
      }
    }
  }

  Future<void> _saveDetails() async {
     final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
     final userProfile = authViewModel.currentUserProfile;
     final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
     
     if (userProfile != null && profileViewModel.userProfile != null) {
        final updatedProfile = profileViewModel.userProfile!.copyWith(
          passportNumber: _passportNumberController.text,
          passportExpiryDate: _expiryDateController.text,
        );
        
        final success = await profileViewModel.updateProfile(updatedProfile);
        
        if (mounted) {
          if (success) {
            setState(() => _hasChanges = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Passport details saved successfully!'), backgroundColor: Colors.green),
            );
            // Optional: Navigator.pop(context); // User might want to stay
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(profileViewModel.errorMessage ?? 'Failed to save'), backgroundColor: Colors.red),
            );
          }
        }
     }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent pop if uploading or changes exist
    final canPop = !_isUploading && !_hasChanges;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (_isUploading) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait for the upload to complete.'), backgroundColor: Colors.orange),
          );
        } else if (_hasChanges) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please save your changes first!'), duration: Duration(seconds: 2), backgroundColor: Colors.orange),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Passport Details",
            style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primaryBlue,
          leading: IconButton(
             icon: const Icon(Icons.arrow_back, color: AppColors.white),
             onPressed: () {
               Navigator.of(context).maybePop();
             },
          ),
        ),
        backgroundColor: AppColors.lightGrey,
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            final profile = viewModel.userProfile;
            final isLoading = viewModel.isLoading;
            
            Widget imageWidget;
            if (_pickedImage != null) {
               if (kIsWeb) {
                  imageWidget = Image.network(_pickedImage!.path, fit: BoxFit.cover);
               } else {
                  imageWidget = Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
               }
            } else if (profile?.passportImageUrl != null) {
               imageWidget = Image.network(
                 profile!.passportImageUrl!, 
                 fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
               );
            } else {
               imageWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 50, color: AppColors.grey),
                    const SizedBox(height: 10),
                    Text(
                      "Upload Passport Image",
                      style: GoogleFonts.poppins(color: AppColors.grey),
                    ),
                  ],
                );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField("Passport Number", _passportNumberController),
                  // Expiry Date with Date Picker
                  GestureDetector(
                    onTap: () => _selectExpiryDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        "Expiry Date (MM/YYYY)", 
                        _expiryDateController, 
                        readOnly: true, // Make it look manageable but read-only for text input
                        suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Passport Image",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: isLoading ? null : _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                         children: [
                            Positioned.fill(child: imageWidget),
                            if (isLoading && _isUploading) // Show loading on image only if uploading image
                               Container(
                                 color: Colors.black26, 
                                 child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                               ),
                         ],
                      ),
                    ),
                  ),
                   const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasChanges ? Colors.orange : AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _hasChanges ? "Save Changes (Unsaved)" : "Save Passport Details",
                              style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          filled: true,
          fillColor: AppColors.white,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
        ),
      ),
    );
  }
}
