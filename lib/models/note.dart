class Note {
  final String id;
  final String entityId; // memberId or guestId
  final String entityType; // Member or Guest
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final String? category; // General, Follow-up, Complaint, Achievement, etc.

  Note({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.category,
  });

  factory Note.fromMap(Map<String, dynamic> map, String id) {
    return Note(
      id: id,
      entityId: map['entityId'] ?? '',
      entityType: map['entityType'] ?? '',
      content: map['content'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as dynamic).toDate(),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entityId': entityId,
      'entityType': entityType,
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'category': category,
    };
  }
}
