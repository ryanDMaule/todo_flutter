import 'package:flutter/material.dart';
import '../controllers/todo_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/status_legend.dart';
import '../widgets/todo_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const ColoredBox(
              color: AppColors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "TODAY'S TASKS",
                      maxLines: 1,
                      style: AppTextStyles.heading,
                    ),
                  ),
                  SizedBox(height: 16),
                  StatusLegend(),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${controller.todos.length} Total task(s)',
                                style: AppTextStyles.action,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: _ScreenButton(
                                label: 'Clear all',
                                color: AppColors.red,
                                textColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: controller.error != null
                            ? const Center(
                                child: Text(
                                  'Unable to load saved tasks.',
                                  style: AppTextStyles.task,
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  8,
                                ),
                                itemCount: controller.todos.length,
                                separatorBuilder: (_, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final todo = controller.todos[index];
                                  return TodoListItem(
                                    key: ValueKey(todo.id),
                                    todo: todo,
                                    number: index + 1,
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: _ScreenButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    barrierColor: AppColors.black.withValues(alpha: 0.5),
                    builder: (_) => AddTaskDialog(controller: controller),
                  ),
                  label: 'Add Task',
                  color: AppColors.green,
                  textColor: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keep reference styling; Clear all remains disabled.
class _ScreenButton extends StatelessWidget {
  const _ScreenButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.onPressed,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            label,
            style: AppTextStyles.action.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
