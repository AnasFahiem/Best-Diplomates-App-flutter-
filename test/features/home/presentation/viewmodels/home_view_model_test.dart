import 'package:flutter_test/flutter_test.dart';
import 'package:best_diplomats/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:best_diplomats/features/home/domain/repositories/home_repository.dart';
import 'package:best_diplomats/features/home/data/models/conference_model.dart';
import 'package:best_diplomats/features/home/data/models/opportunity_model.dart';

class MockHomeRepository implements HomeRepository {
  bool shouldThrowError = false;
  
  @override
  Future<List<ConferenceModel>> getConferences() async {
    if (shouldThrowError) throw Exception('Failed to load conferences');
    return [
      ConferenceModel(
        id: '1',
        title: 'Test Conference',
        description: 'Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        location: 'Test Location',
        imageUrl: '',
        status: 'upcoming',
      ),
    ];
  }

  @override
  Future<List<OpportunityModel>> getOpportunities() async {
    if (shouldThrowError) throw Exception('Failed to load opportunities');
    return [
      OpportunityModel(
        id: '1',
        title: 'Test Opportunity',
        description: 'Description',
        icon: 'public',
        isComingSoon: false,
        type: 'country_rep',
      ),
    ];
  }
}

void main() {
  late HomeViewModel viewModel;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    viewModel = HomeViewModel(homeRepository: mockRepository);
  });

  test('Initial state should be empty', () {
    expect(viewModel.conferences, isEmpty);
    expect(viewModel.opportunities, isEmpty);
    expect(viewModel.isConferencesLoading, false);
    expect(viewModel.isOpportunitiesLoading, false);
    expect(viewModel.conferencesErrorMessage, null);
    expect(viewModel.opportunitiesErrorMessage, null);
  });

  test('fetchConferences should update conferences list on success', () async {
    await viewModel.fetchConferences();
    expect(viewModel.conferences.length, 1);
    expect(viewModel.conferences.first.title, 'Test Conference');
    expect(viewModel.isConferencesLoading, false);
    expect(viewModel.conferencesErrorMessage, null);
  });

  test('fetchConferences should set errorMessage on failure', () async {
    mockRepository.shouldThrowError = true;
    await viewModel.fetchConferences();
    expect(viewModel.conferences, isEmpty);
    expect(viewModel.isConferencesLoading, false);
    expect(viewModel.conferencesErrorMessage, contains('Failed to load conferences'));
  });

  test('fetchOpportunities should update opportunities list on success', () async {
    await viewModel.fetchOpportunities();
    expect(viewModel.opportunities.length, 1);
    expect(viewModel.opportunities.first.title, 'Test Opportunity');
    expect(viewModel.isOpportunitiesLoading, false);
    expect(viewModel.opportunitiesErrorMessage, null);
  });
}
