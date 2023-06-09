import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/location_widget.dart';

class LocationsOverviewWidget extends StatelessWidget {
  const LocationsOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<LocationManagerState>(builder: (state) {
      final roots = state.getSubLocations(null);
      final treeController = TreeController(
          roots: roots,
          childrenProvider: (location) {
            return state.getSubLocations(location.id);
          });
      return AnimatedTreeView(
          treeController: treeController,
          nodeBuilder: (_, entry) {
            return LocationWidget(
                entry: entry,
                expandCallback: () =>
                    treeController.toggleExpansion(entry.node),
                selectCallback: () {
                  state.toggleLocationSelection(entry.node);
                  treeController.rebuild();
                },
                isSelected: state.isLocationSelected(entry.node));
          });
    });
  }
}
