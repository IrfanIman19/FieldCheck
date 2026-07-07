import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import '../providers/check_in_provider.dart';
import '../utils/date_time_utils.dart';
import '../widgets/empty_state_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('FieldCheck'),
            actions: [
              IconButton(
                onPressed: provider.loadCheckIns,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.loadCheckIns,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.checkIns.isEmpty
                    ? const EmptyStateCard(
                        title: 'No check-ins yet',
                        subtitle: 'Tap the + button to add your first check-in.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: provider.checkIns.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final checkIn = provider.checkIns[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.detail,
                                arguments: checkIn,
                              );
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        File(checkIn.imagePath),
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Container(
                                          width: 84,
                                          height: 84,
                                          color: AppColors.border,
                                          child: const Icon(Icons.broken_image_outlined),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            checkIn.note.isEmpty ? 'Untitled check-in' : checkIn.note,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            DateTimeUtils.formatShort(checkIn.createdAt),
                                            style: const TextStyle(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondary),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${checkIn.latitude.toStringAsFixed(4)}, ${checkIn.longitude.toStringAsFixed(4)}',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newCheckIn),
            icon: const Icon(Icons.add),
            label: const Text('New Check-In'),
          ),
        );
      },
    );
  }

}
