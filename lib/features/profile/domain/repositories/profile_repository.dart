import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../models/account_verification_data.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<UserProfile?> updateAvatarUrl(String userId, String avatarUrl);
  Future<String?> uploadAvatar(String userId, XFile imageFile);
  Future<String?> uploadPassportImage(String userId, XFile imageFile);
  Future<void> saveVerificationData(String userId, AccountVerificationData data);
  Future<AccountVerificationData?> getVerificationData(String userId);
}
