import 'package:flutter/material.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/models/conference_model.dart';
import '../../data/models/opportunity_model.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeViewModel({required HomeRepository homeRepository}) : _homeRepository = homeRepository;

  List<ConferenceModel> _conferences = [];
  List<OpportunityModel> _opportunities = [];
  bool _isConferencesLoading = false;
  bool _isOpportunitiesLoading = false;
  String? _conferencesErrorMessage;
  String? _opportunitiesErrorMessage;

  List<ConferenceModel> get conferences => _conferences;
  List<OpportunityModel> get opportunities => _opportunities;
  bool get isConferencesLoading => _isConferencesLoading;
  bool get isOpportunitiesLoading => _isOpportunitiesLoading;
  String? get conferencesErrorMessage => _conferencesErrorMessage;
  String? get opportunitiesErrorMessage => _opportunitiesErrorMessage;

  Future<void> fetchConferences() async {
    _isConferencesLoading = true;
    _conferencesErrorMessage = null;
    notifyListeners();

    try {
      _conferences = await _homeRepository.getConferences();
    } catch (e) {
      _conferencesErrorMessage = 'Failed to load conferences: ${e.toString()}';
      print("Error fetching conferences: $e");
    } finally {
      _isConferencesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOpportunities() async {
    _isOpportunitiesLoading = true;
    _opportunitiesErrorMessage = null;
    notifyListeners();

    try {
      _opportunities = await _homeRepository.getOpportunities();
    } catch (e) {
      _opportunitiesErrorMessage = 'Failed to load opportunities: ${e.toString()}';
       print("Error fetching opportunities: $e");
    } finally {
      _isOpportunitiesLoading = false;
      notifyListeners();
    }
  }
}
