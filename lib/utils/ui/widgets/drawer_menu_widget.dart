import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_overview_widget.dart';
import 'package:part_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              onTap: () => _setAppDB(context)),
        ],
      ),
    );
  }

  _setAppDB(BuildContext context) async {
    final cont = context;
    final pref = Get.find<SharedPreferences>();
    final f = await FilePicker.platform
        .pickFiles(dialogTitle: 'Select db', allowedExtensions: ['db']);
    if (f != null) {
      final path = f.files.first.path;
      if (path != null) {
        pref.setString('dbPath', path);
        Get.defaultDialog(
            title: '', middleText: 'To apply changes restart app');
        if (cont.mounted) {
          RestartWidget.restartApp(cont);
        }
      }
    }
  }
}
