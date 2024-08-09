import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/di.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen_mobile.dart';
import 'package:part_tracker/utils/ui/widgets/db_select_dialog.dart';

void main() async {
  runApp(const RestartWidget());
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  restartApp() async {
    await Get.deleteAll();
    Future.delayed(const Duration(seconds: 1));
    key = UniqueKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: key,
        future: initDependencies(),
        builder: (context, r) {
          Widget child = const Center(child: CircularProgressIndicator());
          final loaded = r.data;
          if (r.hasError) {
            final errString = r.error.toString();
            if (errString.contains('No db')) {
              setAppDB(context);
            }
            child = Scaffold(body: Center(child: Text(errString)));
          }
          if (loaded != null && loaded == true) {
            if (Platform.isLinux) {
              child = const LocationsOverviewScreen();
            }
            if (Platform.isAndroid) {
              child = const LocationsOverviewScreenMobile();
            }
          }

          return KeyedSubtree(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,

              theme: ThemeData(
                primarySwatch: Colors.grey,
              ),
              home: const LocationsOverviewScreen(),
            );
          }),
    );
  }
}
