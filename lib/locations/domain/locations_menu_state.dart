import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class LocationsMenuState extends GetxController {
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
    _selectedLocation.value = [val];
  }

  toggleMenu(Location? val) {
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
      _editor.openEditorDialog(Location.empty(name: ''), create: true);
    }
  }

  duplicateSelectedItem() {
    final l = _selectedLocation.first;
    if (isLocationSelected) {
      _editor.openEditorDialog(l.copyWith(id: l.id, name: l.name),
          create: true);
    }
  }

  addSubLocation() {
    final l = _selectedLocation.first;
    if (isLocationSelected) {
      _editor.openEditorDialog(
          l.copyWith(id: UniqueId(), name: "", parentLocation: l.id),
          create: true);
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

  showDataOnImgSelectedLocation() {
    final location = selectedLocation;
    if (location != null) {
      final data = Get.find<LocationManagerState>()
          .getLocationTreeReportData(locationId: location.id);
      Get.find<DataViewOnImageState>()
          .showDataViewOnImage(locationId: location.id, data: data);
    }
  }
}
