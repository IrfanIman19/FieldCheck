import 'package:flutter_test/flutter_test.dart';

import 'package:fieldcheck2/utils/date_time_utils.dart';

void main() {
  test('formats time with AM/PM suffix', () {
    final value = DateTime(2024, 6, 7, 0, 5);

    expect(DateTimeUtils.formatShort(value), '07/06/2024 • 12:05 AM');
  });
}
