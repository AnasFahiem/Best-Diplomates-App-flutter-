
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _supabaseClient.from('profiles').upsert(profile.toJson());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<UserProfile?> updateAvatarUrl(String userId, String avatarUrl) async {
    print('DEBUG: Attempting to update avatar for userId: $userId with URL: $avatarUrl');
    
    // 1. Try Update first
    try {
      final updateResponse = await _supabaseClient.from('profiles').update({
        'avatar_url': avatarUrl,
      }).eq('id', userId).select();
      
      if (updateResponse.isNotEmpty) {
        return UserProfile.fromJson(updateResponse.first);
      }
    } catch (e) {
      print('DEBUG: Update failed or row missing, trying Insert. Error: $e');
    }

    // 2. If update didn't work, try Insert (Upsert)
    try {
       // We use upsert here as a fallback
       final upsertResponse = await _supabaseClient.from('profiles').upsert({
        'id': userId,
        'avatar_url': avatarUrl,
      }).select().maybeSingle();

       if (upsertResponse != null) {
         return UserProfile.fromJson(upsertResponse);
       }
    } catch (e) {
      throw Exception('Failed to persist avatar URL (Write Failed): $e');
    }

    throw Exception('Failed to update profile: RLS may be blocking writes, or row is locked.');
  }

  @override
  Future<String?> uploadAvatar(String userId, XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.name.split('.').last;
      // NEW: Unique filename every time to bypass all caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/avatar_$timestamp.$fileExt';

      await _supabaseClient.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final imageUrl = _supabaseClient.storage.from('avatars').getPublicUrl(fileName);
      
      // Add a timestamp to bust cache in case the URL is the same but content changed
      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
