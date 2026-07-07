import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CheckIn extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String note;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final double accuracy;

  @HiveField(6)
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.note,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      note: json['note'] as String,
      imagePath: json['imagePath'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 0;

  @override
  CheckIn read(BinaryReader reader) {
    return CheckIn(
      id: reader.readString(),
      note: reader.readString(),
      imagePath: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      accuracy: reader.readDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.note);
    writer.writeString(obj.imagePath);
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
    writer.writeDouble(obj.accuracy);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
