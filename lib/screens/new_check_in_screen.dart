import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/check_in.dart';
import '../models/check_in_store.dart';

enum LocationState { idle, fetching, success, deniedOnce, deniedForever, error, serviceDisabled }

class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final _noteController = TextEditingController();
  String? _photoPath;
  Position? _position;
  LocationState _locationState = LocationState.idle;
  bool _saving = false;

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (picked == null) return; // user cancelled — no crash, just no-op

      // Copy into permanent app storage so the file survives even if the
      // OS clears temp/cache directories between sessions.
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docsDir.path}/fieldcheck_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      final fileName = 'checkin_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(picked.path).copy('${photosDir.path}/$fileName');

      if (mounted) setState(() => _photoPath = savedFile.path);
    } catch (e) {
      // Camera unavailable / permission denied — never crash, just inform.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture photo: ${_friendlyError(e)}')),
        );
      }
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    return msg.length > 120 ? '${msg.substring(0, 120)}...' : msg;
  }

  Future<void> _getLocation() async {
    setState(() => _locationState = LocationState.fetching);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationState = LocationState.serviceDisabled);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        // User explicitly tapped "Deny" — app continues normally.
        setState(() => _locationState = LocationState.deniedOnce);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        // User denied with "Don't ask again" — needs Settings to re-enable.
        setState(() => _locationState = LocationState.deniedForever);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _position = pos;
        _locationState = LocationState.success;
      });
    } catch (_) {
      // Any other failure (timeout, hardware issue, etc.) — fail safe.
      setState(() => _locationState = LocationState.error);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final store = context.read<CheckInStore>();
    await store.add(CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      photoPath: _photoPath,
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
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _photoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(_photoPath!), fit: BoxFit.cover, width: double.infinity),
                    )
                  : Center(
                      child: Text('IMG / X', style: TextStyle(color: Colors.grey.shade400)),
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _locationState == LocationState.fetching ? null : _getLocation,
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
            _buildLocationCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EBD63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    Widget content;
    switch (_locationState) {
      case LocationState.idle:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Latitude: -'),
            SizedBox(height: 4),
            Text('Longitude: -'),
            SizedBox(height: 4),
            Text('Accuracy: -'),
          ],
        );
        break;
      case LocationState.fetching:
        content = Row(
          children: const [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: fieldCheckRed),
            ),
            SizedBox(width: 8),
            Text('fetching...'),
          ],
        );
        break;
      case LocationState.success:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${_position!.latitude.toStringAsFixed(6)}'),
            const SizedBox(height: 4),
            Text('Longitude: ${_position!.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 4),
            Text('Accuracy: ${_position!.accuracy.toStringAsFixed(1)} m'),
          ],
        );
        break;
      case LocationState.deniedOnce:
        content = Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Location permission denied. You can still save this check-in without coordinates, or tap "Get Location" to try again.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        );
        break;
      case LocationState.deniedForever:
        content = Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Location permission permanently denied. Enable it from system Settings to attach coordinates, or save without location.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        );
        break;
      case LocationState.serviceDisabled:
        content = Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Location services are turned off on this device. Turn them on to attach coordinates, or save without location.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        );
        break;
      case LocationState.error:
        content = Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Could not fetch location right now. You can save without it, or try again.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: content,
    );
  }
}
