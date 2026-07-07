import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/check_in.dart';

class StorageService {
  StorageService();

  static const String _boxName = 'check_ins';

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CheckInAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<CheckIn>(_boxName);
    }
  }

  Future<Box<CheckIn>> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<CheckIn>(_boxName);
    }
    return Hive.box<CheckIn>(_boxName);
  }

  Future<List<CheckIn>> getAll() async {
    final box = await _box();
    return box.values.toList().cast<CheckIn>();
  }

  Future<void> save(CheckIn checkIn) async {
    final box = await _box();
    await box.put(checkIn.id, checkIn);
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}
