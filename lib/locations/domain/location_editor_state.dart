import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/location_editor_widget.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';

class LocationEditorState extends GetxController {
  final item = <Location>[].obs;
  final _isChanged = false.obs;
  bool createMode = false;

  bool isSet() => item.isNotEmpty;

  bool get isChanged => _isChanged.value;

  Location get getLocation => item.first;

  clearLocation() {
    item.clear();
    update();
  }

  openEditorDialog(Location l, {bool create = false}) async {
    setLocation(l);
    String title = 'Edit location';
    createMode = create;
    if (createMode) {
      title = 'Create location';
    }
    Get.defaultDialog(content: const LocationEditorWidget(), title: title);
  }

  setLocation(Location l) async {
    item.value = [l];
    _isChanged.value = false;
    update();
  }

  updateLocation(Location l) {
    item.value = [l];
    _isChanged.value = true;
    update();
  }

  save() {
    final locationsManager = Get.find<LocationManagerState>();
    final location = getLocation;

    if (createMode && locationsManager.hasLocationWithSameId(location.id)) {
      Get.defaultDialog(
          middleText:
              'Location with same id exists! Please type another name.');
      return;
    }
    locationsManager.updateLocation(location);
    _isChanged.value = false;
    update();
  }

  bool get hasCounter => getLocation.runningHours != null;

  toggleRunningHoursCounter() {
    if (hasCounter) {
      updateLocation(getLocation.copyWith(clearRunningHours: true));
    } else {
      updateLocation(getLocation.copyWith(runningHours: RunningHours(0)));
    }
  }
}
