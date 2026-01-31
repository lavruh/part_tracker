import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:part_tracker/locations/domain/entities/location.dart';
import 'package:part_tracker/running_hours/domain/entities/running_hours.dart';
import 'package:part_tracker/running_hours/ui/widgets/running_hours_edit_dialog.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({
    super.key,
    required this.entry,
    required this.expandCallback,
    required this.selectCallback,
    required this.isSelected,
    required this.showRunningHours,
    required this.hasPartsDueToMaintenance,
    required this.updateRunningHours,
    this.showOverview,
  });
  final TreeEntry<Location> entry;
  final bool isSelected;
  final bool showRunningHours;
  final bool hasPartsDueToMaintenance;
  final Function expandCallback;
  final Function selectCallback;
  final Function(RunningHours) updateRunningHours;
  final Function()? showOverview;

  @override
  Widget build(BuildContext context) {
    final titleColor = hasPartsDueToMaintenance ? Colors.red : Colors.black;

    return TreeIndentation(
      entry: entry,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
                  ? TextStyle(fontWeight: FontWeight.bold, color: titleColor)
                  : TextStyle(fontWeight: FontWeight.normal, color: titleColor),
            ),
          ),
          if (entry.node.runningHours != null && showRunningHours)
            InkWell(
              onTap: () => _showRhUpdateDialog(context),
              child: Text('   RH: ${entry.node.runningHours}'),
            ),
          if (showOverview != null)
            IconButton(
              onPressed: showOverview,
              icon: Image.asset("assets/overview.png", height: 20, width: 20),
            ),
        ]),
      ),
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
