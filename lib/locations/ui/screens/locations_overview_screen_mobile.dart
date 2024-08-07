import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/locations_menu_bar_widget.dart';
import 'package:part_tracker/locations/ui/widgets/locations_overview_widget.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_widget.dart';
import 'package:part_tracker/parts/ui/widgets/parts_menu_bar_widget.dart';
import 'package:part_tracker/parts/ui/widgets/parts_overview_widget.dart';
import 'package:part_tracker/utils/ui/widgets/drawer_menu_widget.dart';

class LocationsOverviewScreenMobile extends StatelessWidget {
  const LocationsOverviewScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: Get.find<LocationManagerState>().pageController,
      children: [
        GestureDetector(
          onTapUp: (d) {
            Get.find<LocationManagerState>().toggleLocationSelection(null);
            Get.find<LogbookState>().removeLogFilter();
          },
          child: Scaffold(
            appBar: AppBar(title: const LocationsMenuBarWidget()),
            drawer: const DrawerMenuWidget(),
            body: const LocationsOverviewWidget(),
          ),
        ),
        Scaffold(
          appBar: AppBar(title: const PartsMenuBarWidget()),
          body: const Flex(
            direction: Axis.vertical,
            children: [
              Flexible(
                child: PartsOverviewWidget(),
              ),
              Flexible(child: LogBookWidget()),
            ],
          ),
        )
      ],
    );
  }
}
