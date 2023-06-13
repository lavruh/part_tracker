import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/ui/widgets/location_editor_widget.dart';
import 'package:part_tracker/locations/ui/widgets/locations_overview_widget.dart';

class LocationsOverviewScreen extends StatelessWidget {
  const LocationsOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        children: [
          Flexible(
              child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              const LocationsOverviewWidget(),
              Card(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.find<LocationEditorState>()
                              .setLocation(Location.empty(name: ''));
                        },
                        icon: const Icon(Icons.add))
                  ],
                ),
              )
            ],
          )),
          const Flexible(child: LocationEditorWidget()),
        ],
      ),
    );
  }
}
