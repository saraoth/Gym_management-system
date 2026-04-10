class Guest {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String visitType;
  final DateTime visitDate;
  final String status; // New, Contacted, Visited, Converted, Lost
  final String source; // Walk-in, Referral, Social Media, Website, etc.
  final String? interestedPlan;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final DateTime? convertedDate;
  final String? convertedToMemberId;

  Guest({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.visitType,
    required this.visitDate,
    required this.status,
    required this.source,
    this.interestedPlan,
    this.followUpDate,
    required this.createdAt,
    this.convertedDate,
    this.convertedToMemberId,
  });

  factory Guest.fromMap(Map<String, dynamic> map, String id) {
    return Guest(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      visitType: map['visitType'] ?? '',
      visitDate: (map['visitDate'] as dynamic).toDate(),
      status: map['status'] ?? 'New',
      source: map['source'] ?? 'Walk-in',
      interestedPlan: map['interestedPlan'],
      followUpDate: map['followUpDate'] != null ? (map['followUpDate'] as dynamic).toDate() : null,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      convertedDate: map['convertedDate'] != null ? (map['convertedDate'] as dynamic).toDate() : null,
      convertedToMemberId: map['convertedToMemberId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'visitType': visitType,
      'visitDate': visitDate,
      'status': status,
      'source': source,
      'interestedPlan': interestedPlan,
      'followUpDate': followUpDate,
      'createdAt': createdAt,
      'convertedDate': convertedDate,
      'convertedToMemberId': convertedToMemberId,
    };
  }
}
