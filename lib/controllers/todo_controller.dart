import 'package:flutter/foundation.dart';

import '../data/todo_database.dart';
import '../models/todo.dart';

/// The app owns the database; disposing this controller does not close it.
/// Mutations persist before refreshing the list and propagate failures to callers.
class TodoController extends ChangeNotifier {
  TodoController(this._database);

  final TodoDatabase _database;
  List<Todo> _todos = const [];
  bool _isLoading = true;
  Object? _error;
  bool _disposed = false;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      _todos = List.unmodifiable(await _database.loadTodos());
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> addTodo(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > 250) {
      throw ArgumentError('Task text must contain 1–250 characters.');
    }
    await _database.addTodo(trimmed);
    await loadTodos();
  }

  Future<void> changeStatus(int id, TodoStatus status) async {
    await _database.changeStatus(id, status);
    await loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await _database.deleteTodo(id);
    await loadTodos();
  }

  /// The UI must obtain confirmation before calling this operation.
  Future<void> clearAll() async {
    await _database.clearAll();
    await loadTodos();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
