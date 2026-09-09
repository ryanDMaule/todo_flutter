import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/todo.dart';

part 'todo_database.g.dart';

@UseRowClass(Todo)
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskText => text()();
  TextColumn get status => textEnum<TodoStatus>()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Todos])
class TodoDatabase extends _$TodoDatabase {
  TodoDatabase() : super(driftDatabase(name: 'todo'));
  TodoDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<List<Todo>> loadTodos() {
    return (select(todos)..orderBy([
          (table) => OrderingTerm.asc(table.createdAt),
          (table) => OrderingTerm.asc(table.id),
        ]))
        .get();
  }

  Future<int> addTodo(String text) => into(todos).insert(
    TodosCompanion.insert(
      taskText: text,
      status: TodoStatus.underway,
      createdAt: DateTime.now().toUtc(),
    ),
  );

  Future<void> changeStatus(int id, TodoStatus status) async {
    await (update(todos)..where((table) => table.id.equals(id))).write(
      TodosCompanion(status: Value(status)),
    );
  }

  Future<void> deleteTodo(int id) async {
    await (delete(todos)..where((table) => table.id.equals(id))).go();
  }

  Future<void> clearAll() async {
    await delete(todos).go();
  }
}
