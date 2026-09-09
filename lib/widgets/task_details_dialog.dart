import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dialog_action_button.dart';

class TaskDetailsDialog extends StatefulWidget {
  const TaskDetailsDialog({
    super.key,
    required this.todo,
    required this.controller,
    required this.audioService,
  });
  final Todo todo;
  final TodoController controller;
  final AudioService audioService;

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  late TodoStatus _selected;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.todo.status;
  }

  Future<void> _submit({required bool delete}) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (delete) {
        await widget.controller.deleteTodo(widget.todo.id);
        widget.audioService.playClear();
      } else {
        await widget.controller.changeStatus(widget.todo.id, _selected);
        widget.audioService.playOther();
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = delete
              ? 'Unable to delete task. Please try again.'
              : 'Unable to update task. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: Dialog(
        backgroundColor: AppColors.blue,
        surfaceTintColor: AppColors.blue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'TASK DETAILS',
                    maxLines: 1,
                    style: AppTextStyles.heading,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Note: ${widget.todo.taskText}',
                  style: AppTextStyles.action,
                ),
                const SizedBox(height: 16),
                RadioGroup<TodoStatus>(
                  groupValue: _selected,
                  onChanged: (value) {
                    if (!_saving && value != null) {
                      widget.audioService.playClick();
                      setState(() => _selected = value);
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      children: [
                        _statusChoice(
                          TodoStatus.completed,
                          'Completed',
                          AppColors.green,
                        ),
                        _statusChoice(
                          TodoStatus.underway,
                          'Underway',
                          AppColors.yellow,
                        ),
                        _statusChoice(
                          TodoStatus.aborted,
                          'Aborted',
                          AppColors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: AppTextStyles.task.copyWith(color: AppColors.yellow),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DialogActionButton(
                        label: 'Delete',
                        color: AppColors.red,
                        textColor: AppColors.white,
                        onPressed: _saving ? null : () => _submit(delete: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DialogActionButton(
                        label: 'Update',
                        color: AppColors.green,
                        textColor: AppColors.black,
                        onPressed: _saving
                            ? null
                            : () => _submit(delete: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DialogActionButton(
                  label: 'Cancel',
                  color: AppColors.red,
                  textColor: AppColors.white,
                  onPressed: _saving
                      ? null
                      : () {
                          widget.audioService.playBack();
                          Navigator.of(context).pop();
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChoice(TodoStatus status, String label, Color color) {
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _saving
            ? null
            : () {
                widget.audioService.playClick();
                setState(() => _selected = status);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Radio<TodoStatus>(
                value: status,
                enabled: !_saving,
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? color
                      : AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.task),
            ],
          ),
        ),
      ),
    );
  }
}
