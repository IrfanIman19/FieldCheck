import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'check_in.dart';

/// Persists check-ins to disk (SharedPreferences) so history survives
/// app restarts, not just in-session navigation.
class CheckInStore extends ChangeNotifier {
  static const _storageKey = 'fieldcheck_checkins';

  final List<CheckIn> _checkIns = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<CheckIn> get all => List.unmodifiable(_checkIns);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        _checkIns
          ..clear()
          ..addAll(decoded.map((e) => CheckIn.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {
      // If stored data is ever corrupted, fail safe with an empty list
      // rather than crashing the app on launch.
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_checkIns.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Persistence failure shouldn't crash the app; the check-in
      // still exists in memory for this session.
    }
  }

  List<CheckIn> forDate(DateTime date) {
    return _checkIns.where((c) =>
        c.createdAt.year == date.year &&
        c.createdAt.month == date.month &&
        c.createdAt.day == date.day).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Set<DateTime> get datesWithCheckIns => _checkIns
      .map((c) => DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day))
      .toSet();

  Future<void> add(CheckIn checkIn) async {
    _checkIns.add(checkIn);
    notifyListeners();
    await _persist();
  }
}
