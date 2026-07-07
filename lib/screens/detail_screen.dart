import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../models/check_in.dart';
import '../utils/date_time_utils.dart';
import '../widgets/info_row.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.checkIn});

  final CheckIn checkIn;

  Future<void> _copyValue(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _copyCoordinates(BuildContext context) async {
    final coords = '${checkIn.latitude.toStringAsFixed(6)}, ${checkIn.longitude.toStringAsFixed(6)}';
    await Clipboard.setData(ClipboardData(text: coords));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordinates copied. Paste them into Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(checkIn.imagePath),
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: double.infinity,
                  height: 260,
                  color: AppColors.border,
                  child: const Center(child: Icon(Icons.broken_image_outlined, size: 42)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Note', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(checkIn.note, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                    const SizedBox(height: 16),
                    const Text('Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _copyValue(context, checkIn.latitude.toStringAsFixed(6)),
                      child: InfoRow(label: 'Latitude', value: checkIn.latitude.toStringAsFixed(6)),
                    ),
                    GestureDetector(
                      onTap: () => _copyValue(context, checkIn.longitude.toStringAsFixed(6)),
                      child: InfoRow(label: 'Longitude', value: checkIn.longitude.toStringAsFixed(6)),
                    ),
                    InfoRow(label: 'Accuracy', value: '${checkIn.accuracy.toStringAsFixed(2)} m'),
                    InfoRow(label: 'Created At', value: DateTimeUtils.formatShort(checkIn.createdAt)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _copyCoordinates(context),
                        icon: const Icon(Icons.copy_all_rounded),
                        label: const Text('Copy coordinates for Google Maps'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
