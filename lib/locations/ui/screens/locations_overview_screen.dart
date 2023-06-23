import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/locations_menu_bar_widget.dart';
import 'package:part_tracker/locations/ui/widgets/locations_overview_widget.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/parts/ui/widgets/parts_menu_bar_widget.dart';
import 'package:part_tracker/parts/ui/widgets/parts_overview_widget.dart';

class LocationsOverviewScreen extends StatelessWidget {
  const LocationsOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (d) {
        Get.find<LocationManagerState>().toggleLocationSelection(null);
        Get.find<PartsManagerState>().deselectPart();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const LocationsMenuBarWidget(),
          actions: const [PartsMenuBarWidget()],
        ),
        body: const Row(
          children: [
            Flexible(child: LocationsOverviewWidget()),
            Flexible(child: PartsOverviewWidget()),
          ],
        ),
      ),
    );
  }
}
