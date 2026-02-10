import 'package:best_diplomats/features/home/data/models/conference_model.dart';
import 'package:best_diplomats/features/home/data/models/opportunity_model.dart';

abstract class HomeRepository {
  Future<List<ConferenceModel>> getConferences();
  Future<List<OpportunityModel>> getOpportunities();
}
