import 'package:get/get.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartsManagerState extends GetxController {
  final parts = <UniqueId, Part>{}.obs;

  addPart() {}
  updatePart(Part part) {}
  deletePart(UniqueId part) {}
  getParts() {}
}
