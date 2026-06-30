import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/check_in.dart';
import '../models/check_in_store.dart';

class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final _noteController = TextEditingController();
  File? _photo;
  bool _fetchingLocation = false;
  Position? _position;
  String? _locationError;

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (picked != null) {
        setState(() => _photo = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not capture photo: $e')));
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _fetchingLocation = true;
      _locationError = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _save() async {
    final store = context.read<CheckInStore>();
    store.add(CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      photo: _photo,
      note: _noteController.text.trim(),
      latitude: _position?.latitude,
      longitude: _position?.longitude,
      accuracy: _position?.accuracy,
      createdAt: DateTime.now(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Check-In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Note', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: fieldCheckRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: _photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Center(
                      child: Text('IMG / X', style: TextStyle(color: Colors.grey.shade400)),
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchingLocation ? null : _getLocation,
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('Get Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: fieldCheckRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _fetchingLocation
                  ? Row(
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: fieldCheckRed),
                        ),
                        SizedBox(width: 8),
                        Text('fetching...'),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latitude: ${_position?.latitude.toStringAsFixed(6) ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Longitude: ${_position?.longitude.toStringAsFixed(6) ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('Accuracy: ${_position != null ? '${_position!.accuracy.toStringAsFixed(1)} m' : '-'}'),
                        if (_locationError != null) ...[
                          const SizedBox(height: 6),
                          Text(_locationError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EBD63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
