import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class LocationsMenuState extends GetxController {
  final visible = false.obs;
  final _editor = Get.find<LocationEditorState>();
  final _selectedLocation = <Location>[].obs;

  bool get isLocationSelected => _selectedLocation.isNotEmpty;

  Location? get selectedLocation {
    if (_selectedLocation.isNotEmpty) {
      return _selectedLocation.first;
    }
    return null;
  }

  showMenu(Location val) {
    visible.value = true;
    _selectedLocation.value = [val];
  }

  toggleMenu(Location? val) {
    visible.value = !visible.value;
    if (val != null) {
      _selectedLocation.value = [val];
    } else {
      _selectedLocation.clear();
    }
  }

  openEditor() {
    if (isLocationSelected) {
      _editor.openEditorDialog(_selectedLocation.first);
    } else {
      _editor.openEditorDialog(Location.empty(name: ''));
    }
  }

  duplicateSelectedItem() {
    final l = _selectedLocation.first;
    if (isLocationSelected) {
      Get.find<LocationManagerState>()
          .updateLocation(l.copyWith(id: UniqueId(), name: "${l.name}_"));
    }
  }

  addSubLocation() {
    final l = _selectedLocation.first;
    if (isLocationSelected) {
      Get.find<LocationManagerState>().updateLocation(
        Location.empty(name: 'name').copyWith(parentLocation: l.id),
      );
    }
  }

  deleteSelectedLocation() async {
    final l = _selectedLocation.first;
    if (isLocationSelected) {
      final act = await questionDialogWidget(question: 'Delete location?');
      if (act != null && act) {
        Get.find<LocationManagerState>().deleteLocation(l.id);
      }
    }
  }
}
