import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/locations_menu_bar_widget.dart';
import 'package:part_tracker/locations/ui/widgets/locations_overview_widget.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_widget.dart';
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
        Get.find<LogbookState>().removeLogFilter();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const LocationsMenuBarWidget(),
          actions: const [PartsMenuBarWidget()],
        ),
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: const LocationsOverviewWidget(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 2,
                    child: const PartsOverviewWidget()),
                SizedBox(
                    height: MediaQuery.of(context).size.height / 2 - 56,
                    width: MediaQuery.of(context).size.width / 2,
                    child: const LogBookWidget()),
              ],
            )
          ],
        ),
      ),
    );
  }
}
