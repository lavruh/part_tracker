import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/maintenance/domain/entities/counter_maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_info.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/entities/time_based_maintenance_plan.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class MaintenanceNotifier extends GetxController {
  final maintenancePlans = <UniqueId, MaintenancePlan>{}.obs;
  final partsDueToMaintenance = <UniqueId, List<MaintenanceInfo>>{}.obs;
  final locationsDueToMaintenance = <UniqueId, List<UniqueId>>{}.obs;
  final IDbService db = Get.find();
  final _tableName = 'maintenance_plans';
  final locationsState = Get.find<LocationManagerState>();

  MaintenanceNotifier() {
    getAll();
  }

  MaintenancePlan getMaintenancePlan(UniqueId id) {
    final plan = maintenancePlans[id];
    if (plan == null) {
      throw Exception("Maintenance plan with id[$id] does not exist.");
    }
    return plan;
  }

  void checkPartForNecessaryMaintenance({required Part part}) {
    final partType = part.type;
    final partPlans = partType.maintenancePlans;

    List<MaintenanceInfo> infoList = [];
    for (final planId in partPlans) {
      try {
        final plan = getMaintenancePlan(planId);
        final info = plan.checkPart(part: part);
        if (info != null) infoList.add(info);
      } catch (_) {
        continue;
      }
    }
    if (infoList.isEmpty) {
      _removeDueToMaintenance(part: part);
      return;
    }

    List<UniqueId> locationsTree = [];
    try {
      final location =
          locationsState.getLocationContainingPart(partId: part.partNo);
      final parentTree = locationsState.getParentLocationsTreeIds(location.id);
      locationsTree = [location.id, ...parentTree];
    } catch (_) {}

    _setDueToMaintenance(
        part: part, infoList: infoList, locationsTree: locationsTree);
  }

  _setDueToMaintenance({
    required Part part,
    required List<MaintenanceInfo> infoList,
    required List<UniqueId> locationsTree,
  }) {
    partsDueToMaintenance[part.partNo] = infoList;
    for (final locationId in locationsTree) {
      List<UniqueId>? locationParts = locationsDueToMaintenance[locationId];

      if (locationParts == null) {
        locationsDueToMaintenance[locationId] = [part.partNo];
      } else {
        locationParts.add(part.partNo);
        locationsDueToMaintenance[locationId] = locationParts;
      }
    }
  }

  _removeDueToMaintenance({
    required Part part,
  }) {
    partsDueToMaintenance.remove(part.partNo);

    Map<UniqueId, List<UniqueId>> tmp = {};
    for (final locationKey in locationsDueToMaintenance.keys) {
      List<UniqueId>? location = locationsDueToMaintenance[locationKey];
      if (location == null) continue;
      location.remove(part.partNo);
      if (location.isEmpty) {
        continue;
      }
      tmp[locationKey] = location;
    }
    locationsDueToMaintenance.value = tmp;
  }

  bool isPartsDueToMaintenance(List<UniqueId> parts) {
    return parts.any((part) => isPartDueToMaintenance(part));
  }

  bool isPartDueToMaintenance(UniqueId part) =>
      partsDueToMaintenance.containsKey(part);

  void updateMaintenancePlan(MaintenancePlan item) {
    maintenancePlans[item.id] = item;
    db.update(id: item.id.toString(), item: item.toMap(), table: _tableName);
  }

  getAll() async {
    await for (final map in db.getAll(table: _tableName)) {
      final planType = map['planType'];
      MaintenancePlan? plan;
      if (planType == 'time_based') {
        plan = TimeBasedMaintenancePlan.fromMap(map);
      }
      if (planType == 'counter_based') {
        plan = CounterMaintenancePlan.fromMap(map);
      }
      if (plan != null) {
        maintenancePlans.addEntries([MapEntry(plan.id, plan)]);
      }
    }
  }

  List<MaintenanceInfo> necessaryMaintenanceInfos(UniqueId partId){
    return partsDueToMaintenance[partId] ?? [];
  }

  removePartType(UniqueId id) {
    maintenancePlans.remove(id);
    db.delete(id: id.toString(), table: _tableName);
  }

  isDueToMaintenance(UniqueId id) {
    return locationsDueToMaintenance.containsKey(id);
  }
}
