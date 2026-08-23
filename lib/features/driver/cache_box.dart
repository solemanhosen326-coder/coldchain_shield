import 'package:coldchain_shield/constants/app_constants.dart';
import 'package:hive/hive.dart';

class CacheBox {
  // ignore: non_constant_identifier_names
  final Box _locationBox = Hive.box(HiveBoxes.location);

  Future<void> addLocationToCache(Map<String, dynamic> data) async {
    await _locationBox.add(data);
  }

  List<Map<String, dynamic>> getCachedLocations() {
    return _locationBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearCache() async {
    await _locationBox.clear();
  }

  int getCachedPacketsCount() {
    return _locationBox.length;
  }
}
