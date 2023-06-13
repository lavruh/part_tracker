import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/part_types/ui/widgets/part_types_widget.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class LocationEditorWidget extends StatelessWidget {
  const LocationEditorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationEditorState>(builder: (state) {
      if (!state.isSet()) {
        return Container();
      }
      return Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: TextEditingController(text: state.getLocation.name),
                decoration: const InputDecoration(labelText: 'Location name:'),
                onFieldSubmitted: (val) {
                  state.updateLocation(state.getLocation.copyWith(name: val));
                },
              ),
              PartTypesWidget(
                // key: Key(state.getLocation.allowedPartTypes.toString()),
                selected: state.getLocation.allowedPartTypes,
                updateSelected: (List<UniqueId> val) {
                  state.updateLocation(
                      state.getLocation.copyWith(allowedPartTypes: val));
                },
              ),
              if (state.isChanged)
                TextButton(
                    onPressed: () {
                      state.save();
                    },
                    child: const Text('Save')),
            ],
          ),
        ),
      );
    });
  }
}
