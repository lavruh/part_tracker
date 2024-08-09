import 'package:flutter/material.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_overview_widget.dart';

class LogbookOverviewScreen extends StatelessWidget {
  const LogbookOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(),
        body: SizedBox(
          height: height,
          width: width,
          child: const LogBookOverviewWidget(),
        ));
  }
}
