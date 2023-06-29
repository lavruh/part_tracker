import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/logbook/ui/widgets/logbook_overview_widget.dart';

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
        ],
      ),
    );
  }
}
