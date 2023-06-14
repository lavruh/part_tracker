import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class LocationManagerState extends GetxController {
  final locations = <UniqueId, Location>{}.obs;
  final IDbService _db = Get.find();
  final table = 'locations';
  Location? _selectedLocation;
  final _menu = Get.find<LocationsMenuState>();
  late TreeController<Location> _treeController;

  LocationManagerState() {
    _setTreeController();
    getAllLocations();
  }

  TreeController<Location> get treeController => _treeController;

  _setTreeController() {
    _treeController = TreeController(
        roots: getSubLocations(null),
        childrenProvider: (location) {
          return getSubLocations(location.id);
        });
  }

  toggleLocationSelection(Location? val) {
    if (_selectedLocation == val || val == null) {
      _selectedLocation = null;
      _menu.toggleMenu(null);
    } else {
      _selectedLocation = val;
      _menu.showMenu(val);
    }
    treeController.rebuild();
  }

  bool isLocationSelected(Location other) {
    return _selectedLocation == other;
  }

  updateLocationRunningHours({required UniqueId locationId, RunningHours? rh}) {
    final location = locations[locationId];
    if (location != null) {
      final updatedLocation = location.copyWith(
        runningHours: rh,
      );

      // Update the location and its sub-locations
      _updateLocationAndSubLocations(updatedLocation);
    }
  }

  void _updateLocationAndSubLocations(Location location) {
    updateLocation(location);

    if (location.parts.isNotEmpty) {
      //  call parts manager to update parts
      // throw UnimplementedError();
    }

    final subLocations = getSubLocations(location.id);
    for (final subLocation in subLocations) {
      final updatedSubLocation = subLocation.copyWith(
        runningHours: location.runningHours,
      );
      _updateLocationAndSubLocations(updatedSubLocation);
    }
  }

  getAllLocations() async {
    await for (final map in _db.getAll(table: table)) {
      final location = Location.fromMap(map);
      _updateState(location);
    }
    _setTreeController();
  }

  updateLocation(Location item) async {
    _updateState(item);
    _db.update(id: item.id.toString(), item: item.toMap(), table: table);
  }

  void _updateState(Location updatedLocation) {
    locations[updatedLocation.id] = updatedLocation;
    _setTreeController();
    _expandTillSelected();
  }

  _expandTillSelected() {
    if (_selectedLocation != null) {
      treeController.expandAncestors(_selectedLocation!, (node) {
        if (node.parentLocation == null) return null;
        return getParentLocation(node.parentLocation!);
      });
    }
  }

  deleteLocation(UniqueId id) async {
    locations.removeWhere((key, value) => key == id);
    _db.delete(id: id.toString(), table: table);
    _setTreeController();
  }

  List<Location> getSubLocations(UniqueId? parentId) {
    return locations.values.where((e) => e.parentLocation == parentId).toList();
  }

  Location getParentLocation(UniqueId parentId) {
    if (locations.containsKey(parentId)) {
      return locations[parentId]!;
    } else {
      throw LocationManagerException('Item <$parentId> does not exist');
    }
  }
}

class LocationManagerException implements Exception {
  final String m;

  @override
  String toString() {
    return 'LocationManagerException{m: $m}';
  }

  LocationManagerException(this.m);
}
