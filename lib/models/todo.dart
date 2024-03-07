class Todo {
  final String title;
  final String description;
  final bool completed;

  Todo({
    required this.title,
    required this.description,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
    };
  }
}
