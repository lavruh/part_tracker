DateTime fromDynamic(dynamic map) {
  DateTime? d = DateTime.now();
  if (map != null) {
    d = DateTime.tryParse(map.toString());
    d ??= DateTime.fromMillisecondsSinceEpoch(map);
  }
  return d;
}
