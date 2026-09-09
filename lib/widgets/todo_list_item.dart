import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.number,
    this.onTap,
  });
  final Todo todo;
  final int number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (todo.status) {
      TodoStatus.aborted => AppColors.red,
      TodoStatus.underway => AppColors.yellow,
      TodoStatus.completed => AppColors.green,
    };
    return Semantics(
      label: 'Task $number, ${todo.status.name}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(2),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: AppColors.white, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  color: color,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text('$number', style: AppTextStyles.number),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(todo.taskText, style: AppTextStyles.task),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
