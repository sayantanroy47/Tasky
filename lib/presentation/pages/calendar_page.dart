import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/enhanced_calendar_widget.dart';
import '../providers/enhanced_calendar_provider.dart';
import '../../domain/entities/calendar_event.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Calendar page for viewing tasks in calendar format
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(enhancedCalendarProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: StandardizedAppBar(
        title: 'Calendar',
        forceBackButton: false,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise()),
            onPressed: () {
              ref.read(enhancedCalendarProvider.notifier).refresh();
            },
            tooltip: 'Refresh Calendar',
          ),
          IconButton(
            icon: Icon(
              calendarState.isLoading ? PhosphorIcons.arrowsClockwise() : PhosphorIcons.calendar(),
            ),
            onPressed: () {
              ref.read(enhancedCalendarProvider.notifier).goToToday();
            },
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: SpacingTokens.xs, // Minimal top padding (4px)
            left: SpacingTokens.sm, // Standard horizontal padding (8px)
            right: SpacingTokens.sm,
            bottom: SpacingTokens.xs, // Minimal bottom padding (4px)
          ),
          child: calendarState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : calendarState.errorMessage != null
                  ? _buildErrorWidget(context, ref, calendarState.errorMessage!)
                  : GlassmorphismContainer(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      padding: const EdgeInsets.all(SpacingTokens.sm), // Standard padding (8px)
                      child: const EnhancedCalendarWidget(),
                    ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: SpacingTokens.md), // 16px
          Text(
            'Calendar Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm), // 8px
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.md), // 16px
          ElevatedButton(
            onPressed: () {
              ref.read(enhancedCalendarProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
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
            const SizedBox(height: SpacingTokens.md), // 16px
            
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: SpacingTokens.md), // 16px
            
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: SpacingTokens.md), // 16px
            
            // Date picker
            ListTile(
              leading: Icon(PhosphorIcons.calendar()),
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
                leading: Icon(PhosphorIcons.clock()),
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
                leading: Icon(PhosphorIcons.clock()),
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
            
            const SizedBox(height: SpacingTokens.md), // 16px
            
            // Color picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: SpacingTokens.sm), // 8px
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
                            ? Icon(PhosphorIcons.check(), color: Colors.white)
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
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createEvent() async {
    final calendarNotifier = ref.read(enhancedCalendarProvider.notifier);
    
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

