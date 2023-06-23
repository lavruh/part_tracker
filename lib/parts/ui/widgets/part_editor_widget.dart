import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:part_tracker/part_types/ui/widgets/part_types_widget.dart';
import 'package:part_tracker/parts/domain/part_editor_state.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';
import 'package:part_tracker/utils/ui/widgets/editor_widget.dart';

class PartEditorWidget extends StatelessWidget {
  const PartEditorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PartEditorState>(builder: (state) {
      final child = Form(
        key: state.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: TextEditingController(text: state.partNo),
              decoration: const InputDecoration(labelText: 'Part number'),
              onFieldSubmitted: (v) {
                state.updatePart(state.part!.copyWith(partNo: UniqueId(id: v)));
              },
              validator: (v) {
                if (v == null) return 'Wrong value';
                if (v.isEmpty) return 'Should not be empty';
                return null;
              },
            ),
            PartTypesWidget(
                selected: state.partType,
                updateSelected: state.updatePartType,
                requestQty: false),
            TextFormField(
              controller: TextEditingController(text: state.runningHours),
              decoration:
                  const InputDecoration(labelText: 'Initial running hours'),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (v) {
                final rh = int.tryParse(v);
                if (rh != null) {
                  state.updatePart(
                      state.part!.copyWith(runningHours: RunningHours(rh)));
                }
              },
              validator: (t){
                if (t == null) return 'Wrong value';
                if(int.tryParse(t) == null) return 'Should be integer';
                return null;
              },
            ),
            TextFormField(
              controller: TextEditingController(text: state.remarks),
              decoration: const InputDecoration(labelText: 'Remarks'),
              onFieldSubmitted: (v) {
                state.updatePart(state.part!.copyWith(remarks: v));
              },
            ),
          ],
        ),
      );
      return EditorWidget(
          isSet: state.isSet,
          isChanged: state.isChanged,
          save: state.save,
          child: child);
    });
  }
}
