import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/controllers/todo_controller.dart';
import 'package:todo_flutter/data/todo_database.dart';
import 'package:todo_flutter/screens/home_screen.dart';

void main() {
  late TodoDatabase database;
  late TodoController controller;

  setUp(() async {
    database = TodoDatabase.forTesting(NativeDatabase.memory());
    controller = TodoController(database);
    await controller.addTodo('Task A');
    await controller.addTodo('Task B');
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(find.text('CLEAR ALL?'), findsOneWidget);
    expect(find.text('Delete all tasks?'), findsOneWidget);
  }

  testWidgets('confirm clears Drift and immediately updates the screen', (
    tester,
  ) async {
    await openDialog(tester);
    final cleared = Completer<void>();
    void listener() {
      if (controller.todos.isEmpty &&
          !controller.isLoading &&
          !cleared.isCompleted) {
        cleared.complete();
      }
    }

    controller.addListener(listener);
    await tester.tap(find.text('Clear All'));
    await tester.pump();
    await tester.runAsync(
      () => cleared.future.timeout(const Duration(seconds: 5)),
    );
    controller.removeListener(listener);
    await tester.pumpAndSettle();

    expect(find.text('CLEAR ALL?'), findsNothing);
    expect(find.text('0 Total task(s)'), findsOneWidget);
    expect(find.text('Task A'), findsNothing);
    expect(find.text('Task B'), findsNothing);
    expect(await tester.runAsync(database.loadTodos), isEmpty);
  });

  testWidgets('cancel, back, and outside dismissal delete nothing', (
    tester,
  ) async {
    for (final dismissal in ['cancel', 'back', 'outside']) {
      await openDialog(tester);
      if (dismissal == 'cancel') {
        await tester.tap(find.text('Cancel'));
      } else if (dismissal == 'back') {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tapAt(const Offset(5, 5));
      }
      await tester.pumpAndSettle();

      expect(find.text('CLEAR ALL?'), findsNothing);
      expect(controller.todos.length, 2);
      expect((await tester.runAsync(database.loadTodos))!.length, 2);
    }
  });

  testWidgets('empty list does not open the dialog', (tester) async {
    await tester.runAsync(controller.clearAll);
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(controller: controller)),
    );
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('CLEAR ALL?'), findsNothing);
    expect(find.text('0 Total task(s)'), findsOneWidget);
  });
}
