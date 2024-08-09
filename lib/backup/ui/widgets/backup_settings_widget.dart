import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';
import 'package:path/path.dart' as p;

class BackupSettingsWidget extends StatelessWidget {
  const BackupSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Get.find<BackupState>();
    final formKey = GlobalKey<FormState>();
    return Obx(() {
      return Column(
        children: [
          ListTile(
            title: Form(
              key: formKey,
              child: TextFormField(
                initialValue: state.amountOfSteps.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Number backups to keep, set 0 to keep all:"),
                validator: _positiveIntValidator,
                onChanged: (v) {
                  final curState = formKey.currentState;
                  if (curState != null && curState.validate()) {
                    final i = int.parse(v);
                    state.amountOfSteps = i;
                  }
                },
              ),
            ),
          ),
          const Text('Files to backup...'),
          ...state.filesToBackupPaths
              .map((e) => TextButton(
                  onPressed: () {
                    state.removeFileFromBackup(e);
                  },
                  child: Text(e)))
              .toList(),
          IconButton(
            onPressed: () => _addFileToBackup(state),
            icon: const Icon(Icons.add_link),
            tooltip: 'Add file to backup',
          ),
        ],
      );
    });
  }

  String? _positiveIntValidator(v) {
    if (v == null || v.isEmpty) return "Should not be empty";
    final i = int.tryParse(v);
    if (i == null) return 'Should be integer';
    if (i < 0) return 'Should be positive number';
    return null;
  }

  _addFileToBackup(BackupState state) async {
    final initDir = Get.find<String>(tag: 'dirName');
    final f = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select file to backup',
      initialDirectory: p.join(initDir, ' '),
    );
    if (f != null) {
      final path = f.paths.first ?? '';
      state.addFileToBackup(path);
    }
  }
}
