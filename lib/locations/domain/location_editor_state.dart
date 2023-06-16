import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/locations/ui/widgets/location_editor_widget.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';

class LocationEditorState extends GetxController {
  final item = <Location>[].obs;
  final _isChanged = false.obs;

  bool isSet() => item.isNotEmpty;

  bool get isChanged => _isChanged.value;

  Location get getLocation => item.first;

  clearLocation() {
    item.clear();
    update();
  }

  openEditorDialog(Location l) async {
    setLocation(l);
    Get.defaultDialog(content: const LocationEditorWidget(),title: 'Edit location');
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
    Get.find<LocationManagerState>().updateLocation(item.first);
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
