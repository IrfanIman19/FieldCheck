class DateTimeUtils {
  DateTimeUtils._();

  static String formatShort(DateTime value) {
    final hour = value.hour % 12;
    final normalizedHour = hour == 0 ? 12 : hour;
    final suffix = value.hour < 12 ? 'AM' : 'PM';

    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} • ${normalizedHour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')} $suffix';
  }
}
