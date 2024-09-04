import 'package:data_on_image_view/ui/screens/overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';

class DataViewOnImageScreen extends StatelessWidget {
  const DataViewOnImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = Get.find<DataViewOnImageState>();
      final config = state.selectedConfig;
      return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () => state.showDataViewOnImageSettings(),
                  icon: const Icon(Icons.settings))
            ],
          ),
          body: config == null
              ? Container()
              : OverviewScreen(
                  config: config,
                  data: state.data,
                  useMenu: false,
                  onSaveConfig: (conf) => state.saveConfig(conf),
                  selectFileDialog: (title) async =>
                      state.selectFile(context, title),
                ));
    });
  }
}
