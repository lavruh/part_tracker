import 'dart:io';

import 'package:flutter/material.dart';

class PartsHeaderWidget extends StatelessWidget {
  const PartsHeaderWidget({super.key});
  static const style = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    Widget child = _headerDesktop();
    if (Platform.isAndroid) child = _headerMobile();
    return child;
  }

  Widget _headerDesktop() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 125),
              child: const Text('', style: style)),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 125),
              child: const Text('PartNo.', style: style)),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 75),
              child: const Text('RH Total:', style: style)),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 75),
              child: const Text('RH     @\n Location:', style: style)),
          const Text('Remarks:', style: style, overflow: TextOverflow.fade),
        ],
      ),
    );
  }

  Widget _headerMobile() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
        children: [
          Flexible(flex: 4, child: Container()),
          const Flexible(child: Text('RH Total:', style: style)),
          const Flexible(child: Text('RH     @\nLocation:', style: style)),
        ],
      ),
    );
  }
}
