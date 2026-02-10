class UserProfile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final String? maritalStatus;
  final String? nationality;
  final String? phone;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? address;
  final String? avatarUrl;
  final String? passportNumber;
  final String? passportExpiryDate;
  final String? passportImageUrl;
  final bool? isPassportVerified;
  final bool? isFaceVerified;
  final String? verificationData;

  UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.maritalStatus,
    this.nationality,
    this.phone,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.address,
    this.avatarUrl,
    this.passportNumber,
    this.passportExpiryDate,
    this.passportImageUrl,
    this.isPassportVerified,
    this.isFaceVerified,
    this.verificationData,
  });

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    String? maritalStatus,
    String? nationality,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? address,
    String? avatarUrl,
    String? passportNumber,
    String? passportExpiryDate,
    String? passportImageUrl,
    bool? isPassportVerified,
    bool? isFaceVerified,
    String? verificationData,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nationality: nationality ?? this.nationality,
      phone: phone ?? this.phone,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber: emergencyContactNumber ?? this.emergencyContactNumber,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiryDate: passportExpiryDate ?? this.passportExpiryDate,
      passportImageUrl: passportImageUrl ?? this.passportImageUrl,
      isPassportVerified: isPassportVerified ?? this.isPassportVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      verificationData: verificationData ?? this.verificationData,
    );
  }

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      gender: json['gender'],
      maritalStatus: json['marital_status'],
      nationality: json['nationality'],
      phone: json['phone'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactNumber: json['emergency_contact_number'],
      address: json['address'],
      avatarUrl: json['avatar_url'],
      passportNumber: json['passport_number'],
      passportExpiryDate: json['passport_expiry_date'],
      passportImageUrl: json['passport_image_url'],
      isPassportVerified: json['is_passport_verified'],
      isFaceVerified: json['is_face_verified'],
      verificationData: json['verification_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'gender': gender,
      'marital_status': maritalStatus,
      'nationality': nationality,
      'phone': phone,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
      'address': address,
      'avatar_url': avatarUrl,
      'passport_number': passportNumber,
      'passport_expiry_date': passportExpiryDate,
      'passport_image_url': passportImageUrl,
      'is_passport_verified': isPassportVerified,
      'is_face_verified': isFaceVerified,
      'verification_data': verificationData,
    };
  }
}
