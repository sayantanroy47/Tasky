import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar_widgets.dart';
import '../providers/calendar_provider.dart';
import '../../domain/entities/calendar_event.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';

/// Calendar page for viewing tasks in calendar format
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Modern app bar with gradient and elevated style
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              title: Text(
                'Calendar',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.today_outlined),
                onPressed: () {
                  calendarNotifier.goToToday();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Navigated to today'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                    ),
                  );
                },
                tooltip: 'Go to today',
              ),
              IconButton(
                icon: const Icon(Icons.event_note_outlined),
                onPressed: () => _showCreateEventDialog(context, ref),
                tooltip: 'Create event',
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Calendar content
          const SliverToBoxAdapter(
            child: CalendarWidget(),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateEventDialog(),
    );
  }
}

/// Create event dialog
class _CreateEventDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends ConsumerState<_CreateEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  bool isAllDay = false;
  String selectedColor = '#2196F3';
  
  final List<String> colors = [
    '#2196F3', // Blue
    '#4CAF50', // Green  
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
            
            // All day toggle
            SwitchListTile(
              title: const Text('All Day'),
              value: isAllDay,
              onChanged: (value) => setState(() => isAllDay = value),
            ),
            
            if (!isAllDay) ...[
              // Start time picker
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Start Time'),
                subtitle: Text(startTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (time != null) {
                    setState(() => startTime = time);
                  }
                },
              ),
              
              // End time picker
              ListTile(
                leading: const Icon(Icons.access_time_filled),
                title: const Text('End Time'),
                subtitle: Text(endTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (time != null) {
                    setState(() => endTime = time);
                  }
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Color picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isEmpty
              ? null
              : () async {
                  await _createEvent();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createEvent() async {
    final calendarNotifier = ref.read(calendarProvider.notifier);
    
    final DateTime startDateTime;
    final DateTime endDateTime;

    if (isAllDay) {
      startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      endDateTime = startDateTime.add(const Duration(days: 1));
    } else {
      startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );
      endDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );
    }

    final event = CalendarEvent.create(
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      isAllDay: isAllDay,
      color: selectedColor,
    );

    await calendarNotifier.addEvent(event);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
    }
  }
}