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
    return Drawer(
      child: ListView(
        children: [
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
