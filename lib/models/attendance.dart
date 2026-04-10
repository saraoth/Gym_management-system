class Attendance {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String activityType; // Gym, Class, PT Session
  final String? trainerId;
  final String? trainerName;
  final String? className;
  final int? duration; // in minutes
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.checkInTime,
    this.checkOutTime,
    required this.activityType,
    this.trainerId,
    this.trainerName,
    this.className,
    this.duration,
    required this.createdAt,
  });

  factory Attendance.fromMap(Map<String, dynamic> map, String id) {
    return Attendance(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      checkInTime: (map['checkInTime'] as dynamic).toDate(),
      checkOutTime: map['checkOutTime'] != null ? (map['checkOutTime'] as dynamic).toDate() : null,
      activityType: map['activityType'] ?? 'Gym',
      trainerId: map['trainerId'],
      trainerName: map['trainerName'],
      className: map['className'],
      duration: map['duration'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'activityType': activityType,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'className': className,
      'duration': duration,
      'createdAt': createdAt,
    };
  }
}
