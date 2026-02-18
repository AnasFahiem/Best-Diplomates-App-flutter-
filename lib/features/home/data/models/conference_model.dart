class ConferenceModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String imageUrl;
  final String status;

  ConferenceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.imageUrl,
    required this.status,
  });

  bool get isHappeningSoon => status == 'happening_soon';

  factory ConferenceModel.fromJson(Map<String, dynamic> json) {
    String city = json['city']?.toString() ?? 'Unknown Location';
    String extractedTitle = json['title']?.toString() ?? 'Future Diplomats $city';
    
    // Parse dates if start_date is null but 'dates' string exists (e.g. "July 15-20, 2026")
    // For now, simpler fallback
    
    return ConferenceModel(
      id: json['id']?.toString() ?? '',
      title: extractedTitle,
      description: json['description']?.toString() ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now() 
          : DateTime.now(), // TODO: improved date parsing from 'dates' string if needed
      endDate: json['end_date'] != null 
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      location: city,
      imageUrl: json['image_url']?.toString() ?? '',
      status: (json['is_active'] == true) ? 'happening_soon' : 'upcoming', // Mapping is_active to status
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'status': status,
    };
  }
}
