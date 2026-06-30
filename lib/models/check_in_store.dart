import 'package:flutter/foundation.dart';
import '../models/check_in.dart';

class CheckInStore extends ChangeNotifier {
  final List<CheckIn> _checkIns = [];

  List<CheckIn> get all => List.unmodifiable(_checkIns);

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

  void add(CheckIn checkIn) {
    _checkIns.add(checkIn);
    notifyListeners();
  }
}
