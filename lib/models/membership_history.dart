class MembershipHistory {
  final String id;
  final String memberId;
  final String action; // Joined, Upgraded, Downgraded, Renewed, Swapped
  final String? previousPlan;
  final String newPlan;
  final double? previousFee;
  final double newFee;
  final DateTime effectiveDate;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  MembershipHistory({
    required this.id,
    required this.memberId,
    required this.action,
    this.previousPlan,
    required this.newPlan,
    this.previousFee,
    required this.newFee,
    required this.effectiveDate,
    this.reason,
    this.notes,
    required this.createdAt,
  });

  factory MembershipHistory.fromMap(Map<String, dynamic> map, String id) {
    return MembershipHistory(
      id: id,
      memberId: map['memberId'] ?? '',
      action: map['action'] ?? '',
      previousPlan: map['previousPlan'],
      newPlan: map['newPlan'] ?? '',
      previousFee: map['previousFee']?.toDouble(),
      newFee: (map['newFee'] ?? 0).toDouble(),
      effectiveDate: (map['effectiveDate'] as dynamic).toDate(),
      reason: map['reason'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'action': action,
      'previousPlan': previousPlan,
      'newPlan': newPlan,
      'previousFee': previousFee,
      'newFee': newFee,
      'effectiveDate': effectiveDate,
      'reason': reason,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}
