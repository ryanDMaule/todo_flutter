import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/controllers/todo_controller.dart';
import 'package:todo_flutter/data/todo_database.dart';
import 'package:todo_flutter/models/todo.dart';
import 'package:todo_flutter/screens/home_screen.dart';

void main() {
  late TodoDatabase database;
  late TodoController controller;

  setUp(() {
    database = TodoDatabase.forTesting(NativeDatabase.memory());
    controller = TodoController(database);
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test(
    'persists task lifecycle with stable IDs and explicit statuses',
    () async {
      await controller.loadTodos();
      await controller.addTodo(' First ');
      await controller.addTodo('Second');
      final first = controller.todos.first;
      final secondId = controller.todos.last.id;
      expect(first.taskText, 'First');
      expect(first.status, TodoStatus.underway);
      expect(first.createdAt, isA<DateTime>());

      await controller.changeStatus(first.id, TodoStatus.completed);
      expect((await database.loadTodos()).first.status, TodoStatus.completed);
      await controller.changeStatus(first.id, TodoStatus.aborted);
      expect(controller.todos.first.status, TodoStatus.aborted);
      await controller.changeStatus(first.id, TodoStatus.underway);
      expect(controller.todos.first.status, TodoStatus.underway);

      await controller.deleteTodo(first.id);
      await controller.addTodo('Third');
      expect(controller.todos.first.id, secondId);
      expect(controller.todos.last.id, isNot(first.id));
      expect(controller.todos.last.id, isNot(secondId));
      expect(() => controller.todos.clear(), throwsUnsupportedError);

      await controller.clearAll();
      expect(await database.loadTodos(), isEmpty);
      expect(controller.todos, isEmpty);
    },
  );

  test('rejects blank and oversized tasks without writing them', () async {
    await expectLater(controller.addTodo('  '), throwsArgumentError);
    await expectLater(controller.addTodo('x' * 251), throwsArgumentError);
    expect(await database.loadTodos(), isEmpty);
  });

  testWidgets('placeholder renders after loading the database', (tester) async {
    await controller.loadTodos();
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    expect(find.textContaining('Todo foundation ready.'), findsOneWidget);
    expect(find.textContaining('0 saved task(s).'), findsOneWidget);
  });
}
