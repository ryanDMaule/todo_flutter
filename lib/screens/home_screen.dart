import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              if (controller.isLoading) {
                return const CircularProgressIndicator();
              }
              if (controller.error != null) {
                return const Text('Unable to load saved tasks.');
              }
              return Text(
                'Todo foundation ready.\n'
                '${controller.todos.length} saved task(s).\n'
                'Task interface coming next.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              );
            },
          ),
        ),
      ),
    );
  }
}
