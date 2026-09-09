import 'dart:async';

import 'package:flutter/material.dart';

import 'controllers/todo_controller.dart';
import 'data/todo_database.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final TodoDatabase _database;
  late final TodoController _controller;

  @override
  void initState() {
    super.initState();
    _database = TodoDatabase();
    _controller = TodoController(_database);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      await _controller.loadTodos();
    } catch (_) {
      // The controller exposes the load failure to HomeScreen.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(_database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.black,
        fontFamily: AppTextStyles.fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          secondary: AppColors.yellow,
          surface: AppColors.black,
          error: AppColors.red,
          onPrimary: AppColors.black,
          onSecondary: AppColors.black,
          onSurface: AppColors.white,
          onError: AppColors.white,
        ),
      ),
      home: HomeScreen(controller: _controller),
    );
  }
}
