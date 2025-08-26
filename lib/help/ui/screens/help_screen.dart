import 'dart:io';

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final tocController = TocController();

  Widget buildTocWidget() => TocWidget(controller: tocController);

  @override
  Widget build(BuildContext context) {
    final tocController = TocController();

    Widget buildTocWidget() => TocWidget(controller: tocController);

    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: FutureBuilder(
        future:
            DefaultAssetBundle.of(context).loadString('assets/help/help.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          if (snapshot.hasData) {
            final data = snapshot.data;
            if (data == null) return Text('...');
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  if (!Platform.isAndroid) Expanded(child: buildTocWidget()),
                  Expanded(
                    flex: 3,
                    child: MarkdownWidget(
                      tocController: tocController,
                      data: data,
                    ),
                  ),
                ],
              ),
            );
          }
          return Text('...');
        },
      ),
    );
  }
}
