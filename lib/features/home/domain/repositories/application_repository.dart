abstract class ApplicationRepository {
  // Representative
  Future<Map<String, dynamic>?> getRepresentativeApplication(String userId);
  Future<void> saveRepresentativeApplication(Map<String, dynamic> data);
  Future<void> saveRepresentativeVideo(String userId, String videoLink);
  Future<List<String>> getTakenCountries();

  // Moderator
  Future<Map<String, dynamic>?> getModeratorApplication(String userId);
  Future<void> saveModeratorApplication(Map<String, dynamic> data);
  Future<void> saveModeratorResumeVideo(String userId, String? resumeUrl, String videoLink);
}
