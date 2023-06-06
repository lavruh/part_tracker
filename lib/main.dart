import 'package:flutter/material.dart';
import 'package:part_tracker/parts/ui/screens/part_tracker_overview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PartTrackerOverviewScreen(),
    );
  }
}
