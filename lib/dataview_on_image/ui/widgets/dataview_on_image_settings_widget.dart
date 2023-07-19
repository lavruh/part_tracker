import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/utils/ui/widgets/editor_widget.dart';

class DataViewOnImageSettingsWidget extends StatelessWidget {
  const DataViewOnImageSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = Get.find<DataViewOnImageState>();
      final child = Column(
        children: [
          ListTile(
            leading: const Text('Config file:'),
            title: TextButton(
              onPressed: () => _selectConfigFile(state),
              child: Text(state.selectedConfigPath),
            ),
            trailing: IconButton(
                onPressed: () => state.showConfigEditor(),
                icon: const Icon(Icons.edit)),
          ),
          ListTile(
            leading: const Text('View port to show:'),
            title: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: state
                  .getRelatedViewPortIds()
                  .entries
                  .map((e) => InputChip(
                        label: Text(e.key),
                        selected: e.value,
                        onPressed: () => state.toggleViewPortActivation(e.key),
                      ))
                  .toList(),
            ),
          ),
        ],
      );
      return EditorWidget(
          isSet: state.configSelected,
          isChanged: state.configChanged,
          save: state.updateConfig,
          child: child);
    });
  }

  void _selectConfigFile(DataViewOnImageState state) {
    final locationId = Get.find<LocationsMenuState>().selectedLocation?.id;
    if (locationId != null) {
      state.selectConfigFile(locationId);
    }
  }
}
