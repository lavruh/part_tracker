import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:part_tracker/locations/domain/locations_manager_state.dart';
import 'package:part_tracker/part_types/domain/entities/part_type.dart';
import 'package:part_tracker/part_types/domain/part_types_state.dart';
import 'package:part_tracker/parts/domain/entities/part.dart';
import 'package:part_tracker/parts/domain/parts_manager_state.dart';
import 'package:part_tracker/parts/ui/widgets/part_editor_widget.dart';
import 'package:part_tracker/utils/domain/unique_id.dart';

class PartEditorState extends GetxController {
  final _part = <Part>[].obs;
  final _changed = false.obs;
  final _partType = <UniqueId, int?>{}.obs;
  final formKey = GlobalKey<FormState>();

  setPart(Part? p) {
    if (p != null) {
      _part.value = [p];
    } else {
      _part.clear();
    }
    _changed.value = false;
  }

  Map<UniqueId, int?> get partType {
    if (_partType.entries.length == 1) {
      return _partType;
    }
    return {};
  }

  updatePartType(Map<UniqueId, int?> map) {
    if (map.isEmpty) {
      _partType.clear();
    } else if (map.entries.length < 2) {
      _partType.value = map;
    } else {
      final e = map.entries.last;
      _partType.value = {e.key: e.value};
    }
    _changed.value = true;
  }

  Part? get part => _part[0];
  bool get isSet => _part.isNotEmpty;
  bool get isChanged => _changed.value;
  String get partNo => part?.partNo.id ?? '';
  String get remarks => part?.remarks ?? '';
  String get runningHours => part?.runningHours.value.toString() ?? '0';

  openEditor() {
    setPart(Part.newPart(partNo: UniqueId(), type: PartType.empty()));
    Get.defaultDialog(title: 'New part', content: const PartEditorWidget());
  }

  updatePart(Part p) {
    _part.value = [p];
    _changed.value = true;
  }

  bool partWithSameNumberExists(String partNo) {
    final parts = Get.find<PartsManagerState>().getPartWithIds([UniqueId(id: partNo)]);
    if(parts.isNotEmpty){
      return true;
    }
    return false;
  }

  bool validate() {
    if (formKey.currentState!.validate()) {
      // validate part type
      if (partType.keys.isEmpty) {
        Get.defaultDialog(middleText: 'Please select part type.');
        return false;
      }
      final pT = Get.find<PartTypesState>().types[partType.keys.first];
      if (pT == null) {
        Get.defaultDialog(middleText: 'Please select correct part type.');
        return false;
      }
      _part.value = [part!.copyWith(type: pT)];
      return true;
    }
    return false;
  }

  save() async {
    if (validate()) {
      final p = part;
      if (p != null) {
        await Get.find<PartsManagerState>().updatePart(p);
        Get.find<LocationManagerState>()
            .moveNewPartToSelectedLocation(partId: p.partNo);
        _changed.value = false;
        _partType.clear();
        Get.back();
      }
    }
  }
}
