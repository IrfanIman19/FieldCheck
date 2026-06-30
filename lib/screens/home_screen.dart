import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';
import '../models/check_in.dart';
import '../models/check_in_store.dart';
import 'new_check_in_screen.dart';
import 'check_in_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  void _pickDate() async {
    final store = context.read<CheckInStore>();
    DateTime focused = _selectedDate;
    DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        DateTime tempSelected = _selectedDate;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(8),
              content: SizedBox(
                width: 320,
                child: TableCalendar(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime(2030, 12, 31),
                  focusedDay: focused,
                  selectedDayPredicate: (day) => isSameDay(day, tempSelected),
                  onDaySelected: (selected, focusedDay) {
                    setStateDialog(() {
                      tempSelected = selected;
                      focused = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    final d = DateTime(day.year, day.month, day.day);
                    return store.datesWithCheckIns.contains(d) ? [1] : [];
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: fieldCheckRed,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: fieldCheckRed.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: fieldCheckRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: fieldCheckRed),
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CheckInStore>();
    final items = store.forDate(_selectedDate);
    final dateLabel = DateFormat('d MMMM yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldCheck'),
        actions: [
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 16, color: fieldCheckRed),
            label: Text(dateLabel, style: const TextStyle(color: fieldCheckRed)),
          ),
        ],
      ),
      body: items.isEmpty ? _buildEmptyState() : _buildList(items),
      floatingActionButton: FloatingActionButton(
        backgroundColor: fieldCheckRed,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewCheckInScreen()),
          );
          setState(() {});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.close, color: Colors.grey.shade400, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Check-In yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first check-in',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<CheckIn> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CheckInDetailScreen(checkIn: item)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.photo != null
                      ? Image.file(item.photo!, width: 64, height: 64, fit: BoxFit.cover)
                      : Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.note.isEmpty ? '(No note)' : item.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('h:mm a').format(item.createdAt),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        );
      },
    );
  }
}
