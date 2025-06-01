import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/backup/domain/backups_state.dart';
import 'package:part_tracker/backup/ui/widgets/backup_item_widget.dart';
import 'package:part_tracker/backup/ui/widgets/backup_settings_widget.dart';
import 'package:part_tracker/utils/ui/widgets/text_input_dialog_widget.dart';
import 'package:restart_app/restart_app.dart';

class BackupsDialogWidget extends StatelessWidget {
  const BackupsDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Get.find<BackupState>();
    state.getAvailableBackups();
    return Obx(() {
      final backupItems = state.availableBackups;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () => _createBackup(state),
                  icon: const Icon(Icons.add)),
              IconButton(
                  onPressed: () => Get.defaultDialog(
                      title: 'Backup Settings',
                      content: const BackupSettingsWidget()),
                  icon: const Icon(Icons.settings)),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.7,
            child: ListView(
              children: backupItems
                  .map((e) => BackupItemWidget(
                      item: e,
                      onTap: () async {
                        await state.restoreToDescription(
                            description: e.description);
                        await Get.defaultDialog(
                            title: '',
                            middleText: 'To apply changes restart app');
                        Restart.restartApp(
                          notificationTitle: "Restart app",
                          notificationBody: "Restore backup",
                        );
                      }))
                  .toList(),
            ),
          ),
        ],
      );
    });
  }

  _createBackup(BackupState state) async {
    final description =
        await textInputDialogWidget(initName: '', title: 'Backup description');
    if (description != null) {
      state.createBackup(description: description);
    }
  }
}
