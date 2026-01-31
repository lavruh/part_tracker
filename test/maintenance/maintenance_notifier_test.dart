import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/maintenance/domain/entities/counter_maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/entities/time_based_maintenance_plan.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/data/i_db_service.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
// ignore: depend_on_referenced_pac
import '../mocks.dart';

import 'maintenance_notifier_test.mocks.dart';

const tableName = 'maintenance_plans';

@GenerateMocks([IDbService])
main() {
  group('MaintenanceNotifier getAll', () {
    late MockIDbService mockDbService;
    late MockLocationManagerState mockLocationsState;

    setUp(() {
      Get.reset();
      mockDbService = MockIDbService();
      mockLocationsState = MockLocationManagerState();
      Get.put<IDbService>(mockDbService);
      Get.put<LocationManagerState>(mockLocationsState);
    });

    test('should load time-based maintenance plans from database', () async {
      final planId = UniqueId();
      final timeBasedPlanMap = {
        'id': planId.toMap(),
        'title': 'Oil Change',
        'description': 'Regular oil change',
        'timeLimit': 30,
        'timeUnit': 'day',
        'planType': 'time_based',
      };

      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => Stream.fromIterable([timeBasedPlanMap]));

      final notifier = MaintenanceNotifier();
      // await notifier.getAll();
      await pumpEventQueue(times: 10);

      expect(notifier.maintenancePlans.keys, contains(planId));
      expect(
          notifier.maintenancePlans[planId], isA<TimeBasedMaintenancePlan>());
      expect(notifier.maintenancePlans[planId]!.title, 'Oil Change');
      expect(
          notifier.maintenancePlans[planId]!.description, 'Regular oil change');
      verify(mockDbService.getAll(table: tableName)).called(1);
    });

    test('should load counter-based maintenance plans from database', () async {
      final planId = UniqueId();
      final counterBasedPlanMap = {
        'id': planId.toMap(),
        'title': 'Filter Replacement',
        'description': 'Replace air filter',
        'counterLimit': 500,
        'planType': 'counter_based',
      };

      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => Stream.fromIterable([counterBasedPlanMap]));

      final notifier = MaintenanceNotifier();
      // await notifier.getAll();
      await pumpEventQueue(times: 10);

      expect(notifier.maintenancePlans.keys, contains(planId));
      expect(notifier.maintenancePlans[planId], isA<CounterMaintenancePlan>());
      expect(notifier.maintenancePlans[planId]!.title, 'Filter Replacement');
      expect(
          notifier.maintenancePlans[planId]!.description, 'Replace air filter');
      verify(mockDbService.getAll(table: tableName)).called(1);
    });

    test('should load mixed maintenance plans from database', () async {
      final timeBasedPlanId = UniqueId(id: 'time1');
      final counterBasedPlanId = UniqueId(id: 'count1');

      final timeBasedPlanMap = {
        'id': timeBasedPlanId.toMap(),
        'title': 'Oil Change',
        'description': 'Regular oil change',
        'timeLimit': 30,
        'timeUnit': 'day',
        'planType': 'time_based',
      };

      final counterBasedPlanMap = {
        'id': counterBasedPlanId.toMap(),
        'title': 'Filter Replacement',
        'description': 'Replace air filter',
        'counterLimit': 500,
        'planType': 'counter_based',
      };

      when(mockDbService.getAll(table: tableName)).thenAnswer(
          (_) => Stream.fromIterable([timeBasedPlanMap, counterBasedPlanMap]));

      final notifier = MaintenanceNotifier();
      // await notifier.getAll();
      await pumpEventQueue(times: 10);

      expect(notifier.maintenancePlans.keys,
          containsAll([timeBasedPlanId, counterBasedPlanId]));
      expect(notifier.maintenancePlans[timeBasedPlanId],
          isA<TimeBasedMaintenancePlan>());
      expect(notifier.maintenancePlans[counterBasedPlanId],
          isA<CounterMaintenancePlan>());
      expect(notifier.maintenancePlans.length, 2);
      verify(mockDbService.getAll(table: tableName)).called(1);
    });

    test('should handle empty database stream', () async {
      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => const Stream.empty());

      final notifier = MaintenanceNotifier();
      await pumpEventQueue(times: 10);

      expect(notifier.maintenancePlans.isEmpty, true);
      verify(mockDbService.getAll(table: tableName)).called(1);
    });

    test('should ignore unknown plan types', () async {
      final validPlanId = UniqueId(id: "valid");
      final invalidPlanId = UniqueId(id: "invalid");

      final validPlanMap = {
        'id': validPlanId.toMap(),
        'title': 'Valid Plan',
        'description': 'A valid plan',
        'timeLimit': 30,
        'timeUnit': 'day',
        'planType': 'time_based',
      };

      final invalidPlanMap = {
        'id': invalidPlanId.toMap(),
        'title': 'Invalid Plan',
        'description': 'An invalid plan',
        'planType': 'unknown_type',
      };

      when(mockDbService.getAll(table: tableName)).thenAnswer(
          (_) => Stream.fromIterable([validPlanMap, invalidPlanMap]));

      final notifier = MaintenanceNotifier();
      await pumpEventQueue(times: 10);

      expect(notifier.maintenancePlans.keys, contains(validPlanId));
      expect(notifier.maintenancePlans.keys, isNot(contains(invalidPlanId)));
      expect(notifier.maintenancePlans.length, 1);
      verify(mockDbService.getAll(table: tableName)).called(1);
    });
  });

  group('MaintenanceNotifier checkPartForNecessaryMaintenance', () {
    late MockIDbService mockDbService;
    late MockLocationManagerState mockLocationsState;
    late MaintenanceNotifier notifier;
    late PartType partType;
    late CounterMaintenancePlan counterPlan;

    setUp(() {
      Get.reset();
      mockDbService = MockIDbService();
      mockLocationsState = MockLocationManagerState();
      Get.put<IDbService>(mockDbService);
      Get.put<LocationManagerState>(mockLocationsState);

      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => Stream.empty());
      notifier = MaintenanceNotifier();

      final planId = UniqueId();
      counterPlan = CounterMaintenancePlan(
        id: planId,
        title: 'Filter Replacement',
        description: 'Replace air filter every 500 hours',
        counterLimit: 500,
      );

      notifier.maintenancePlans[planId] = counterPlan;

      partType = PartType(
        id: UniqueId(),
        name: 'Engine Filter',
        maintenancePlans: [planId],
      );
    });

    test(
        'should mark part as due for maintenance when running hours exceed counter limit',
        () {
      final part = Part(
        partNo: UniqueId(),
        runningHours: RunningHours(600),
        runningHoursAtLocation: RunningHours(600),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours(0),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.partsDueToMaintenance[part.partNo]!.length, 1);

      final maintenanceInfo =
          notifier.partsDueToMaintenance[part.partNo]!.first;
      expect(maintenanceInfo.plan, equals(counterPlan));
      expect(maintenanceInfo.info, contains('Overdue 100rhs'));
    });

    test(
        'should not mark part as due when running hours are below counter limit',
        () {
      final part = Part(
        partNo: UniqueId(),
        runningHours: RunningHours(300),
        runningHoursAtLocation: RunningHours(300),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours(0),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), false);
    });

    test(
        'should mark part as due when running hours exactly equal counter limit',
        () {
      final part = Part(
        partNo: UniqueId(id: "part1"),
        runningHours: RunningHours(500),
        runningHoursAtLocation: RunningHours(500),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours(0),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
    });

    test('should handle multiple counter-based maintenance plans for same part',
        () {
      final planId2 = UniqueId();
      final counterPlan2 = CounterMaintenancePlan(
        id: planId2,
        title: 'Oil Change',
        description: 'Change oil every 1000 hours',
        counterLimit: 1000,
      );

      notifier.maintenancePlans[planId2] = counterPlan2;

      final updatedPartType = PartType(
        id: partType.id,
        name: partType.name,
        maintenancePlans: [counterPlan.id, planId2],
      );

      final part = Part(
        partNo: UniqueId(),
        runningHours: RunningHours(1200),
        runningHoursAtLocation: RunningHours(1200),
        remarks: 'Test part',
        type: updatedPartType,
        installationRh: RunningHours(0),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.partsDueToMaintenance[part.partNo]!.length, 2);

      final maintenanceInfos = notifier.partsDueToMaintenance[part.partNo]!;
      expect(
          maintenanceInfos.any((info) => info.plan.id == counterPlan.id), true);
      expect(maintenanceInfos.any((info) => info.plan.id == counterPlan2.id),
          true);
      expect(
          maintenanceInfos.any((info) => info.info.contains('Overdue 700rhs')),
          true);
      expect(
          maintenanceInfos.any((info) => info.info.contains('Overdue 200rhs')),
          true);
    });

    test(
        'should add part to locations due for maintenance when location exists',
        () {
      final locationId = UniqueId(id: "location1");
      final part = Part(
        partNo: UniqueId(id: "part1"),
        runningHours: RunningHours(600),
        runningHoursAtLocation: RunningHours(600),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours(0),
      );
      final location = Location(
          id: locationId,
          name: 'Test Location',
          allowedPartTypes: {},
          parts: [part.partNo]);

      Get.reset();
      mockDbService = MockIDbService();
      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => Stream.empty());

      Get.put<IDbService>(mockDbService);
      Get.put<LogbookState>(MockLogbookState());
      Get.put<LocationsMenuState>(MockLocationsMenuState());
      final locationsState = LocationManagerState();
      Get.replace<LocationManagerState>(locationsState);
      locationsState.locations[locationId] = location;
      notifier = MaintenanceNotifier();
      notifier.maintenancePlans[counterPlan.id] = counterPlan;

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.locationsDueToMaintenance.containsKey(locationId), true);
      expect(notifier.locationsDueToMaintenance[locationId],
          contains(part.partNo));
    });

    test('should handle part with no maintenance plans gracefully', () {
      final partTypeNoPlans = PartType(
        id: UniqueId(),
        name: 'Simple Part',
        maintenancePlans: [],
      );

      final part = Part(
        partNo: UniqueId(),
        runningHours: RunningHours(600),
        runningHoursAtLocation: RunningHours(600),
        remarks: 'Test part',
        type: partTypeNoPlans,
        installationRh: RunningHours(0),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), false);
    });

    test('should handle missing maintenance plan gracefully', () {
      final missingPlanId = UniqueId();
      final partTypeWithMissingPlan = PartType(
        id: UniqueId(),
        name: 'Part with missing plan',
        maintenancePlans: [missingPlanId],
      );

      final part = Part(
        partNo: UniqueId(),
        runningHours: RunningHours(600),
        runningHoursAtLocation: RunningHours(600),
        remarks: 'Test part',
        type: partTypeWithMissingPlan,
        installationRh: RunningHours(0),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), false);
    });
  });

  group('MaintenanceNotifier checkPartForNecessaryMaintenance - Time Based', () {
    late MockIDbService mockDbService;
    late MaintenanceNotifier notifier;
    late PartType partType;
    late TimeBasedMaintenancePlan timePlan;

    setUp(() {
      Get.reset();
      mockDbService = MockIDbService();
      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => Stream.empty());
      Get.put<IDbService>(mockDbService);
      Get.put<LogbookState>(MockLogbookState());
      Get.put<LocationsMenuState>(MockLocationsMenuState());
      Get.put<LocationManagerState>(MockLocationManagerState());
      
      notifier = MaintenanceNotifier();
      
      timePlan = TimeBasedMaintenancePlan(
        id: UniqueId(id: "timePlan1"),
        title: 'Monthly Inspection',
        description: 'Inspect part monthly',
        timeLimit: 30,
        timeUnit: TimeUnit.day,
      );
      
      partType = PartType(
        id: UniqueId(id: "partType1"),
        name: 'Time Maintained Part',
        maintenancePlans: [timePlan.id],
      );
      
      notifier.maintenancePlans[timePlan.id] = timePlan;
    });

    test('should detect part due for time-based maintenance (days overdue)', () {
      final installationDate = DateTime.now().subtract(Duration(days: 45));
      final part = Part(
        partNo: UniqueId(id: "part1"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.partsDueToMaintenance[part.partNo]!.length, 1);
      
      final maintenanceInfo = notifier.partsDueToMaintenance[part.partNo]!.first;
      expect(maintenanceInfo.plan.id, timePlan.id);
      expect(maintenanceInfo.info, contains('Overdue'));
      expect(maintenanceInfo.info, contains('days'));
    });

    test('should not detect part due for time-based maintenance when within limit', () {
      final installationDate = DateTime.now().subtract(Duration(days: 15));
      final part = Part(
        partNo: UniqueId(id: "part2"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), false);
    });

    test('should detect part due for weekly time-based maintenance', () {
      final weeklyPlan = TimeBasedMaintenancePlan(
        id: UniqueId(id: "weeklyPlan"),
        title: 'Weekly Check',
        description: 'Check part weekly',
        timeLimit: 2,
        timeUnit: TimeUnit.week,
      );
      
      final weeklyPartType = PartType(
        id: UniqueId(id: "weeklyPartType"),
        name: 'Weekly Maintained Part',
        maintenancePlans: [weeklyPlan.id],
      );
      
      notifier.maintenancePlans[weeklyPlan.id] = weeklyPlan;
      
      final installationDate = DateTime.now().subtract(Duration(days: 21));
      final part = Part(
        partNo: UniqueId(id: "part3"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: weeklyPartType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.partsDueToMaintenance[part.partNo]!.length, 1);
      
      final maintenanceInfo = notifier.partsDueToMaintenance[part.partNo]!.first;
      expect(maintenanceInfo.plan.id, weeklyPlan.id);
      expect(maintenanceInfo.info, contains('Overdue'));
    });

    test('should detect part due for monthly time-based maintenance', () {
      final monthlyPlan = TimeBasedMaintenancePlan(
        id: UniqueId(id: "monthlyPlan"),
        title: 'Monthly Service',
        description: 'Service part monthly',
        timeLimit: 3,
        timeUnit: TimeUnit.month,
      );
      
      final monthlyPartType = PartType(
        id: UniqueId(id: "monthlyPartType"),
        name: 'Monthly Maintained Part',
        maintenancePlans: [monthlyPlan.id],
      );
      
      notifier.maintenancePlans[monthlyPlan.id] = monthlyPlan;
      
      final installationDate = DateTime.now().subtract(Duration(days: 120));
      final part = Part(
        partNo: UniqueId(id: "part4"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: monthlyPartType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.partsDueToMaintenance[part.partNo]!.length, 1);
      
      final maintenanceInfo = notifier.partsDueToMaintenance[part.partNo]!.first;
      expect(maintenanceInfo.plan.id, monthlyPlan.id);
      expect(maintenanceInfo.info, contains('Overdue'));
    });

    test('should handle multiple time-based maintenance plans for same part', () {
      final timePlan2 = TimeBasedMaintenancePlan(
        id: UniqueId(id: "timePlan2"),
        title: 'Quarterly Check',
        description: 'Check part quarterly',
        timeLimit: 90,
        timeUnit: TimeUnit.day,
      );
      
      final multiTimePartType = PartType(
        id: UniqueId(id: "multiTimePartType"),
        name: 'Multi Time Maintained Part',
        maintenancePlans: [timePlan.id, timePlan2.id],
      );
      
      notifier.maintenancePlans[timePlan2.id] = timePlan2;
      
      final installationDate = DateTime.now().subtract(Duration(days: 100));
      final part = Part(
        partNo: UniqueId(id: "part5"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: multiTimePartType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.partsDueToMaintenance[part.partNo]!.length, 2);
      
      final maintenanceInfos = notifier.partsDueToMaintenance[part.partNo]!;
      expect(maintenanceInfos.any((info) => info.plan.id == timePlan.id), true);
      expect(maintenanceInfos.any((info) => info.plan.id == timePlan2.id), true);
    });

    test('should add time-based maintenance part to locations due for maintenance', () {
      final locationId = UniqueId(id: "location1");
      final installationDate = DateTime.now().subtract(Duration(days: 45));
      final part = Part(
        partNo: UniqueId(id: "part6"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );
      final location = Location(
        id: locationId,
        name: 'Test Location',
        allowedPartTypes: {},
        parts: [part.partNo],
      );

      Get.reset();
      mockDbService = MockIDbService();
      when(mockDbService.getAll(table: tableName))
          .thenAnswer((_) => Stream.empty());

      Get.put<IDbService>(mockDbService);
      Get.put<LogbookState>(MockLogbookState());
      Get.put<LocationsMenuState>(MockLocationsMenuState());
      final locationsState = LocationManagerState();
      Get.replace<LocationManagerState>(locationsState);
      locationsState.locations[locationId] = location;
      notifier = MaintenanceNotifier();
      notifier.maintenancePlans[timePlan.id] = timePlan;

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.locationsDueToMaintenance.containsKey(locationId), true);
      expect(notifier.locationsDueToMaintenance[locationId],
          contains(part.partNo));
    });

    test('should handle time-based maintenance with missing location gracefully', () {
      final installationDate = DateTime.now().subtract(Duration(days: 45));
      final part = Part(
        partNo: UniqueId(id: "part7"),
        runningHours: RunningHours(100),
        runningHoursAtLocation: RunningHours(100),
        remarks: 'Test part',
        type: partType,
        installationRh: RunningHours.atTime(value: 0, date: installationDate),
      );

      notifier.checkPartForNecessaryMaintenance(part: part);

      expect(notifier.partsDueToMaintenance.containsKey(part.partNo), true);
      expect(notifier.locationsDueToMaintenance.isEmpty, true);
    });

  });


}
