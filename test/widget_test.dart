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

  for (final width in [320.0, 412.0]) {
    testWidgets('main screen renders persisted tasks at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        await controller.addTodo('First task');
        await controller.addTodo(
          'Second task with a long note that wraps across multiple lines.',
        );
        await controller.addTodo('Third task');
        await controller.changeStatus(
          controller.todos[1].id,
          TodoStatus.aborted,
        );
        await controller.changeStatus(
          controller.todos[2].id,
          TodoStatus.completed,
        );
      });
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(controller: controller)),
      );
      await tester.pump();
      expect(find.text("TODAY'S TASKS"), findsOneWidget);
      expect(find.text('3 Total task(s)'), findsOneWidget);
      expect(find.text('First task'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final survivingId = controller.todos[2].id;
      await tester.tap(find.text('Clear all'));
      await tester.tap(find.text('Add Task'));
      expect(controller.todos.length, 3);

      await tester.runAsync(
        () => controller.deleteTodo(controller.todos[1].id),
      );
      await tester.pump();
      expect(find.text('2 Total task(s)'), findsOneWidget);
      expect(find.text('3'), findsNothing);
      expect(find.text('2'), findsOneWidget);
      expect(controller.todos.last.id, survivingId);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('empty list retains only the reference screen elements', (
    tester,
  ) async {
    await tester.runAsync(controller.loadTodos);
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    expect(find.text('0 Total task(s)'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.text('Aborted'), findsOneWidget);
    expect(find.text('Underway'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.byKey(const ValueKey('live-clock')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
