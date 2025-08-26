import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';

class LocationsMenuBarWidget extends StatelessWidget {
  const LocationsMenuBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<LocationsMenuState>(builder: (state) {
      final createMenu = [
        IconButton(
            onPressed: () => state.openEditor(), icon: const Icon(Icons.add)),
      ];
      final editMenu = [
        IconButton(
            onPressed: () => state.openEditor(),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit'),
        IconButton(
            onPressed: () => state.duplicateSelectedItem(),
            icon: const Icon(Icons.copy),
            tooltip: 'Duplicate'),
        IconButton(
            onPressed: () => state.addSubLocation(),
            icon: const Icon(Icons.account_tree),
            tooltip: 'Add sub location'),
        IconButton(
            onPressed: () => state.deleteSelectedLocation(),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete'),
        IconButton(
            onPressed: () => state.showDataOnImgSelectedLocation(context),
            icon:  Image.asset("assets/overview.png", height: 25, width: 25),
            tooltip: 'Show report'),
      ];

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: state.isLocationSelected ? editMenu : createMenu,
      );
    });
  }
}
