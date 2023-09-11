import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/backup/ui/screens/backups_dialog.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_overview_widget.dart';
import 'package:part_tracker/utils/ui/widgets/db_select_dialog.dart';

class DrawerMenuWidget extends StatelessWidget {
  const DrawerMenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final v = Get.find<String>(tag: 'version');
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text("Part Tracker   v:$v"),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showAboutDialog(
                    context: context,
                    applicationName: 'Part Tracker',
                    applicationVersion: v,
                    applicationLegalese:
                        'Source code and latest version check at \nhttps://github.com/lavruh/part_tracker');
              },
            ),
          ),
          ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Logbook'),
              onTap: () {
                Get.defaultDialog(
                    title: 'Logbook', content: const LogBookOverviewWidget());
              }),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Set app db file'),
              onTap: () => setAppDB(context)),
          ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backups'),
              onTap: () {
                Get.defaultDialog(
                    title: 'Backups', content: const BackupsDialogWidget());
              }),
        ],
      ),
    );
  }
}
