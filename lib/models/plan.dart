class Plan {
  final String id;
  final String name;
  final String duration; // Day, Monthly, 3 Months, 6 Months, etc.
  final double price;
  final String trainingType; // Personal, General, Equipment Only, etc.
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final int? sessions; // For session-based plans (e.g., 12 sessions)
  final bool includesClasses; // Whether classes are included
  final bool includesEquipment; // Whether equipment access is included
  final int ptSessions; // Number of personal training sessions
  final int friendInvitations; // Number of friend invitations
  final double? registrationFee; // Optional registration fee (Gaid)

  Plan({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.trainingType,
    required this.features,
    required this.isActive,
    required this.createdAt,
    this.sessions,
    this.includesClasses = false,
    this.includesEquipment = true,
    this.ptSessions = 0,
    this.friendInvitations = 0,
    this.registrationFee,
  });

  factory Plan.fromMap(Map<String, dynamic> map, String id) {
    return Plan(
      id: id,
      name: map['name'] ?? '',
      duration: map['duration'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      trainingType: map['trainingType'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      sessions: map['sessions'],
      includesClasses: map['includesClasses'] ?? false,
      includesEquipment: map['includesEquipment'] ?? true,
      ptSessions: map['ptSessions'] ?? 0,
      friendInvitations: map['friendInvitations'] ?? 0,
      registrationFee: map['registrationFee']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'price': price,
      'trainingType': trainingType,
      'features': features,
      'isActive': isActive,
      'createdAt': createdAt,
      'sessions': sessions,
      'includesClasses': includesClasses,
      'includesEquipment': includesEquipment,
      'ptSessions': ptSessions,
      'friendInvitations': friendInvitations,
      'registrationFee': registrationFee,
    };
  }
}
