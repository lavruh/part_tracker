import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget(
      {super.key,
      required this.child,
      required this.isSet,
      required this.isChanged,
      required this.save});

  final Widget child;
  final bool isSet;
  final bool isChanged;
  final Function save;

  @override
  Widget build(BuildContext context) {
    if (!isSet) {
      return Container();
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        final flag = await _hasToSaveDialog();
        if (flag) {
          Get.back();
        }
      },
      child: Flexible(
        child: SizedBox(
          height: 400,
          width: 700,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: SingleChildScrollView(child: child)),
                if (isChanged)
                  TextButton(
                      onPressed: () async => await save(),
                      child: const Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _hasToSaveDialog() async {
    bool? actFl = false;
    print('isSet [$isSet] && isChanged [$isChanged]');
    if (isSet && isChanged) {
      actFl = await questionDialogWidget(question: 'Save changes?');
    }
    if (actFl == null) {
      return false;
    }
    if (actFl) {
      save();
    }
    return true;
  }
}
