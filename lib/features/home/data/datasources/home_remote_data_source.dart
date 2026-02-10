import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conference_model.dart';
import '../models/opportunity_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ConferenceModel>> getConferences();
  Future<List<OpportunityModel>> getOpportunities();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ConferenceModel>> getConferences() async {
    final response = await supabaseClient
        .from('summits')
        .select()
        .order('start_date', ascending: true);
    
    return (response as List).map((e) => ConferenceModel.fromJson(e)).toList();
  }

  @override
  Future<List<OpportunityModel>> getOpportunities() async {
    final response = await supabaseClient
        .from('opportunities')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => OpportunityModel.fromJson(e)).toList();
  }
}
