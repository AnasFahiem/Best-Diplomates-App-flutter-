import 'package:flutter/material.dart';
import '../../domain/repositories/application_repository.dart';

class ApplicationViewModel extends ChangeNotifier {
  final ApplicationRepository _repository;

  ApplicationViewModel({required ApplicationRepository repository})
      : _repository = repository;

  // ── State ──
  Map<String, dynamic>? _repApplication;
  Map<String, dynamic>? _modApplication;
  List<String> _takenCountries = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──
  Map<String, dynamic>? get repApplication => _repApplication;
  Map<String, dynamic>? get modApplication => _modApplication;
  List<String> get takenCountries => _takenCountries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Representative step completion
  bool get isRepStep1Completed =>
      _repApplication != null &&
      (_repApplication!['country'] ?? '').toString().isNotEmpty;

  bool get isRepStep2Completed =>
      _repApplication != null &&
      (_repApplication!['video_link'] ?? '').toString().isNotEmpty;

  // Moderator step completion
  bool get isModStep1Completed =>
      _modApplication != null &&
      (_modApplication!['candidate_statement'] ?? '').toString().isNotEmpty;

  bool get isModStep2Completed =>
      _modApplication != null &&
      (_modApplication!['video_link'] ?? '').toString().isNotEmpty;

  // ── Representative Methods ──

  Future<void> loadRepresentativeApplication(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _repApplication = await _repository.getRepresentativeApplication(userId);
      _takenCountries = await _repository.getTakenCountries();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRepresentativeApplication(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveRepresentativeApplication(data);
      _repApplication = data;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveRepresentativeVideo(String userId, String videoLink) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveRepresentativeVideo(userId, videoLink);
      _repApplication?['video_link'] = videoLink;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTakenCountries() async {
    try {
      _takenCountries = await _repository.getTakenCountries();
      notifyListeners();
    } catch (e) {
      // Silently fail — countries list not critical for load
    }
  }

  // ── Moderator Methods ──

  Future<void> loadModeratorApplication(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _modApplication = await _repository.getModeratorApplication(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveModeratorApplication(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveModeratorApplication(data);
      _modApplication = data;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveModeratorResumeVideo(String userId, String? resumeUrl, String videoLink) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.saveModeratorResumeVideo(userId, resumeUrl, videoLink);
      _modApplication?['resume_url'] = resumeUrl;
      _modApplication?['video_link'] = videoLink;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
