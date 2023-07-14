import 'package:flutter/material.dart';

class PartsHeaderWidget extends StatelessWidget {
  const PartsHeaderWidget({Key? key}) : super(key: key);
  static const style = TextStyle(fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
                child: const Text('RH @ Location:', style: style)),
            const Flexible(
              child: Text('Remarks:',
                  style: style, overflow: TextOverflow.fade),
            ),
          ],
        ),
      ),
    );
  }
}
