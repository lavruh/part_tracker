import 'package:flutter/material.dart';

class LocationsMenuBarWidget extends StatelessWidget {
  const LocationsMenuBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.edit), tooltip: 'Edit'),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.copy),
              tooltip: 'Duplicate'),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
              tooltip: 'Add child'),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete),
              tooltip: 'Delete'),
        ],
      ),
    );
  }
}
