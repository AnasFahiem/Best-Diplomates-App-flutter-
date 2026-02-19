import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart' as intl_phone;
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/user_profile.dart';
import '../viewmodels/profile_view_model.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';

enum _ExitAction { discard, save, cancel }

class BasicInfoView extends StatefulWidget {
  const BasicInfoView({super.key});

  @override
  State<BasicInfoView> createState() => _BasicInfoViewState();
}

class LeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('0')) {
      return newValue.copyWith(
        text: newValue.text.replaceFirst(RegExp(r'^0+'), ''),
        selection: newValue.selection.copyWith(
          baseOffset: newValue.selection.baseOffset > 0 ? newValue.selection.baseOffset - 1 : 0,
          extentOffset: newValue.selection.extentOffset > 0 ? newValue.selection.extentOffset - 1 : 0,
        ),
      );
    }
    return newValue;
  }
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
  
  // Store full phone numbers with country codes
  String? _completePhoneNumber;
  String? _completeEmergencyPhoneNumber;

  // Initial Country Codes for Phone Fields
  String _phoneIsoCode = 'US';
  String _emergencyPhoneIsoCode = 'US';
  
  XFile? _imageFile;
  bool _isUploading = false;
  
  // Save Guard State
  // Save Guard State
  bool _hasChanges = false;
  bool _hasPopulatedControllers = false;
  // Start as true to prevent initial builds/populations from triggering changes
  bool _isInitializing = true; 
  final ScrollController _scrollController = ScrollController();
  late AnimationController _shakeController;
  // ignore: unused_field
  late Animation<double> _shakeAnimation;

  // Data Lists
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];
  
  // Timers
  Timer? _initializationTimer;

  @override
  void initState() {
    super.initState();
    
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
      final userProfile = authViewModel.currentUserProfile;
      if (userProfile != null) {
        // If profile exists, fetch full details just in case
        Provider.of<ProfileViewModel>(context, listen: false).fetchProfile(userProfile['id']);
      } else {
        // If no profile, we are done initializing (e.g. new form)
        setState(() {
          _isInitializing = false;
        });
      }
    });
  }

  void _addChangeListeners() {
    void markChanged() {
      if (_isInitializing) return;
      if (!_hasChanges) {
        // Safe setState execution
        if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted && !_hasChanges) setState(() => _hasChanges = true);
           });
        } else {
           setState(() => _hasChanges = true);
        }
      }
    }

    _firstNameController.addListener(markChanged);
    _lastNameController.addListener(markChanged);
    _addressController.addListener(markChanged);
    _nationalityController.addListener(markChanged);
    _emergencyNameController.addListener(markChanged);
    // Explicit listeners for phone controllers too, just in case
    // The IntlPhoneField might update the controller text but not trigger onChanged in some cases
    _phoneController.addListener(markChanged);
    _emergencyPhoneController.addListener(markChanged);
  }

  @override
  void dispose() {
    _initializationTimer?.cancel();
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

  Map<String, String>? _parsePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return null;
    
    final sortedCountries = List<intl_phone.Country>.from(intl_phone.countries)
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

    for (var country in sortedCountries) {
      final prefix = '+${country.dialCode}';
      if (phoneNumber.startsWith(prefix)) {
        return {
          'code': country.code,
          'number': phoneNumber.substring(prefix.length),
        };
      }
    }
    return null;
  }

  void _populateControllers(UserProfile profile) {
    // Ensure we are initializing
    _isInitializing = true;
    _initializationTimer?.cancel(); 
    
    debugPrint('BasicInfoView: Populating controllers from profile: ${profile.firstName}');
    
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _emailController.text = profile.email ?? '';
    _addressController.text = profile.address ?? '';
    _nationalityController.text = profile.nationality ?? '';
    
    // Parse Phone
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      final parsed = _parsePhoneNumber(profile.phone);
      if (parsed != null) {
        debugPrint('BasicInfoView: Parsed Phone: ${parsed['code']} ${parsed['number']}');
        _phoneIsoCode = parsed['code']!;
        _phoneController.text = parsed['number']!;
      } else {
        _phoneController.text = profile.phone!;
      }
    }
    
    // Parse Emergency Phone
    if (profile.emergencyContactNumber != null && profile.emergencyContactNumber!.isNotEmpty) {
       final parsed = _parsePhoneNumber(profile.emergencyContactNumber);
       if (parsed != null) {
         debugPrint('BasicInfoView: Parsed Emergency Phone: ${parsed['code']} ${parsed['number']}');
         _emergencyPhoneIsoCode = parsed['code']!;
         _emergencyPhoneController.text = parsed['number']!;
       } else {
         _emergencyPhoneController.text = profile.emergencyContactNumber!;
       }
    }

    _emergencyNameController.text = profile.emergencyContactName ?? '';
    
    _completePhoneNumber = profile.phone;
    _completeEmergencyPhoneNumber = profile.emergencyContactNumber;
    
    if (profile.gender != null && _genders.contains(profile.gender)) {
        _selectedGender = profile.gender;
    }
    
    if (profile.maritalStatus != null && _maritalStatuses.contains(profile.maritalStatus)) {
        _selectedMaritalStatus = profile.maritalStatus;
    }
    
    // Finish initialization
    if (mounted) {
       // Refresh UI to show values
       setState(() {});
       
       // Allow changes after valid frame
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
           _isInitializing = false;
         }
       });
       
       // Failsafe timer in case frame callback takes too long or gets dropped
       _initializationTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted && _isInitializing) {
             debugPrint('BasicInfoView: Failsafe timer disabling initialization mode');
             setState(() => _isInitializing = false);
          }
       });
    } else {
      _isInitializing = false;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isUploading = true;
        _hasChanges = true;
      });
      
      // Auto upload if user is logged in
      if (mounted) {
         final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
         final userProfile = authViewModel.currentUserProfile;
         if (userProfile != null) {
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
              await profileViewModel.uploadAvatar(userProfile['id'], _imageFile!);
              
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

  Future<bool> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
       final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
       final userProfile = authViewModel.currentUserProfile;
       
       if (userProfile != null) {
         final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
         final currentProfile = viewModel.userProfile;

         final profile = UserProfile(
           id: userProfile['id'],
           firstName: _firstNameController.text,
           lastName: _lastNameController.text,
           email: _emailController.text,
           gender: _selectedGender,
           maritalStatus: _selectedMaritalStatus,
           nationality: _nationalityController.text,
           // Use the complete phone numbers captured from IntlPhoneField
           phone: _completePhoneNumber ?? _phoneController.text, 
           emergencyContactName: _emergencyNameController.text,
           emergencyContactNumber: _completeEmergencyPhoneNumber ?? _emergencyPhoneController.text,
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
             return true;
           } else {
             final error = Provider.of<ProfileViewModel>(context, listen: false).errorMessage;
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(error ?? 'Failed to update profile'), backgroundColor: Colors.red),
             );
             return false;
           }
         }
       }
    }
    return false;
  }



  @override
  Widget build(BuildContext context) {
    // Determine if we can pop
    final canPop = !_isUploading && !_hasChanges;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        debugPrint('PopScope: onPopInvokedWithResult called. didPop: $didPop, canPop: $canPop, _hasChanges: $_hasChanges');
        if (didPop) return;

        if (_isUploading) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait for the upload to complete.'), backgroundColor: Colors.orange),
          );
          return;
        } 
        
        if (_hasChanges) {
           debugPrint('PopScope: Showing Unsaved Changes Dialog');
           // Show confirmation dialog
           final action = await showDialog<_ExitAction>(
             context: context,
             builder: (dialogContext) => AlertDialog(
               title: Text('Unsaved Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
               content: Text('You have unsaved changes. Are you sure you want to discard them?', style: GoogleFonts.inter()),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.of(dialogContext).pop(_ExitAction.discard);
                   },
                   child: Text('Go without saving', style: GoogleFonts.inter(color: Colors.red)),
                 ),
                 ElevatedButton(
                   onPressed: () {
                     Navigator.of(dialogContext).pop(_ExitAction.save);
                   },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                   child: Text('Save Changes', style: GoogleFonts.inter(color: Colors.white)),
                 ),
               ],
             ),
           );

           if (!mounted) return;

           switch (action) {
             case _ExitAction.discard:
               setState(() => _hasChanges = false);
               // Allow the pop to happen now
               Navigator.of(context).pop();
               break;
             case _ExitAction.save:
               final success = await _saveProfile();
               if (success && mounted) {
                 Navigator.of(context).pop();
               }
               break;
             case _ExitAction.cancel:
             case null:
               // Do nothing, stay on screen
               break;
           }
        } else {
          // No changes, just pop
          Navigator.of(context).pop();
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
          

          // Populate controllers once when profile loads
          if (viewModel.userProfile != null && !_hasPopulatedControllers) {
             debugPrint('BasicInfoView: Profile loaded, scheduling _populateControllers');
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted && !_hasPopulatedControllers) {
                 _hasPopulatedControllers = true;
                 _populateControllers(viewModel.userProfile!);
               }
             });
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
            child: Form( // Added onWillPop logging in previous step, but let's reinforce PopScope
              key: _formKey,
              onWillPop: () async {
                debugPrint('onWillPop called. _hasChanges: $_hasChanges');
                return true;
              },
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
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
                                           // print('IMAGE LOAD ERROR: $error'); 
                                           // ignoring print usage for linter
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
                  _buildTextField("Email Address", _emailController, readOnly: true, keyboardType: TextInputType.emailAddress),
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
        
                  // Nationality - Country Picker
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      controller: _nationalityController,
                      readOnly: true,
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          exclude: ['IR', 'IL', 'ET'],
                          onSelect: (Country country) {
                            setState(() {
                              _nationalityController.text = country.name;
                              _hasChanges = true;
                            });
                          },
                          showPhoneCode: false,
                          countryListTheme: CountryListThemeData(
                            bottomSheetHeight: 600,
                            borderRadius: BorderRadius.circular(20),
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Nationality",
                        labelStyle: const TextStyle(color: AppColors.grey),
                        filled: true,
                        fillColor: AppColors.white,
                        suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
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
                         if (value == null || value.isEmpty) {
                             return 'Please select your nationality';
                         }
                         return null;
                      },
                    ),
                  ),
                  
                  // Phone Number - IntlPhoneField
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: IntlPhoneField(
                      // Force rebuild when phone code changes to update initialCountryCode correctly
                      key: ValueKey('phone_$_phoneIsoCode'),
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
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
                        counterText: "", // Hide character counter
                      ),
                      initialCountryCode: _phoneIsoCode,
                      // We can omit initialValue if we use controller, but keeping it consistent with logic
                      initialValue: _phoneController.text,
                      inputFormatters: [
                        LeadingZeroFormatter(),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (phone) {
                        if (_isInitializing) return;
                        _completePhoneNumber = phone.completeNumber;
                        if (!_hasChanges) {
                           // Safe setState execution
                           if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_hasChanges) setState(() => _hasChanges = true);
                              });
                           } else {
                              setState(() => _hasChanges = true);
                           }
                        }
                      },
                      onCountryChanged: (country) {
                         // Country change triggers update
                         if (_isInitializing) return;
                         if (!_hasChanges) {
                           if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_hasChanges) setState(() => _hasChanges = true);
                              });
                           } else {
                              setState(() => _hasChanges = true);
                           }
                         }
                      },
                    ),
                  ),
                  
                  _buildTextField("Emergency Contact Name", _emergencyNameController),
                  
                  // Emergency Phone - IntlPhoneField
                  Padding(
                     padding: const EdgeInsets.only(bottom: 15),
                     child: IntlPhoneField(
                       key: ValueKey('emergency_phone_$_emergencyPhoneIsoCode'),
                       controller: _emergencyPhoneController,
                       decoration: InputDecoration(
                         labelText: 'Emergency Contact Number',
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
                         counterText: "",
                       ),
                       initialCountryCode: _emergencyPhoneIsoCode, 
                       initialValue: _emergencyPhoneController.text,
                       inputFormatters: [
                        LeadingZeroFormatter(),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                       onChanged: (phone) {
                         if (_isInitializing) return;
                         _completeEmergencyPhoneNumber = phone.completeNumber;
                         if (!_hasChanges) {
                           if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_hasChanges) setState(() => _hasChanges = true);
                              });
                           } else {
                              setState(() => _hasChanges = true);
                           }
                         }
                       },
                       onCountryChanged: (country) {
                          if (_isInitializing) return;
                          if (!_hasChanges) {
                           if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_hasChanges) setState(() => _hasChanges = true);
                              });
                           } else {
                              setState(() => _hasChanges = true);
                           }
                         }
                       },
                     ),
                   ),
        
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
