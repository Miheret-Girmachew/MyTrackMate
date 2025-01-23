class Task {
  final String id;
  final String name;
  final String status;
  final String time;
  final String groupId;

  Task({
    required this.id,
    required this.name,
    required this.status,
    required this.time,
    required this.groupId,
  });

  factory Task.fromFirestore(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      status: data['status'] ?? '',
      time: data['time'] ?? '',
      groupId: data['groupId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'status': status,
      'time': time,
      'groupId': groupId,
    };
  }
}
