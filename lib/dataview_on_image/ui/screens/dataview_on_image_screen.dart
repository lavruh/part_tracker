import 'package:data_on_image_view/ui/screens/overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';

class DataViewOnImageScreen extends StatelessWidget {
  const DataViewOnImageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = Get.find<DataViewOnImageState>();
      final config = state.selectedConfig;
      return Scaffold(
          appBar: AppBar(),
          body: config == null
              ? Container()
              : OverviewScreen(
                  config: config,
                  data: state.data,
                ));
    });
  }
}
