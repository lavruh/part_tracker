import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_overview_widget.dart';

showLogbookOverviewDialog(BuildContext context) {
  Get.defaultDialog(title: 'Logbook', content: const LogbookOverviewDialog());
}

class LogbookOverviewDialog extends StatefulWidget {
  const LogbookOverviewDialog({super.key});

  @override
  State<LogbookOverviewDialog> createState() => _LogbookOverviewDialogState();
}

class _LogbookOverviewDialogState extends State<LogbookOverviewDialog> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;
    final width = MediaQuery.of(context).size.width * 0.9;
    return SizedBox(
      height: height,
      width: width,
      child: const LogBookOverviewWidget(),
    );
  }
}
