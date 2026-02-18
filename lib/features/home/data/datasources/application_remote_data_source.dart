import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ApplicationRemoteDataSource {
  Future<Map<String, dynamic>?> getRepresentativeApplication(String userId);
  Future<void> saveRepresentativeApplication(Map<String, dynamic> data);
  Future<void> saveRepresentativeVideo(String userId, String videoLink);
  Future<List<String>> getTakenCountries();

  Future<Map<String, dynamic>?> getModeratorApplication(String userId);
  Future<void> saveModeratorApplication(Map<String, dynamic> data);
  Future<void> saveModeratorResumeVideo(String userId, String? resumeUrl, String videoLink);
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final SupabaseClient supabaseClient;

  ApplicationRemoteDataSourceImpl({required this.supabaseClient});

  // ── Representative ──

  @override
  Future<Map<String, dynamic>?> getRepresentativeApplication(String userId) async {
    final response = await supabaseClient
        .from('representative_applications')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  @override
  Future<void> saveRepresentativeApplication(Map<String, dynamic> data) async {
    // Check if application already exists for this user
    final existing = await supabaseClient
        .from('representative_applications')
        .select('id')
        .eq('user_id', data['user_id'])
        .maybeSingle();

    if (existing != null) {
      await supabaseClient
          .from('representative_applications')
          .update(data)
          .eq('user_id', data['user_id']);
    } else {
      await supabaseClient
          .from('representative_applications')
          .insert(data);
    }
  }

  @override
  Future<void> saveRepresentativeVideo(String userId, String videoLink) async {
    await supabaseClient
        .from('representative_applications')
        .update({'video_link': videoLink})
        .eq('user_id', userId);
  }

  @override
  Future<List<String>> getTakenCountries() async {
    final response = await supabaseClient
        .from('representative_applications')
        .select('country');
    return (response as List)
        .map((e) => e['country'] as String)
        .where((c) => c.isNotEmpty)
        .toList();
  }

  // ── Moderator ──

  @override
  Future<Map<String, dynamic>?> getModeratorApplication(String userId) async {
    final response = await supabaseClient
        .from('moderator_applications')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  @override
  Future<void> saveModeratorApplication(Map<String, dynamic> data) async {
    final existing = await supabaseClient
        .from('moderator_applications')
        .select('id')
        .eq('user_id', data['user_id'])
        .maybeSingle();

    if (existing != null) {
      await supabaseClient
          .from('moderator_applications')
          .update(data)
          .eq('user_id', data['user_id']);
    } else {
      await supabaseClient
          .from('moderator_applications')
          .insert(data);
    }
  }

  @override
  Future<void> saveModeratorResumeVideo(String userId, String? resumeUrl, String videoLink) async {
    await supabaseClient
        .from('moderator_applications')
        .update({
          'resume_url': resumeUrl,
          'video_link': videoLink,
        })
        .eq('user_id', userId);
  }
}
