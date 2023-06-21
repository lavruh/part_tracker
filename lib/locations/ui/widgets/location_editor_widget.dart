import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/location_editor_state.dart';
import 'package:part_tracker/part_types/ui/widgets/part_types_widget.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class LocationEditorWidget extends StatelessWidget {
  const LocationEditorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationEditorState>(builder: (state) {
      if (!state.isSet()) {
        return Container();
      }
      return WillPopScope(
        onWillPop: () async => await _hasToSaveDialog(state),
        child: SizedBox(
          height: 300,
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller:
                              TextEditingController(text: state.getLocation.name),
                          decoration:
                              const InputDecoration(labelText: 'Location name:'),
                          onFieldSubmitted: (val) {
                            state.updateLocation(
                                state.getLocation.copyWith(name: val));
                          },
                        ),
                      ),
                      PartTypesWidget(
                        selected: state.getLocation.allowedPartTypes,
                        updateSelected: (val) {
                          state.updateLocation(state.getLocation
                              .copyWith(allowedPartTypes: val));
                        },
                      ),
                      CheckboxListTile(
                          title: const Text('Has counter?'),
                          value: state.hasCounter,
                          onChanged: (_) => state.toggleRunningHoursCounter()),
                    ],
                  ),
                ),
                if (state.isChanged)
                  TextButton(
                      onPressed: () => state.save(), child: const Text('Save')),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<bool> _hasToSaveDialog(LocationEditorState state) async {
    bool? actFl = true;
    if (state.item.isNotEmpty && state.isChanged) {
      actFl = await questionDialogWidget(question: 'Save changes?');
    }
    if (actFl == null) {
      return false;
    }
    if (actFl) {
      state.save();
    }
    return true;
  }
}
