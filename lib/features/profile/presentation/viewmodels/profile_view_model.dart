import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/account_verification_data.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileViewModel({required ProfileRepository profileRepository}) 
      : _profileRepository = profileRepository;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _profileRepository.getProfile(userId);
    } catch (e) {
      _errorMessage = 'Failed to load profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _profileRepository.updateProfile(profile);
      _userProfile = profile; // Update local state
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  String _uploadStatus = '';
  String get uploadStatus => _uploadStatus;

  Future<void> uploadAvatar(String userId, XFile imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _uploadStatus = 'Uploading to server...';
    notifyListeners();

    // Backup current profile for rollback
    final previousProfile = _userProfile;

    try {
      // Upload to storage directly
      _uploadStatus = 'Uploading to storage...';
      notifyListeners();
      
      final imageUrl = await _profileRepository.uploadAvatar(userId, imageFile);
      
      if (imageUrl != null) {
        _uploadStatus = 'Upload complete! Updating profile...';
        notifyListeners(); // Keep loading

        // 1. Upsert URL & Fetch fresh profile
        UserProfile? newProfile;
        try {
           newProfile = await _profileRepository.updateAvatarUrl(userId, imageUrl);
        } catch (e) {
           throw Exception('Failed to save profile picture URL in DB: $e');
        }

        // 2. Update local state
        if (newProfile != null) {
          // FORCE the avatarUrl to be the new one, even if DB returns null (e.g. RLS issue)
          _userProfile = newProfile.copyWith(avatarUrl: imageUrl);
        } else {
           _userProfile = _userProfile?.copyWith(avatarUrl: imageUrl) ?? UserProfile(id: userId, avatarUrl: imageUrl);
        }
          
        notifyListeners();
        
        _uploadStatus = 'Profile picture updated successfully!';
        notifyListeners();
      }
    } catch (e) {
      // Rollback on failure
      _userProfile = previousProfile;
      _uploadStatus = 'Failed: ${e.toString()}';
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> uploadPassportImage(String userId, XFile imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _uploadStatus = 'Uploading passport image...';
    notifyListeners();

    try {
      final imageUrl = await _profileRepository.uploadPassportImage(userId, imageFile);
      
      if (imageUrl != null) {
        // Update local state temporarily so UI shows new image
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(passportImageUrl: imageUrl);
        } else {
           _userProfile = UserProfile(id: userId, passportImageUrl: imageUrl);
        }
        
        // Note: We don't verify against DB here like avatar, we just return success
        // The actual text fields + image URL will be saved when user clicks "Save Passport Details"
        // OR we can save immediately. 
        // For Passport Integration plan: "Implement Save Passport Details logic". 
        // So we just upload and let the user click save to persist the URL to the profile row? 
        // No, `uploadPassportImage` returns a URL. 
        // We probably want to update the profile immediately with the URL? 
        // Or just let the UI hold the URL and save it with text fields?
        // Let's decide: Upload returns URL. UI calls updateProfile with that URL.
        // Actually, looking at `uploadAvatar`, it does both. 
        // For passport, usually form data is saved together.
        // Let's just update local state and let the "Save" button persist it to DB along with text fields.
        
        _uploadStatus = 'Passport image uploaded!';
        notifyListeners();
      }
    } catch (e) {
      _uploadStatus = 'Failed: ${e.toString()}';
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verification methods
  Future<void> saveVerificationData(String userId, AccountVerificationData data) async {
    try {
      await _profileRepository.saveVerificationData(userId, data);
    } catch (e) {
      _errorMessage = 'Failed to save verification data: ${e.toString()}';
      rethrow;
    }
  }

  Future<AccountVerificationData?> getVerificationData(String userId) async {
    try {
      return await _profileRepository.getVerificationData(userId);
    } catch (e) {
      _errorMessage = 'Failed to load verification data: ${e.toString()}';
      return null;
    }
  }
}
