import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/logbook/domain/logbook_state.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';

class MockPartEditorState extends GetxController
    with Mock
    implements PartEditorState {}

class MockLogbookState extends GetxController
    with Mock
    implements LogbookState {}

class MockLocationManagerState extends GetxController
    with Mock
    implements LocationManagerState {}

class MockLocationEditorState extends GetxController
    with Mock
    implements LocationEditorState {}

class MockLocationsMenuState extends GetxController
    with Mock
    implements LocationsMenuState {}

class MockPartsManagerState extends GetxController
    with Mock
    implements PartsManagerState {}

class MockBackupState extends GetxController
    with Mock
    implements BackupState {}
