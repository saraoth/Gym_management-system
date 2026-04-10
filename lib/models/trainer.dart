class Trainer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String specialization;
  final int membersCount;
  final int classesCount;
  final String status;
  final DateTime createdAt;
  final double baseSalary;
  final double commissionRate; // Percentage per PT session
  final DateTime hireDate;
  final String? photoUrl;
  final List<String> certifications;

  Trainer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.specialization,
    required this.membersCount,
    required this.classesCount,
    required this.status,
    required this.createdAt,
    required this.baseSalary,
    required this.commissionRate,
    required this.hireDate,
    this.photoUrl,
    this.certifications = const [],
  });

  factory Trainer.fromMap(Map<String, dynamic> map, String id) {
    return Trainer(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      specialization: map['specialization'] ?? '',
      membersCount: map['membersCount'] ?? 0,
      classesCount: map['classesCount'] ?? 0,
      status: map['status'] ?? 'Active',
      createdAt: (map['createdAt'] as dynamic).toDate(),
      baseSalary: (map['baseSalary'] ?? 0).toDouble(),
      commissionRate: (map['commissionRate'] ?? 0).toDouble(),
      hireDate: (map['hireDate'] as dynamic).toDate(),
      photoUrl: map['photoUrl'],
      certifications: List<String>.from(map['certifications'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'membersCount': membersCount,
      'classesCount': classesCount,
      'status': status,
      'createdAt': createdAt,
      'baseSalary': baseSalary,
      'commissionRate': commissionRate,
      'hireDate': hireDate,
      'photoUrl': photoUrl,
      'certifications': certifications,
    };
  }
}
