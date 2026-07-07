
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/check_in_provider.dart';
import '../widgets/info_row.dart';

class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Check-In'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture a field check-in',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a photo, note, and GPS location to complete your inspection record.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 22),
                if (provider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(child: Text(provider.errorMessage!)),
                        if (provider.errorMessage!.contains('denied') || provider.errorMessage!.contains('permission'))
                          TextButton(
                            onPressed: provider.openAppSettingsIfNeeded,
                            child: const Text('Settings'),
                          ),
                      ],
                    ),
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Required Note', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Describe the inspection or issue found',
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: provider.pickImage,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.selectedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              provider.selectedImage!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_camera_outlined, size: 42, color: AppColors.primary),
                                SizedBox(height: 8),
                                Text('Photo preview will appear here'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: provider.fetchCurrentLocation,
                            icon: provider.isFetchingLocation
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.my_location_rounded),
                            label: Text(provider.isFetchingLocation ? 'Fetching GPS…' : 'Get Location'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.currentPosition != null) ...[
                          const Text('Location Details', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          InfoRow(label: 'Latitude', value: provider.currentPosition!.latitude.toStringAsFixed(6)),
                          InfoRow(label: 'Longitude', value: provider.currentPosition!.longitude.toStringAsFixed(6)),
                          InfoRow(label: 'Accuracy', value: '${provider.currentPosition!.accuracy.toStringAsFixed(2)} m'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await provider.saveCheckIn(note: _noteController.text);
                      if (!mounted) return;
                      if (provider.errorMessage == null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Check-in saved successfully.')),
                        );
                      }
                    },
                    child: const Text('Save Check-In'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
