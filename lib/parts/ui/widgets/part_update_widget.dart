import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';

class PartUpdateWidget extends StatefulWidget {
  const PartUpdateWidget({super.key, required this.part});
  final Part part;

  @override
  State<PartUpdateWidget> createState() => _PartUpdateWidgetState();
}

class _PartUpdateWidgetState extends State<PartUpdateWidget> {
  late Part item;

  @override
  void initState() {
    item = widget.part;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Remarks field
          TextField(
            controller: TextEditingController(text: item.remarks),
            decoration: const InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              item = item.copyWith(remarks: value);
            },
          ),
          const SizedBox(height: 16),

          // Installation date field
          ListTile(
            title: const Text('Installation Date'),
            subtitle:
                Text(DateFormat("dd-MM-yyyy").format(item.installationRh.date)),
            leading: const Icon(Icons.calendar_today),
            onTap: () async {
              final selectedDate = item.installationRh.date;
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  final installationRh = item.installationRh;
                  item = item.copyWith(
                      installationRh: installationRh.copyWith(date: picked));
                });
              }
            },
          ),
          const SizedBox(height: 8),

          // Running hours field
          TextField(
            controller: TextEditingController(
                text: item.installationRh.value.toString()),
            decoration: const InputDecoration(
              labelText: 'Installation Running Hours',
              border: OutlineInputBorder(),
              suffixText: 'hours',
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final newRh = int.tryParse(value);
              if (newRh == null) return;
              item = item.copyWith(
                  installationRh: item.installationRh.copyWith(value: newRh));
            },
          ),
          const SizedBox(height: 24),

          // Check button
          IconButton(
            onPressed: () => Get.back(result: item),
            icon: const Icon(Icons.check),
            tooltip: 'Save',
          ),
        ],
      ),
    );
  }
}
