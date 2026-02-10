import '../../data/models/conference_model.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ConferenceModel>> getConferences() async {
    return await remoteDataSource.getConferences();
  }

  @override
  Future<List<OpportunityModel>> getOpportunities() async {
    return await remoteDataSource.getOpportunities();
  }
}
