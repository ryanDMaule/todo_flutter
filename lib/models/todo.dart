enum TodoStatus { underway, completed, aborted }

class Todo {
  const Todo({
    required this.id,
    required this.taskText,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String taskText;
  final TodoStatus status;
  final DateTime createdAt;
}
