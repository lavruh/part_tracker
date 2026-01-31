import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/part_types/ui/widgets/part_type_editor_widget.dart';
import 'package:part_tracker/part_types/ui/widgets/qty_edit_dialog.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartTypesWidget extends StatelessWidget {
  const PartTypesWidget(
      {super.key,
      required this.selected,
      required this.updateSelected,
      this.requestQty = true});
  final Map<UniqueId, int?> selected;
  final Function(Map<UniqueId, int?>) updateSelected;
  final bool requestQty;

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
                            onPressed: () {
                              Get.defaultDialog(
                                  title: "Part type [edit]",
                                  content: PartTypeEditorWidget(
                                      partType: e,
                                      onConfirm: (val){
                                        state.updatePartType(val);
                                      }));
                            },
                          )
                        : InputChip(
                            label: Text("${e.name}${_getQty(e.id)}"),
                            selected: _isPartTypeSelected(e.id),
                            onPressed: () => requestQty
                                ? _showQtyEditDialog(e)
                                : _toggleState(e),
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
        subtitle: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: SingleChildScrollView(
            child: Wrap(
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
          ),
        ),
      );
    });
  }

  bool _isPartTypeSelected(UniqueId id) {
    return selected.containsKey(id);
  }

  _showQtyEditDialog(PartType e) {
    Get.defaultDialog(
        title: e.name,
        content: QtyEditDialog(
          item: e,
          isSelected: _isPartTypeSelected(e.id),
          updateCallback: (MapEntry<UniqueId, int?>? val) {
            if (val != null) {
              selected.addEntries([val]);
            } else {
              selected.remove(e.id);
            }
            updateSelected(selected);
            Get.back();
          },
        ));
  }

  void _toggleState(PartType e) {
    if (selected.containsKey(e.id)) {
      selected.remove(e.id);
    } else {
      selected.putIfAbsent(e.id, () => 0);
    }
    updateSelected(selected);
  }

  String _getQty(UniqueId id) {
    if (!selected.containsKey(id)) return '';
    final qty = selected[id];
    if (qty != null && qty > 0) {
      return "\t$qty pcs";
    }
    return '';
  }
}
