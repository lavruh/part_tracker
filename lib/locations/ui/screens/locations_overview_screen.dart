import 'package:flutter/material.dart';
import 'package:part_tracker/locations/ui/widgets/locations_overview_widget.dart';

class LocationsOverviewScreen extends StatelessWidget {
  const LocationsOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const LocationsOverviewWidget(),
    );
  }
}