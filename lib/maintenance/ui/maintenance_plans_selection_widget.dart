import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/maintenance/domain/maintenance_notifier.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class MaintenancePlansSelectionWidget extends StatefulWidget {
  const MaintenancePlansSelectionWidget(
      {super.key, required this.selected, required this.updateSelected});
  final List<UniqueId> selected;
  final Function(List<UniqueId>) updateSelected;

  @override
  State<MaintenancePlansSelectionWidget> createState() =>
      _MaintenancePlansSelectionWidgetState();
}

class _MaintenancePlansSelectionWidgetState
    extends State<MaintenancePlansSelectionWidget> {
  late List<UniqueId> selected;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetX<MaintenanceNotifier>(
      builder: (state) {
        return Padding(
          padding: const EdgeInsets.all(3.0),
          child: Wrap(
            children: [
              ...state.maintenancePlans.values.map((e) => Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ChoiceChip(
                        label: Text(e.title),
                        selected: _isSelected(e.id),
                        onSelected: (value) {
                          if (value) {
                            selected.add(e.id);
                          } else {
                            selected.remove(e.id);
                          }
                          setState(() {
                            widget.updateSelected(selected);
                          });
                        }),
                  ))
            ],
          ),
        );
      },
    );
  }

  bool _isSelected(UniqueId id) => selected.contains(id);
}
