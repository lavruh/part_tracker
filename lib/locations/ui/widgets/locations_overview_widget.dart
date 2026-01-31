import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/location_widget.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class LocationsOverviewWidget extends StatelessWidget {
  const LocationsOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<LocationManagerState>(builder: (state) {
      state.getSubLocations(null); //this line to force getx to work

      final maintenanceNotifier = Get.find<MaintenanceNotifier>();

      final treeController = state.treeController;
      return AnimatedTreeView(
          treeController: treeController,
          nodeBuilder: (_, entry) {
            return DragTarget<Part>(
              onAcceptWithDetails: (obj) => _processObj(obj, entry, state),
              builder: (context, _, __) {
                final location = entry.node;

                final hasPartsDueToMaintenance =
                    maintenanceNotifier.isDueToMaintenance(location.id);

                return LocationWidget(
                  entry: entry,
                  expandCallback: () =>
                      treeController.toggleExpansion(location),
                  selectCallback: () {
                    state.toggleLocationSelection(location);
                  },
                  updateRunningHours: (val) {
                    state.updateLocationRunningHours(
                        locationId: location.id, rh: val);
                  },
                  isSelected: state.isLocationSelected(location),
                  hasPartsDueToMaintenance: hasPartsDueToMaintenance,
                  showRunningHours: state.showLocationRunningHours(location),
                  showOverview:
                      state.getOverviewShowCallback(context, location),
                );
              },
            );
          });
    });
  }

  _processObj(DragTargetDetails<Part> obj, entry, state) {
    final p = obj.data;
    state.movePartFromSelected(partId: p.partNo, targetLocation: entry.node.id);
  }
}
