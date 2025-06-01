import 'package:file_provider/file_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';

class BackupSettingsWidget extends StatelessWidget {
  const BackupSettingsWidget({super.key});

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
          ...state.filesToBackupPaths.map((e) => TextButton(
              onPressed: () {
                state.removeFileFromBackup(e);
              },
              child: Text(e))),
          IconButton(
            onPressed: () => _addFileToBackup(context, state),
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

  _addFileToBackup(BuildContext context, BackupState state) async {
    final fp = Get.find<IFileProvider>();
    try {
      final f =
          await fp.selectFile(context: context, title: "Select file to backup");
      final path = (f.path);
      state.addFileToBackup(path);
    } catch (e) {
      Get.defaultDialog(middleText: "$e");
    }
  }
}
