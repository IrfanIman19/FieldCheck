import 'dart:io';

class CheckIn {
  final String id;
  final File? photo;
  final String note;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.photo,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });
}
