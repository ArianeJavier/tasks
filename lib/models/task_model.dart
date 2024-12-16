class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool completed;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.completed,
  });

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      dueDate: DateTime.parse(data['due_date']),
      completed: data['completed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'completed': completed,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }

  static placeholder() {}
}
