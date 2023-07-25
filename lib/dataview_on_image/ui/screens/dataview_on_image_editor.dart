import 'package:data_on_image_view/ui/screens/editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';

class DataViewOnImageEditor extends StatelessWidget {
  const DataViewOnImageEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = Get.find<DataViewOnImageState>();
      final config = state.selectedConfig;

      Widget child = const CircularProgressIndicator();
      if (config != null) {
        try {
          child = EditorScreen(
            config: config,
            useBackButton: false,
          );
        } catch (e) {
          child = Text(e.toString());
        }
      }

      return WillPopScope(
          onWillPop: () async {
            state.reloadConfigFile();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () => state.showDataViewOnImageSettings(),
                    icon: const Icon(Icons.settings))
              ],
            ),
            body: child,
          ));
    });
  }
}
