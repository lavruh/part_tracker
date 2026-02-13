import 'dart:io';

import 'package:data_on_image_view/ui/widgets/overview_widget.dart';
import 'package:data_on_image_view/ui/widgets/view_port_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/dataview_on_image/domain/dataview_on_image_state.dart';
import 'package:part_tracker/dataview_on_image/ui/widgets/custom_data_view_widget.dart';

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
              : OverviewWidget(
                  img: config.getFile,
                  viewPorts: config.viewPorts,
                  child: (e) {
                    final data = state.data[e.id];
                    final size = MediaQuery.of(context).size;
                    return ViewPortWidget(
                      item: e,
                      data: data,
                      customDataWidgets: [
                        ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxWidth(size),
                              maxHeight: maxHeight(size),
                            ),
                            child: SingleChildScrollView(
                                child: CustomDataViewWidget(port: e)))
                      ],
                    );
                  }));
    });
  }

  double maxHeight(Size size) {
    if (Platform.isAndroid) return size.height * 0.08;
    return size.height * 0.5;
  }

  double maxWidth(Size size) {
    if (Platform.isAndroid) return size.width * 0.4;
    return size.width * 0.1;
  }
}
