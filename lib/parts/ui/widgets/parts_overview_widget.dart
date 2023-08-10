import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_menu_state.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/parts/ui/widgets/part_widget.dart';
import 'package:part_tracker/parts/ui/widgets/parts_header_widget.dart';

class PartsOverviewWidget extends StatelessWidget {
  const PartsOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<LocationsMenuState>(builder: (state) {
      if (state.selectedLocation == null) {
        return Container();
      }
      final partsState = Get.find<PartsManagerState>();
      final items = partsState.getPartWithIds(state.selectedLocation!.parts);
      final selectedPart = partsState.selectedPart;
      final scrollController = ScrollController();
      final  partWidgetHeight = MediaQuery.of(context).size.height * 0.045;

      double itemIndex = 0;
      if (selectedPart != null) {
        itemIndex = items.indexOf(selectedPart).toDouble();
      }
      final itemPosition = (itemIndex * partWidgetHeight);
      Future.delayed(const Duration(milliseconds: 5),
          () => _scrollListViewToSelected(scrollController, itemPosition));

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${state.selectedLocation?.name ?? ''} parts',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const PartsHeaderWidget(),
          Flexible(
              child: ListView(
            controller: scrollController,
            children: [
              ...items.map((e) => PartWidget(
                    item: e,
                    onTap: () => partsState.selectPart(e),
                    partSelected: partsState.currentPartSelected(e.partNo),
                    widgetMaxHeight: partWidgetHeight,
                  ))
            ],
          )),
        ],
      );
    });
  }

  void _scrollListViewToSelected(
    ScrollController scrollController,
    double itemPosition,
  ) {
    final currentViewPos = scrollController.position.pixels;
    final portDimensions = scrollController.position.viewportDimension;
    final currentViewMaxPos = currentViewPos + portDimensions;

    if (itemPosition < currentViewPos || itemPosition > currentViewMaxPos) {
      scrollController.animateTo(
        itemPosition,
        duration: const Duration(milliseconds: 5),
        curve: Curves.fastOutSlowIn,
      );
    }
  }
}
