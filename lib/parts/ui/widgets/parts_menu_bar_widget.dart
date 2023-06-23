import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';

class PartsMenuBarWidget extends StatelessWidget {
  const PartsMenuBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PartsManagerState>(builder: (state) {
      final locationsMenuState = Get.find<LocationsMenuState>();
      final partCreateMenu = <Widget>[
        locationsMenuState.isLocationSelected
            ? IconButton(
                onPressed: () => state.createPart(),
                icon: const Icon(Icons.add))
            : Container()
      ];
      final partEditMenu = <Widget>[
        IconButton(
            onPressed: () => state.updateRemarksSelectedPart(),
            icon: const Icon(Icons.edit_note)),
        IconButton(
            onPressed: () => state.deleteSelectedPart(),
            icon: const Icon(Icons.delete)),
      ];
      return Row(
        children: !state.partSelected ? partCreateMenu : partEditMenu,
      );
    });
  }
}
