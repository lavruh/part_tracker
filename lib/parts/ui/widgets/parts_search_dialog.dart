import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';

class PartsSearchDialog extends StatelessWidget {
  const PartsSearchDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 500,
      width: 200,
      child: Obx(() {
        final state = Get.find<PartsManagerState>();
        final foundParts = state.foundPartsIds;
        return WillPopScope( onWillPop: () async{
          state.foundPartsIds.clear();
          return true;
        },
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              initialValue: '',
              onChanged: (v) => state.searchPart(v),
            ),
            SizedBox(
              height: 200,
              child: ListView(
                children: foundParts
                    .map((e) => TextButton(
                        onPressed: () => state.selectFoundPart(e),
                        child: Text("${e.type.name} No: ${e.partNo}")))
                    .toList(),
              ),
            )
          ]),
        );
      }),
    );
  }
}
