import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/part_types/ui/widgets/part_types_widget.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/editor_widget.dart';

class LocationEditorWidget extends StatelessWidget {
  const LocationEditorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationEditorState>(builder: (state) {
      final child = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.createMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: TextEditingController(
                    text: state.getLocation.id.toString()),
                decoration: const InputDecoration(labelText: 'Location ID:'),
                onFieldSubmitted: (val) {
                  state.updateLocation(
                      state.getLocation.copyWith(id: UniqueId(id: val)));
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: TextEditingController(text: state.getLocation.name),
              decoration: const InputDecoration(labelText: 'Location name:'),
              onFieldSubmitted: (val) {
                state.updateLocation(state.getLocation.copyWith(name: val));
              },
            ),
          ),
          PartTypesWidget(
            selected: {...state.getLocation.allowedPartTypes},
            updateSelected: (val) {
              final newItem = state.getLocation.copyWith(allowedPartTypes: val);
              state.updateLocation(newItem);
            },
          ),
          CheckboxListTile(
              title: const Text('Has counter?'),
              value: state.hasCounter,
              onChanged: (_) => state.toggleRunningHoursCounter()),
        ],
      );

      return EditorWidget(
          isSet: state.isSet(),
          isChanged: state.isChanged,
          save: state.save,
          child: child);
    });
  }
}
