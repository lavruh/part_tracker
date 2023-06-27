import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class LocationManagerState extends GetxController {
  final locations = <UniqueId, Location>{}.obs;
  final IDbService _db = Get.find();
  final table = 'locations';
  final _menu = Get.find<LocationsMenuState>();
  final _logbook = Get.find<LogbookState>();
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

  Location? get _selectedLocation => _menu.selectedLocation;

  toggleLocationSelection(Location? val) {
    if (_selectedLocation == val || val == null) {
      _menu.toggleMenu(null);
    } else {
      _menu.showMenu(val);
      _logbook.filterLogByLocation(val.id);
    }
    treeController.rebuild();
  }

  bool isLocationSelected(Location other) {
    return other == _menu.selectedLocation;
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

  void _updateLocationAndSubLocations(Location location) async {
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
        Get.defaultDialog(middleText: e.m);
      }
    }
  }

  moveNewPartToSelectedLocation({
    required UniqueId partId,
  }) async {
    if (_selectedLocation != null) {
      try {
        await movePartBetweenLocations(
            partId: partId,
            sourceLocation: null,
            targetLocation: _selectedLocation!.id);
      } on LocationManagerException catch (e) {
        Get.defaultDialog(middleText: e.m);
      }
    }
  }

  movePartBetweenLocations({
    required UniqueId partId,
    required UniqueId? sourceLocation,
    required UniqueId targetLocation,
  }) async {
    final partsManager = Get.find<PartsManagerState>();
    final target = locations[targetLocation];
    if (target == null) {
      throw LocationManagerException('Invalid source or target location');
    }
    final parts = partsManager.getPartWithIds([partId]);
    if (parts.isEmpty) {
      throw LocationManagerException('Part not found');
    }
    final part = parts.first;

    if (!target.allowedPartTypes.containsKey(part.type.id)) {
      throw LocationManagerException(
          'Part is not suitable for target location');
    }
    final partTypeQty = target.allowedPartTypes[part.type.id];
    final targetParts = partsManager.getPartWithIds(target.parts);
    final sameTypeParts = targetParts.where((e) => e.type == part.type);
    if (partTypeQty != null &&
        sameTypeParts.length + 1 > partTypeQty &&
        partTypeQty != 0) {
      throw LocationManagerException(
          'Location already has a part of same type');
    }
    Location? source;
    if (sourceLocation != null) {
      source = locations[sourceLocation];
      if (source != null) {
        final sourceRhUpdateDate = source.runningHours?.date;
        if (sourceRhUpdateDate != null) {
          final n = DateTime.now();
          if (sourceRhUpdateDate.millisecondsSinceEpoch <
              DateTime(n.year, n.month, n.day).millisecondsSinceEpoch) {
            throw LocationManagerException('Running hours are not up to date');
          }
        }
        List<UniqueId> tmp = source.parts;
        tmp.removeWhere((e) => e.id == partId.id);
        updateLocation(source.copyWith(parts: tmp));
      }
    }

    await partsManager.updateRemarks(part);
    final updatedPart = partsManager.getPartWithIds([partId]).first;
    _logbook.movePartLogEntry(
        part: updatedPart, target: target, source: source);

    List<UniqueId> tmp = target.parts;
    tmp.add(partId);
    updateLocation(target.copyWith(parts: tmp));
  }

  deletePartSelectedLocation(UniqueId partId) {
    final location = _selectedLocation;
    if (location != null) {
      if (!location.parts.contains(partId)) {
        throw LocationManagerException(
            'Cannot delete [$partId] part not found');
      }
      List<UniqueId> tmp = location.parts;
      tmp.remove(partId);
      updateLocation(location.copyWith(parts: tmp));
      _logbook.addLogEntry('Part no [$partId] deleted from ${location.name}',
          relatedParts: [partId], relatedLocations: [location.id]);
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
