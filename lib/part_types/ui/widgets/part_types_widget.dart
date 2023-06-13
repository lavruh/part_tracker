import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final state = Get.find<PartTypesState>();
    final types = state.types.isNotEmpty
        ? state.types.values
            .map((e) => InputChip(
                  label: Text(e.name),
                  selected: _isPartTypeSelected(e.id),
                  onPressed: () {
                    final index = selected.indexOf(e.id);
                    if (index != -1) {
                      selected.removeAt(index);
                    } else {
                      selected.add(e.id);
                    }
                    updateSelected(selected);
                  },
                ))
            .toList()
        : [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Allowed part types: ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...types,
        ],
      ),
    );
  }

  bool _isPartTypeSelected(UniqueId id) {
    return selected.contains(id);
  }
}
