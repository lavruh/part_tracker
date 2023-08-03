import 'package:flutter/material.dart';

class PartsHeaderWidget extends StatelessWidget {
  const PartsHeaderWidget({Key? key}) : super(key: key);
  static const style = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
}
