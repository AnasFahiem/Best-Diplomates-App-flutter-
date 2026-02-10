class OpportunityModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isComingSoon;
  final String type; // e.g., 'country_rep', 'moderator', 'volunteer'

  OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isComingSoon,
    required this.type,
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'] ?? 'public',
      isComingSoon: json['is_coming_soon'] ?? false,
      type: json['type'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'is_coming_soon': isComingSoon,
      'type': type,
    };
  }
}
