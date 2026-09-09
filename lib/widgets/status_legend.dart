import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.blue,
      child: Row(
        children: [
          Expanded(child: _LegendEntry('Aborted', AppColors.red)),
          Expanded(child: _LegendEntry('Underway', AppColors.yellow)),
          Expanded(child: _LegendEntry('Completed', AppColors.green)),
        ],
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 12,
          width: double.infinity,
          child: ColoredBox(color: color),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(label, style: AppTextStyles.legend),
        ),
      ],
    );
  }
}
