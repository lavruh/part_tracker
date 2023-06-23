import 'package:flutter/material.dart';
import 'package:part_tracker/utils/ui/widgets/question_dialog_widget.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget(
      {Key? key,
      required this.child,
      required this.isSet,
      required this.isChanged,
      required this.save})
      : super(key: key);

  final Widget child;
  final bool isSet;
  final bool isChanged;
  final Function save;

  @override
  Widget build(BuildContext context) {
    if (!isSet) {
      return Container();
    }
    return WillPopScope(
      onWillPop: () async => await _hasToSaveDialog(),
      child: SizedBox(
        height: 300,
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(child: child),
              if (isChanged)
                TextButton(onPressed: () => save(), child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _hasToSaveDialog() async {
    bool? actFl = false;
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
