class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? planId;
  final String planName;
  final String planType;
  final String trainingType;
  final String? trainerId;
  final String status;
  final DateTime startDate;
  final DateTime expiryDate;
  final double fee;
  final DateTime createdAt;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final String? gender;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.planId,
    required this.planName,
    required this.planType,
    required this.trainingType,
    this.trainerId,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.fee,
    required this.createdAt,
    this.photoUrl,
    this.dateOfBirth,
    this.gender,
  });

  factory Member.fromMap(Map<String, dynamic> map, String id) {
    return Member(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'],
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
      planId: map['planId'],
      planName: map['planName'] ?? map['planType'] ?? '',
      planType: map['planType'] ?? '',
      trainingType: map['trainingType'] ?? '',
      trainerId: map['trainerId'],
      status: map['status'] ?? '',
      startDate: (map['startDate'] as dynamic).toDate(),
      expiryDate: (map['expiryDate'] as dynamic).toDate(),
      fee: (map['fee'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as dynamic).toDate(),
      photoUrl: map['photoUrl'],
      dateOfBirth: map['dateOfBirth'] != null ? (map['dateOfBirth'] as dynamic).toDate() : null,
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'trainingType': trainingType,
      'trainerId': trainerId,
      'status': status,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'fee': fee,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }
}
