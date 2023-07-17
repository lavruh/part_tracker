import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/di.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen.dart';

void main() async {
  runApp(const RestartWidget());
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    Get.deleteAll();
    key = UniqueKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: key,
        future: initDependencies(),
        builder: (context, _) {
          Widget child = const Center(child: CircularProgressIndicator());
          final loaded = _.data;
          if (_.hasError) {
            final errString = _.error.toString();
            child = Scaffold(body: Center(child: Text(errString)));
          }
          if (loaded != null && loaded == true) {
            child = const LocationsOverviewScreen();
          }

          return KeyedSubtree(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.grey,
              ),
              home: child,
            ),
          );
        });
  }
}
