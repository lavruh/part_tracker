import 'package:flutter/material.dart';
import 'package:part_tracker/maintenance/ui/maintenance_plans_selection_widget.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';

class PartTypeEditorWidget extends StatefulWidget {
  const PartTypeEditorWidget({
    super.key,
    required this.partType,
    required this.onConfirm,
  });
  final PartType partType;
  final Function(PartType) onConfirm;

  @override
  State<PartTypeEditorWidget> createState() => _PartTypeEditorWidgetState();
}

class _PartTypeEditorWidgetState extends State<PartTypeEditorWidget> {
  late PartType item;

  @override
  void initState() {
    item = widget.partType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Column(
        children: [
          TextField(
            controller: TextEditingController(text: item.name),
            onChanged: (text) {
              item = item.copyWith(name: text);
            },
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          MaintenancePlansSelectionWidget(
              selected: item.maintenancePlans,
              updateSelected: (selected) {
                item = item.copyWith(maintenancePlans: selected);
              }),
          IconButton(
              onPressed: () {
                widget.onConfirm(item);
              },
              icon: Icon(Icons.check))
        ],
      ),
    );
  }
}
