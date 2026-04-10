class WorkoutClass {
  final String id;
  final String name;
  final String trainerId;
  final String trainerName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int enrolled;
  final String difficulty;
  final List<String> tags;

  WorkoutClass({
    required this.id,
    required this.name,
    required this.trainerId,
    required this.trainerName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.enrolled,
    required this.difficulty,
    required this.tags,
  });

  factory WorkoutClass.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      try {
        return (timestamp as dynamic).toDate();
      } catch (e) {
        return DateTime.now();
      }
    }

    return WorkoutClass(
      id: id,
      name: map['name'] ?? '',
      trainerId: map['trainerId'] ?? '',
      trainerName: map['trainerName'] ?? '',
      description: map['description'] ?? '',
      startTime: parseTimestamp(map['startTime']),
      endTime: parseTimestamp(map['endTime']),
      capacity: map['capacity'] ?? 0,
      enrolled: map['enrolled'] ?? 0,
      difficulty: map['difficulty'] ?? 'Beginner',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'capacity': capacity,
      'enrolled': enrolled,
      'difficulty': difficulty,
      'tags': tags,
    };
  }
}
