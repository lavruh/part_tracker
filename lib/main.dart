import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/di.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen_mobile.dart';
import 'package:part_tracker/utils/ui/widgets/db_select_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    Future.delayed(const Duration(seconds: 3));
    key = UniqueKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.grey),
        home: MainScreenLoader(
          key: key,
        ));
  }
}

class MainScreenLoader extends StatelessWidget {
  const MainScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: key,
        future: initDependencies(),
        builder: (context, r) {
          final loaded = r.data;
          if (r.hasError) {
            final errString = r.error.toString();
            if (errString.contains('No db')) {
              Timer(const Duration(seconds: 1), () {
                //Should run after build
                setAppDB(context);
              });
            }
            return Scaffold(body: Center(child: Text(errString)));
          }
          if (loaded != null && loaded == true) {
            if (Platform.isLinux) {
              return const LocationsOverviewScreen();
            }
            if (Platform.isAndroid) {
              return const LocationsOverviewScreenMobile();
            }
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        });
  }
}
