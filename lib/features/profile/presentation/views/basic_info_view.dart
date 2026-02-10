import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/user_profile.dart';
import '../viewmodels/profile_view_model.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

class BasicInfoView extends StatefulWidget {
  const BasicInfoView({super.key});

  @override
  State<BasicInfoView> createState() => _BasicInfoViewState();
}

class CountryData {
  final String name;
  final String code;
  final String flag;

  CountryData({required this.name, required this.code, required this.flag});
}

class _BasicInfoViewState extends State<BasicInfoView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // State variables
  String? _selectedGender;
  String? _selectedMaritalStatus;
  
  // ignore: unused_field
  late CountryData _selectedCountry;
  // ignore: unused_field
  late CountryData _selectedEmergencyCountry;
  
  XFile? _imageFile;
  bool _isUploading = false;
  
  // Save Guard State
  bool _hasChanges = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Data Lists
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];
  
  final List<CountryData> _countries = [
    CountryData(name: "USA", code: "+1", flag: "🇺🇸"),
    CountryData(name: "Egypt", code: "+20", flag: "🇪🇬"),
    CountryData(name: "UK", code: "+44", flag: "🇬🇧"),
    CountryData(name: "India", code: "+91", flag: "🇮🇳"),
    CountryData(name: "Pakistan", code: "+92", flag: "🇵🇰"),
    CountryData(name: "UAE", code: "+971", flag: "🇦🇪"),
    CountryData(name: "Canada", code: "+1", flag: "🇨🇦"),
    CountryData(name: "Germany", code: "+49", flag: "🇩🇪"),
    CountryData(name: "France", code: "+33", flag: "🇫🇷"),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0]; // USA Default
    _selectedEmergencyCountry = _countries[0]; // USA Default
    
    // Initialize Shake Animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Add change listeners
    _addChangeListeners();

    // Fetch profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final user = authViewModel.currentUser;
      if (user != null) {
        Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(user.id);
      }
    });
  }

  void _addChangeListeners() {
    void markChanged() {
      if (!_hasChanges) {
        setState(() => _hasChanges = true);
      }
    }

    _firstNameController.addListener(markChanged);
    _lastNameController.addListener(markChanged);
    _addressController.addListener(markChanged);
    _nationalityController.addListener(markChanged);
    _phoneController.addListener(markChanged);
    _emergencyNameController.addListener(markChanged);
    _emergencyPhoneController.addListener(markChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _scrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfile profile) {
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _nationalityController.text = profile.nationality ?? '';
    _phoneController.text = profile.phone ?? '';
    _emergencyNameController.text = profile.emergencyContactName ?? '';
    _emergencyPhoneController.text = profile.emergencyContactNumber ?? '';
    
    if (profile.gender != null && _genders.contains(profile.gender)) {
        _selectedGender = profile.gender;
    }
    
    if (profile.maritalStatus != null && _maritalStatuses.contains(profile.maritalStatus)) {
        _selectedMaritalStatus = profile.maritalStatus;
    }
  }



  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isUploading = true;
      });
      
      // Auto upload if user is logged in
      if (mounted) {
         final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
         final user = authViewModel.currentUser;
         if (user != null) {
            // Show blocking loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PopScope(
                canPop: false,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Consumer<ProfileViewModel>(
                        builder: (context, viewModel, child) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text(
                              viewModel.uploadStatus.isEmpty 
                                  ? "Uploading & Updating Profile..." 
                                  : viewModel.uploadStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            const Text("Please wait, do not close the app.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

            try {
              final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
              
              // 1. Upload Avatar
              await profileViewModel.uploadAvatar(user.id, _imageFile!);
              
              if (mounted) {
                // Close loading dialog
                Navigator.pop(context); 
                
                setState(() {
                  _isUploading = false;
                });

                if (profileViewModel.errorMessage != null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(profileViewModel.errorMessage!), backgroundColor: Colors.red),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile picture updated!'), 
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                // Close loading dialog
                Navigator.pop(context);
                
                setState(() {
                  _isUploading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
                );
              }
            }
         }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
       final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
       final user = authViewModel.currentUser;
       
       if (user != null) {
         final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
         final currentProfile = viewModel.userProfile;

         final profile = UserProfile(
           id: user.id,
           firstName: _firstNameController.text,
           lastName: _lastNameController.text,
           email: _emailController.text,
           gender: _selectedGender,
           maritalStatus: _selectedMaritalStatus,
           nationality: _nationalityController.text,
           phone: _phoneController.text,
           emergencyContactName: _emergencyNameController.text,
           emergencyContactNumber: _emergencyPhoneController.text,
           address: _addressController.text,
           avatarUrl: currentProfile?.avatarUrl, // PRESERVE AVATAR URL!
         );
         
         final success = await Provider.of<ProfileViewModel>(context, listen: false).updateProfile(profile);
         
         if (mounted) {
           if (success) {
             setState(() => _hasChanges = false);
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
             );
           } else {
             final error = Provider.of<ProfileViewModel>(context, listen: false).errorMessage;
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(error ?? 'Failed to update profile'), backgroundColor: Colors.red),
             );
           }
         }
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we can pop
    final canPop = !_isUploading && !_hasChanges;

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_isUploading) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait for the upload to complete.'), backgroundColor: Colors.orange),
          );
        } else if (_hasChanges) {
           // Scroll to bottom
           if (_scrollController.hasClients) {
             _scrollController.animateTo(
               _scrollController.position.maxScrollExtent,
               duration: const Duration(milliseconds: 300),
               curve: Curves.easeOut,
             );
           }
           
           // Shake button
           _shakeController.forward(from: 0.0);
           
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please save your changes first!'), duration: Duration(seconds: 2), backgroundColor: Colors.orange),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Basic Information",
            style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primaryBlue,
          automaticallyImplyLeading: false, // We handle back via leading widget
          leading: IconButton(
             icon: const Icon(Icons.arrow_back, color: AppColors.white),
             onPressed: () {
               // Trigger PopScope logic via maybePop
               Navigator.of(context).maybePop();
             },
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
      backgroundColor: AppColors.lightGrey,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.userProfile == null) {
             return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }
          
          // Populate controllers once when profile loads (and they are empty)
          if (viewModel.userProfile != null && _firstNameController.text.isEmpty) {
             _populateControllers(viewModel.userProfile!);
          }
          
          final profile = viewModel.userProfile;
          final initials = (profile?.firstName?.isNotEmpty == true) 
              ? profile!.firstName![0].toUpperCase() 
              : ((profile?.email?.isNotEmpty == true) ? profile!.email![0].toUpperCase() : 'U');

          ImageProvider? backgroundImage;
          if (_imageFile != null) {
            if (kIsWeb) {
              backgroundImage = NetworkImage(_imageFile!.path);
            } else {
              backgroundImage = FileImage(File(_imageFile!.path));
            }
          } else if (profile?.avatarUrl != null) {
            backgroundImage = NetworkImage(profile!.avatarUrl!);
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: (backgroundImage != null)
                                ? (kIsWeb 
                                   ? Image.network(
                                       (backgroundImage as NetworkImage).url, 
                                       fit: BoxFit.cover,
                                       errorBuilder: (context, error, stackTrace) {
                                         print('IMAGE LOAD ERROR: $error');
                                         return const Center(child: Icon(Icons.broken_image, color: Colors.red));
                                       },
                                     ) 
                                   : Image(
                                      image: backgroundImage, 
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                         return const Center(child: Icon(Icons.broken_image, color: Colors.blue));
                                      },
                                    )
                                  )
                                : CircleAvatar(
                                    backgroundColor: AppColors.primaryBlue,
                                    child: Text(initials, style: const TextStyle(fontSize: 30, color: AppColors.white)),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField("First Name", _firstNameController),
                  _buildTextField("Last Name", _lastNameController),
                  _buildTextField("Email Address", _emailController, readOnly: true),
                  _buildTextField("Address", _addressController),
                  
                  // Gender Dropdown
                  _buildDropdownField(
                    "Gender",
                    _selectedGender,
                    _genders,
                    (val) => setState(() {
                      _selectedGender = val;
                      _hasChanges = true;
                    }),
                  ),
                  
                  // Marital Status Dropdown
                   _buildDropdownField(
                    "Marital Status",
                    _selectedMaritalStatus,
                    _maritalStatuses,
                    (val) => setState(() {
                      _selectedMaritalStatus = val;
                      _hasChanges = true;
                    }),
                  ),
        
                  _buildTextField("Nationality", _nationalityController),
                  
                  // Phone Number with Rich Country Code
                  // Simplified for now, just text field but retaining structure
                  _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
                  
                  _buildTextField("Emergency Contact Name", _emergencyNameController),
                  
                  // Emergency Contact with Rich Country Code
                   _buildTextField("Emergency Contact Number", _emergencyPhoneController, keyboardType: TextInputType.phone),
        
                  const SizedBox(height: 20),
                  
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      // Simple horizontal shake
                      final double offset = 10 *
                          (1 - _shakeController.value) *
                          math.sin(3.14159 * 4 * _shakeController.value);
                          
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasChanges ? Colors.orange : AppColors.primaryBlue, // Highlight if changed
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: viewModel.isLoading 
                            ? const CircularProgressIndicator(color: AppColors.white)
                            : Text(
                                _hasChanges ? "Save Changes (Unsaved)" : "Save Changes",
                                style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
        ),
        validator: (value) {
            if (!readOnly && (value == null || value.isEmpty)) {
                return 'Please enter $label';
            }
            return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
        ),
        dropdownColor: AppColors.white,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.poppins(color: AppColors.primaryBlue),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
