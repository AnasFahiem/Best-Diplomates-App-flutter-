import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<UserProfile?> updateAvatarUrl(String userId, String avatarUrl);
  Future<String?> uploadAvatar(String userId, XFile imageFile);
}
