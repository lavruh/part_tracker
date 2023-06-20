import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
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
      _updateLocationAndSubLocations(updatedLocation);
    }
  }

  void _updateLocationAndSubLocations(Location location) {
    updateLocation(location);

    if (location.parts.isNotEmpty && location.runningHours != null) {
      final RunningHours rh = location.runningHours!;
      Get.find<PartsManagerState>()
          .updatePartsRunningHours(partIds: location.parts, runningHours: rh);
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

  movePartFromSelected({
    required UniqueId partId,
    required UniqueId targetLocation,
  }) async {
    if (_selectedLocation != null) {
      try {
        await movePartBetweenLocations(
            partId: partId,
            sourceLocation: _selectedLocation!.id,
            targetLocation: targetLocation);
        final target = locations[targetLocation];
        _menu.showMenu(target!);
      } on LocationManagerException catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
  }

  movePartBetweenLocations({
    required UniqueId partId,
    required UniqueId sourceLocation,
    required UniqueId targetLocation,
  }) async {
    final partsManager = Get.find<PartsManagerState>();
    final source = locations[sourceLocation];
    final target = locations[targetLocation];
    if (source == null || target == null) {
      throw LocationManagerException('Invalid source or target location');
    }
    final parts = partsManager.getPartWithIds([partId]);
    if (parts.isEmpty) {
      throw LocationManagerException('Part not found');
    }
    final part = parts.first;
    final partRhUpdateDate = part.runningHours.date;
    final n = DateTime.now();
    if (partRhUpdateDate.millisecondsSinceEpoch <
        DateTime(n.year, n.month, n.day).millisecondsSinceEpoch) {
      throw LocationManagerException('Running hours are not up to date');
    }
    final targetParts = partsManager.getPartWithIds(target.parts);
    for (final i in targetParts) {
      if (i.type == part.type) {
        throw LocationManagerException(
            'Target location already has a part with the same part type');
      }
    }

    List<UniqueId> tmp = source.parts;
    tmp.removeWhere((e) => e.id == partId.id);
    updateLocation(source.copyWith(parts: tmp));

    tmp = target.parts;
    tmp.add(partId);
    updateLocation(target.copyWith(parts: tmp));
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
