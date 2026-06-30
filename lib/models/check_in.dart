import 'dart:io';

class CheckIn {
  final String id;
  final String? photoPath;
  final String note;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.photoPath,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });

  File? get photo => photoPath != null ? File(photoPath!) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'photoPath': photoPath,
        'note': note,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
        id: json['id'] as String,
        photoPath: json['photoPath'] as String?,
        note: json['note'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
