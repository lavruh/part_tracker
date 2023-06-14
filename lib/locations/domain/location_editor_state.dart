import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

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

  setLocation(Location l) async {
    bool? actFl = true;
    if (item.isNotEmpty && _isChanged.value) {
      actFl = await questionDialogWidget(
          question: 'Save changes?', onConfirm: save());
    }
    if (actFl == null || actFl) {
      item.value = [l];
      _isChanged.value = false;
      update();
    }
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
}
