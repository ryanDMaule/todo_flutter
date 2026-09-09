import 'package:flutter/material.dart';

import '../controllers/todo_controller.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dialog_action_button.dart';

class ClearAllDialog extends StatefulWidget {
  const ClearAllDialog({
    super.key,
    required this.controller,
    required this.audioService,
  });

  final TodoController controller;
  final AudioService audioService;

  @override
  State<ClearAllDialog> createState() => _ClearAllDialogState();
}

class _ClearAllDialogState extends State<ClearAllDialog> {
  bool _clearing = false;
  String? _error;

  Future<void> _clearAll() async {
    if (_clearing) return;
    setState(() {
      _clearing = true;
      _error = null;
    });

    try {
      await widget.controller.clearAll();
      widget.audioService.playClear();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _clearing = false;
          _error = 'Unable to clear tasks. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_clearing,
      child: Dialog(
        backgroundColor: AppColors.blue,
        surfaceTintColor: AppColors.blue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CLEAR ALL?',
                    maxLines: 1,
                    style: AppTextStyles.heading,
                  ),
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Delete all tasks?',
                      style: AppTextStyles.action,
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
                        color: AppColors.green,
                        textColor: AppColors.black,
                        onPressed: _clearing
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
                        label: _clearing ? 'Clearing...' : 'Clear All',
                        color: AppColors.red,
                        textColor: AppColors.white,
                        onPressed: _clearing ? null : _clearAll,
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
