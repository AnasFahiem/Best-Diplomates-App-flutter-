import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/logic/liveness_detector.dart';
import '../../domain/logic/passport_scanner.dart';
import '../../domain/logic/verification_state.dart';
import '../../domain/models/account_verification_data.dart';
import '../../presentation/viewmodels/profile_view_model.dart';

class AccountVerificationView extends StatefulWidget {
  const AccountVerificationView({super.key});

  @override
  State<AccountVerificationView> createState() => _AccountVerificationViewState();
}

class _AccountVerificationViewState extends State<AccountVerificationView> {
  // Logic Controllers
  final PassportScanner _passportScanner = PassportScanner();
  final LivenessDetector _livenessDetector = LivenessDetector();
  final ImagePicker _picker = ImagePicker();

  // State
  VerificationState _state = InstructionState("Start Verification");
  bool _isPassportStepCompleted = false;
  Map<String, String>? _scannedPassportData;
  AccountVerificationData? _existingVerification;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingVerification();
  }

  Future<void> _loadExistingVerification() async {
    try {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final verificationData = await profileViewModel.getVerificationData(userId);
      
      setState(() {
        _existingVerification = verificationData;
        _isLoading = false;
        
        if (verificationData != null) {
          _isPassportStepCompleted = verificationData.isPassportVerified;
          _scannedPassportData = verificationData.passportData;
        }
      });
    } catch (e) {
      print('Error loading verification data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passportScanner.dispose();
    _livenessDetector.dispose();
    super.dispose();
  }

  // Native camera capture for passport
  Future<void> _capturePassportPhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );
      
      if (pickedFile == null) {
        setState(() => _state = InstructionState("Scan cancelled"));
        return;
      }

      // Show preview dialog
      final shouldProcess = await _showImagePreview(pickedFile.path, isPassport: true);
      
      if (!shouldProcess) {
        // User chose to retake
        return _capturePassportPhoto();
      }

      setState(() => _state = ProcessingState("Analyzing passport..."));

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final result = await _passportScanner.processImage(inputImage);

      if (result != null) {
        setState(() => _state = SuccessState(result));
      } else {
        setState(() => _state = FailureState("Could not read passport. Please ensure the MRZ (bottom lines) is clearly visible and try again."));
      }
    } catch (e) {
      setState(() => _state = FailureState("Error: $e"));
    }
  }

  // Native camera capture for face
  Future<void> _captureFacePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100,
      );
      
      if (pickedFile == null) {
        setState(() => _state = ScanningState("Take a clear selfie"));
        return;
      }

      // Show preview dialog
      final shouldProcess = await _showImagePreview(pickedFile.path, isPassport: false);
      
      if (!shouldProcess) {
        // User chose to retake
        return _captureFacePhoto();
      }

      setState(() => _state = ProcessingState("Verifying face..."));

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final result = await _livenessDetector.processImage(inputImage, LivenessGesture.none);

      if (result) {
        // Save verification data to database
        await _saveVerificationData();
        setState(() => _state = SuccessState("Identity Verified"));
      } else {
        setState(() => _state = FailureState("No face detected. Please ensure your face is clearly visible and try again"));
      }
    } catch (e) {
      setState(() => _state = FailureState("Error: $e"));
    }
  }

  Future<void> _saveVerificationData() async {
    try {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      if (userId == null || _scannedPassportData == null) {
        print('Cannot save verification: missing userId or passport data');
        return;
      }

      final verificationData = AccountVerificationData(
        isPassportVerified: true,
        isFaceVerified: true,
        verifiedAt: DateTime.now(),
        passportData: _scannedPassportData,
      );

      await profileViewModel.saveVerificationData(userId, verificationData);
      print('✅ Verification data saved successfully');
    } catch (e) {
      print('❌ Error saving verification data: $e');
    }
  }

  // Show image preview with option to retake or process
  Future<bool> _showImagePreview(String imagePath, {required bool isPassport}) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isPassport ? "Review Passport Photo" : "Review Selfie",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (isPassport)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Make sure the MRZ lines (bottom 2 lines) are clear",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retake"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.check),
                      label: const Text("Use This"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Verification",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 0. Loading State
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 1. Already Verified State
    if (_existingVerification != null && 
        _existingVerification!.isPassportVerified && 
        _existingVerification!.isFaceVerified &&
        _state is! SuccessState && _state is! ProcessingState && _state is! ScanningState) {
      return Center(
        child: Padding(
          padding: ResponsiveUtils.padding(context, mobile: 20, tablet: 28, desktop: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              Text(
                "Account Verified!",
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 10),
              Text(
                "Your account has been successfully verified",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              if (_existingVerification!.passportData != null) ...[
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Verification Details", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildDetailRow("Name", "${_existingVerification!.passportData!['givenNames']} ${_existingVerification!.passportData!['surname']}"),
                        _buildDetailRow("Nationality", _existingVerification!.passportData!['nationality'] ?? ""),
                        _buildDetailRow("Document No", _existingVerification!.passportData!['documentNumber'] ?? ""),
                        if (_existingVerification!.verifiedAt != null)
                          _buildDetailRow("Verified On", _existingVerification!.verifiedAt!.toString().split('.')[0]),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Success View (Passport Scanned)
    if (_state is SuccessState) {
       final data = (_state as SuccessState).data;
       
       // Final verification complete
       if (data is String && data == "Identity Verified") {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text("Verification Complete!", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Continue"),
                ),
              ],
            ),
          );
       }

       // Passport Success - Show Review
       final passportData = data as Map<String, String>;
       return Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("Passport Scanned", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
             const SizedBox(height: 10),
             Text("Please verify the details below:", style: GoogleFonts.poppins(color: Colors.grey)),
             const SizedBox(height: 20),
             Card(
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      _buildDetailRow("Name", "${passportData['givenNames']} ${passportData['surname']}"),
                      _buildDetailRow("Nationality", passportData['nationality'] ?? ""),
                      _buildDetailRow("Document No", passportData['documentNumber'] ?? ""),
                      _buildDetailRow("Date of Birth", passportData['birthDate'] ?? ""),
                      _buildDetailRow("Expiry Date", passportData['expiryDate'] ?? ""),
                      if (passportData.containsKey('sex'))
                        _buildDetailRow("Sex", passportData['sex'] ?? ""),
                   ],
                 ),
               ),
             ),
             const Spacer(),
             Row(
               children: [
                 Expanded(
                   child: OutlinedButton(
                     onPressed: () {
                       setState(() {
                         _state = InstructionState("Ready to verify your identity");
                         _isPassportStepCompleted = false;
                       });
                     },
                     child: const Text("Retake"),
                   ),
                 ),
                 const SizedBox(width: 10),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () {
                       // Save passport data before moving to next step
                       if (_state is SuccessState) {
                         final data = (_state as SuccessState).data;
                         if (data is Map<String, String>) {
                           _scannedPassportData = data;
                         }
                       }

                       setState(() {
                         _isPassportStepCompleted = true;
                         _state = InstructionState("Now let's verify it's really you");
                       });
                     },
                     child: const Text("Confirm"),
                   ),
                 ),
               ],
             ),
           ],
         ),
       );
    }

    // 2. Processing State
    if (_state is ProcessingState) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const CircularProgressIndicator(),
             const SizedBox(height: 20),
             Text((_state as ProcessingState).message, style: GoogleFonts.poppins()),
           ],
         ),
       );
    }

    // 3. Scanning View - Native camera button
    if (_state is ScanningState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPassportStepCompleted ? Icons.face : Icons.document_scanner,
              size: 100,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                (_state as ScanningState).message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isPassportStepCompleted ? _captureFacePhoto : _capturePassportPhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(_isPassportStepCompleted ? "Take Selfie" : "Scan Passport"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
    }

    // 4. Failure State
    if (_state is FailureState) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.error, color: Colors.red, size: 80),
             const SizedBox(height: 20),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 40),
               child: Text(
                 (_state as FailureState).message,
                 textAlign: TextAlign.center,
                 style: GoogleFonts.poppins(fontSize: 16),
               ),
             ),
             const SizedBox(height: 40),
             ElevatedButton(
               onPressed: _isPassportStepCompleted ? _captureFacePhoto : _capturePassportPhoto,
               child: const Text("Try Again"),
             ),
           ],
         ),
       );
    }

    // 5. Initial Instruction View
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, size: 80, color: AppColors.primaryBlue),
          const SizedBox(height: 20),
          Text("Account Verification", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            "Complete these steps to verify your account",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.grey),
          ),
          const SizedBox(height: 40),
          _buildVerificationStep(
            icon: Icons.description,
            title: "Scan Passport",
            description: "Take a clear photo of your passport's information page",
            isCompleted: _isPassportStepCompleted,
            isLoading: false,
            isLocked: false,
            onTap: () {
              setState(() => _state = ScanningState("Position your passport and tap to scan"));
            },
          ),
          const SizedBox(height: 15),
          _buildVerificationStep(
            icon: Icons.face,
            title: "Face Verification",
            description: "Take a selfie to verify your identity",
            isCompleted: false,
            isLoading: false,
            isLocked: !_isPassportStepCompleted,
            onTap: _isPassportStepCompleted
                ? () {
                    setState(() => _state = ScanningState("Take a clear selfie"));
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildVerificationStep({
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isLoading,
    required bool isLocked,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: ResponsiveUtils.padding(context, mobile: 16, tablet: 20, desktop: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted ? Colors.green : (isLocked ? Colors.grey.shade300 : AppColors.primaryBlue)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isCompleted ? Colors.green : (isLocked ? Colors.grey : AppColors.primaryBlue)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: isCompleted ? Colors.green : (isLocked ? Colors.grey : AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(description, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (isLocked)
              const Icon(Icons.lock, size: 20, color: AppColors.grey)
            else
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.lightGrey),
          ],
        ),
      ),
    );
  }
}
