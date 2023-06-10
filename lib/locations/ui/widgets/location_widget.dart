import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/running_hours/ui/widgets/running_hours_edit_dialog.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({
    Key? key,
    required this.entry,
    required this.expandCallback,
    required this.selectCallback,
    required this.isSelected,
    required this.updateRunningHours,
  }) : super(key: key);
  final TreeEntry<Location> entry;
  final bool isSelected;
  final Function expandCallback;
  final Function selectCallback;
  final Function(RunningHours) updateRunningHours;

  @override
  Widget build(BuildContext context) {
    return TreeIndentation(
      entry: entry,
      child: Row(children: [
        entry.hasChildren
            ? IconButton(
                onPressed: () => expandCallback(),
                icon: entry.isExpanded
                    ? const Icon(Icons.folder_open)
                    : const Icon(Icons.folder))
            : const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.label_important_outline),
              ),
        InkWell(
          onTap: () => selectCallback(),
          child: Text(
            entry.node.name,
            style: isSelected
                ? const TextStyle(fontWeight: FontWeight.bold)
                : const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
        if (entry.node.runningHours != null)
          InkWell(
            onTap: () => _showRhUpdateDialog(context),
            child: Text('   RH: ${entry.node.runningHours}'),
          )
      ]),
    );
  }

  void _showRhUpdateDialog(BuildContext context) async {
    final rh = await showDialog<RunningHours>(
        context: context,
        builder: (_) => RunningHoursEditDialog(item: entry.node.runningHours!));
    if (rh != null) {
      updateRunningHours(rh);
    }
  }
}
