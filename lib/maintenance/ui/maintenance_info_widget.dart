import 'package:flutter/material.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_info.dart';

class MaintenanceInfoWidget extends StatelessWidget {
  const MaintenanceInfoWidget(
      {super.key, required this.info, required this.defTextStyle});
  final MaintenanceInfo info;
  final TextStyle defTextStyle;

  @override
  Widget build(BuildContext context) {
    final textColor = info.isOverdue ? Colors.red : defTextStyle.color;
    final fillColor = textColor?.withValues(alpha: 0.2);
    final backgroundColor = textColor?.withValues(alpha: 0.05);

    return Stack(
      alignment: Alignment.center,
      children: [
        LinearProgressIndicator(
          value: info.percentage,
          minHeight: 11,
          color: fillColor,
          backgroundColor: backgroundColor,
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(text: "${info.info} ", style: defTextStyle.copyWith(color: textColor)),
              TextSpan(text: info.plan.title, style: defTextStyle.copyWith(color: textColor)),
            ]),
          ),
        ),
      ],
    );
  }
}
