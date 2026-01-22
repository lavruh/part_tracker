import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/di.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen_mobile.dart';
import 'package:part_tracker/utils/data/db_lock_manager.dart';
import 'package:part_tracker/utils/ui/widgets/db_select_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await isPermissionsGranted() == false) return;

  if (!Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.maximize();
      await windowManager.focus();
    });
    final customWindowListener = CustomWindowListener();
    windowManager.addListener(customWindowListener);
  }
  runApp(GetMaterialApp(
    theme: ThemeData(primarySwatch: Colors.grey),
    home: const MainScreenLoader(),
  ));
}

class MainScreenLoader extends StatefulWidget {
  const MainScreenLoader({super.key});

  @override
  State<MainScreenLoader> createState() => _MainScreenLoaderState();
}

class _MainScreenLoaderState extends State<MainScreenLoader> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onDetach: () => Get.find<DBLockManager>().removeLock(),
      onRestart: () => Get.find<DBLockManager>().removeLock(),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: widget.key,
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
            return Scaffold(
                body: Center(
                    child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errString),
                TextButton(
                    onPressed: () => setAppDB(context), child: Text("Set db")),
              ],
            )));
          }
          if (loaded != null && loaded == true) {
            if (Platform.isLinux || Platform.isWindows) {
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

Future<bool> isPermissionsGranted() async {
  bool fl = true;
  if (Platform.isWindows || Platform.isLinux) return true;
  if (fl && await Permission.manageExternalStorage.status.isDenied) {
    fl = await Permission.manageExternalStorage.request().isGranted;
  }
  return fl;
}

class CustomWindowListener extends WindowListener {
  @override
  void onWindowClose() => Get.find<DBLockManager>().removeLock();
}
