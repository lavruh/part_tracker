import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:part_tracker/backup/domain/entities/backup_item.dart';

class BackupItemWidget extends StatelessWidget {
  const BackupItemWidget({Key? key, required this.item, required this.onTap})
      : super(key: key);

  final BackupItem item;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(DateFormat('yyyy-MM-dd hh:mm').format(item.date)),
      title: Text(item.description),
      onTap: onTap,
    );
  }
}
