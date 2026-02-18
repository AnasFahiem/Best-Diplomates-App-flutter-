import '../../data/datasources/application_remote_data_source.dart';
import '../../domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>?> getRepresentativeApplication(String userId) =>
      remoteDataSource.getRepresentativeApplication(userId);

  @override
  Future<void> saveRepresentativeApplication(Map<String, dynamic> data) =>
      remoteDataSource.saveRepresentativeApplication(data);

  @override
  Future<void> saveRepresentativeVideo(String userId, String videoLink) =>
      remoteDataSource.saveRepresentativeVideo(userId, videoLink);

  @override
  Future<List<String>> getTakenCountries() =>
      remoteDataSource.getTakenCountries();

  @override
  Future<Map<String, dynamic>?> getModeratorApplication(String userId) =>
      remoteDataSource.getModeratorApplication(userId);

  @override
  Future<void> saveModeratorApplication(Map<String, dynamic> data) =>
      remoteDataSource.saveModeratorApplication(data);

  @override
  Future<void> saveModeratorResumeVideo(String userId, String? resumeUrl, String videoLink) =>
      remoteDataSource.saveModeratorResumeVideo(userId, resumeUrl, videoLink);
}
