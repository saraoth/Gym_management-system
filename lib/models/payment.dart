class Payment {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String paymentMethod; // Cash, Card, Bank Transfer, UPI
  final String paymentType; // Membership, PT Session, Registration, Other
  final String status; // Paid, Pending, Overdue, Refunded
  final DateTime paymentDate;
  final DateTime dueDate;
  final String? planType;
  final String? notes;
  final DateTime createdAt;
  final String? receiptNumber;
  final String? transactionId;

  Payment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    required this.paymentDate,
    required this.dueDate,
    this.planType,
    this.notes,
    required this.createdAt,
    this.receiptNumber,
    this.transactionId,
  });

  factory Payment.fromMap(Map<String, dynamic> map, String id) {
    return Payment(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      paymentType: map['paymentType'] ?? 'Membership',
      status: map['status'] ?? 'Paid',
      paymentDate: (map['paymentDate'] as dynamic).toDate(),
      dueDate: (map['dueDate'] as dynamic).toDate(),
      planType: map['planType'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
      receiptNumber: map['receiptNumber'],
      transactionId: map['transactionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentType': paymentType,
      'status': status,
      'paymentDate': paymentDate,
      'dueDate': dueDate,
      'planType': planType,
      'notes': notes,
      'createdAt': createdAt,
      'receiptNumber': receiptNumber,
      'transactionId': transactionId,
    };
  }
}
