import 'dart:async';
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

  Future<void> submit(
    WidgetTester tester,
    String action,
    bool Function() done,
  ) async {
    final saved = Completer<void>();
    void listener() {
      if (done() && !controller.isLoading && !saved.isCompleted) {
        saved.complete();
      }
    }

    controller.addListener(listener);
    try {
      await tester.tap(find.text(action));
      await tester.pump();
      await tester.runAsync(
        () => saved.future.timeout(const Duration(seconds: 5)),
      );
      await tester.pumpAndSettle();
    } finally {
      controller.removeListener(listener);
    }
  }

  testWidgets(
    'preselects, drafts, and persists every status without editing text',
    (tester) async {
      await tester.runAsync(() => controller.addTodo('Task A'));
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(controller: controller)),
      );
      for (final entry in [
        (TodoStatus.completed, 'Completed'),
        (TodoStatus.aborted, 'Aborted'),
        (TodoStatus.underway, 'Underway'),
      ]) {
        final previous = controller.todos.single.status;
        await tester.tap(find.text('Task A'));
        await tester.pumpAndSettle();
        expect(find.text('Note: Task A'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(
          tester
              .widget<RadioGroup<TodoStatus>>(
                find.byType(RadioGroup<TodoStatus>),
              )
              .groupValue,
          previous,
        );
        await tester.tap(find.text(entry.$2).last);
        await tester.pump();
        expect(controller.todos.single.status, previous);
        expect(
          (await tester.runAsync(database.loadTodos))!.single.status,
          previous,
        );
        await submit(
          tester,
          'Update',
          () => controller.todos.single.status == entry.$1,
        );
        expect(find.text('TASK DETAILS'), findsNothing);
        final saved = (await tester.runAsync(database.loadTodos))!.single;
        expect(saved.status, entry.$1);
        expect(saved.taskText, 'Task A');
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Delete removes only selected task and closes numbering gap', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final text in ['Task A', 'Task B', 'Task C']) {
        await controller.addTodo(text);
      }
    });
    final ids = controller.todos.map((todo) => todo.id).toList();
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.tap(find.text('Task B'));
    await tester.pumpAndSettle();
    await submit(tester, 'Delete', () => controller.todos.length == 2);
    expect(find.text('TASK DETAILS'), findsNothing);
    expect(find.text('Task B'), findsNothing);
    expect(find.text('2 Total task(s)'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(
      (await tester.runAsync(database.loadTodos))!.map((todo) => todo.id),
      [ids[0], ids[2]],
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Cancel, back and outside discard status drafts', (tester) async {
    await tester.runAsync(() => controller.addTodo('Task A'));
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    for (final method in ['Cancel', 'back', 'outside']) {
      await tester.tap(find.text('Task A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aborted').last);
      await tester.pump();
      if (method == 'Cancel') {
        await tester.tap(find.text('Cancel'));
      } else if (method == 'back') {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tapAt(const Offset(5, 5));
      }
      await tester.pumpAndSettle();
      expect(find.text('TASK DETAILS'), findsNothing);
      expect(
        (await tester.runAsync(database.loadTodos))!.single.status,
        TodoStatus.underway,
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('narrow dialog keeps full heading and long note scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final text = List.filled(20, 'Long note').join('\n');
    await tester.runAsync(() => controller.addTodo(text));
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.tapAt(tester.getTopLeft(find.text(text)) + const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('TASK DETAILS'), findsOneWidget);
    expect(
      tester.getRect(find.text('TASK DETAILS')).left,
      greaterThanOrEqualTo(24),
    );
    expect(
      tester.getRect(find.text('TASK DETAILS')).right,
      lessThanOrEqualTo(296),
    );
    await tester.ensureVisible(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
