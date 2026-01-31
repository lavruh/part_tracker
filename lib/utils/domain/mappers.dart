import 'package:part_tracker/utils/domain/unique_id.dart';

List<UniqueId> mapUniqueIdList(Object? m){
  if(m == null) return [];
  return (m as List).map((e) => UniqueId.fromMap(e)).toList();
}
