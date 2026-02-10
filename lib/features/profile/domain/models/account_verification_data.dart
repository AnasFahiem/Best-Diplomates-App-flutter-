import 'dart:convert';

class AccountVerificationData {
  final bool isPassportVerified;
  final bool isFaceVerified;
  final DateTime? verifiedAt;
  final Map<String, String>? passportData;

  AccountVerificationData({
    required this.isPassportVerified,
    required this.isFaceVerified,
    this.verifiedAt,
    this.passportData,
  });

  factory AccountVerificationData.fromJson(Map<String, dynamic> json) {
    return AccountVerificationData(
      isPassportVerified: json['isPassportVerified'] ?? false,
      isFaceVerified: json['isFaceVerified'] ?? false,
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      passportData: json['passportData'] != null
          ? Map<String, String>.from(json['passportData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPassportVerified': isPassportVerified,
      'isFaceVerified': isFaceVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'passportData': passportData,
    };
  }

  factory AccountVerificationData.fromJsonString(String jsonString) {
    return AccountVerificationData.fromJson(json.decode(jsonString));
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  AccountVerificationData copyWith({
    bool? isPassportVerified,
    bool? isFaceVerified,
    DateTime? verifiedAt,
    Map<String, String>? passportData,
  }) {
    return AccountVerificationData(
      isPassportVerified: isPassportVerified ?? this.isPassportVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      passportData: passportData ?? this.passportData,
    );
  }
}
