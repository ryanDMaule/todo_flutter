import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dialog_action_button.dart';

import '../controllers/todo_controller.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({
    super.key,
    required this.controller,
    required this.audioService,
  });
  final TodoController controller;
  final AudioService audioService;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _text = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_saving) return;
    final text = _text.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please enter task text');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.addTodo(text);
      widget.audioService.playOther();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Unable to add task. Please try again.';
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                  child: Text('NEW TASK', style: AppTextStyles.heading),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _text,
                  autofocus: true,
                  enabled: !_saving,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 5,
                  maxLines: 8,
                  inputFormatters: [LengthLimitingTextInputFormatter(250)],
                  style: AppTextStyles.body,
                  cursorColor: AppColors.green,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter task',
                    labelStyle: AppTextStyles.action.copyWith(
                      color: AppColors.yellow,
                    ),
                    floatingLabelStyle: AppTextStyles.action.copyWith(
                      color: AppColors.yellow,
                    ),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppColors.black,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none,
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DialogActionButton(
                        label: _saving ? 'Adding...' : 'Add',
                        color: AppColors.green,
                        textColor: AppColors.black,
                        onPressed: _saving ? null : _add,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
