import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/di.dart';
import 'package:part_tracker/locations/ui/screens/locations_overview_screen.dart';
import 'package:part_tracker/utils/ui/widgets/db_select_dialog.dart';

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

  restartApp() async {
    await Get.deleteAll();
    Future.delayed(const Duration(seconds: 1));
    key = UniqueKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: FutureBuilder(
          future: initDependencies(),
          builder: (context, _) {
            final loaded = _.data;
            if (_.hasError) {
              final errString = _.error.toString();
              if (errString.contains('No db')) {
                setAppDB(context);
              }
              return Scaffold(body: Center(child: Text(errString)));
            }
            if (loaded == null || loaded == false) {
              return const MaterialApp(
                home:
                    Scaffold(body: Center(child: CircularProgressIndicator())),
              );
            }

            return GetMaterialApp(
              // debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.grey,
              ),
              home: const LocationsOverviewScreen(),
            );
          }),
    );
  }
}
