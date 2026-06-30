import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/check_in.dart';

class CheckInDetailScreen extends StatelessWidget {
  final CheckIn checkIn;
  const CheckInDetailScreen({super.key, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: checkIn.photo != null
                  ? Image.file(checkIn.photo!, width: double.infinity, height: 180, fit: BoxFit.cover)
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('Note', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(checkIn.note.isEmpty ? '(No note)' : checkIn.note),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _detailRow('Latitude', checkIn.latitude?.toStringAsFixed(6) ?? '-'),
            _detailRow('Longitude', checkIn.longitude?.toStringAsFixed(6) ?? '-'),
            _detailRow('Accuracy', checkIn.accuracy != null ? '${checkIn.accuracy!.toStringAsFixed(1)} m' : '-'),
            _detailRow('Created At', DateFormat('d MMM yyyy, h:mm a').format(checkIn.createdAt)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE6332A),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
