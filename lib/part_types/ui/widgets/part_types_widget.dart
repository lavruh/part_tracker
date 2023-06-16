import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartTypesWidget extends StatelessWidget {
  const PartTypesWidget(
      {Key? key, required this.selected, required this.updateSelected})
      : super(key: key);
  final List<UniqueId> selected;
  final Function(List<UniqueId>) updateSelected;

  @override
  Widget build(BuildContext context) {
    return GetX<PartTypesState>(builder: (state) {
      final types = state.types.isNotEmpty
          ? state.types.values
              .map((e) => Transform.scale(
                    scale: 0.95,
                    child: state.isEditMode
                        ? InputChip(
                            label: Text(e.name),
                            onDeleted: () => state.removePartType(e.id),
                            onPressed: () => _showNameEditDialog(
                              initName: e.name,
                              update: (val) {
                                state.updatePartType(e.copyWith(name: val));
                              },
                            ),
                          )
                        : InputChip(
                            label: Text(e.name),
                            selected: _isPartTypeSelected(e.id),
                            onPressed: () => _toggleState(e),
                          ),
                  ))
              .toList()
          : <Widget>[];

      return ListTile(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Allowed part types: ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                  onPressed: () => state.toggleMode(),
                  icon: state.isEditMode
                      ? const Icon(Icons.check)
                      : const Icon(Icons.edit))
            ],
          ),
        ),
        subtitle: Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...types,
            if (state.isEditMode)
              Transform.scale(
                scale: 0.95,
                child: InputChip(
                  label: const Icon(Icons.add),
                  onPressed: () => state.createPartType(),
                ),
              )
          ],
        ),
      );
    });
  }

  void _toggleState(PartType e) {
    final index = selected.indexOf(e.id);
    if (index != -1) {
      selected.removeAt(index);
    } else {
      selected.add(e.id);
    }
    updateSelected(selected);
  }

  bool _isPartTypeSelected(UniqueId id) {
    return selected.contains(id);
  }

  _showNameEditDialog(
      {required String initName, required Function(String) update}) async {
    final controller = TextEditingController(text: initName);
    Get.defaultDialog(
        title: 'Name:',
        content: TextFormField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              update(controller.text);
              Get.back();
            },
            child: const Text('Confirm'),
          )
        ]);
  }
}
