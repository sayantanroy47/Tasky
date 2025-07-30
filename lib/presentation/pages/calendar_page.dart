import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';

/// Calendar page for viewing tasks in calendar format
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Calendar',
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            // TODO: Navigate to today
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Navigate to today coming soon!')),
            );
          },
          tooltip: 'Go to today',
        ),
        IconButton(
          icon: const Icon(Icons.view_module),
          onPressed: () {
            // TODO: Change calendar view
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calendar view options coming soon!')),
            );
          },
          tooltip: 'Change view',
        ),
      ],
      body: const CalendarPageBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add scheduled task
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule task functionality coming soon!')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Schedule task',
      ),
    );
  }
}

/// Calendar page body content
class CalendarPageBody extends ConsumerWidget {
  const CalendarPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar view selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'January 2024',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'month', label: Text('Month')),
                      ButtonSegment(value: 'week', label: Text('Week')),
                      ButtonSegment(value: 'day', label: Text('Day')),
                    ],
                    selected: {'month'},
                    onSelectionChanged: (selection) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${selection.first} view coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Calendar grid placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Week days header
                  Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Calendar days grid
                  ...List.generate(5, (weekIndex) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: List.generate(7, (dayIndex) {
                        final dayNumber = weekIndex * 7 + dayIndex + 1;
                        final hasTask = dayNumber % 3 == 0;
                        final isToday = dayNumber == 15;
                        
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected day $dayNumber'),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isToday 
                                  ? Theme.of(context).colorScheme.primary
                                  : hasTask 
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                border: hasTask && !isToday
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 1,
                                    )
                                  : null,
                              ),
                              child: Center(
                                child: Text(
                                  dayNumber <= 31 ? dayNumber.toString() : '',
                                  style: TextStyle(
                                    color: isToday 
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : hasTask
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : null,
                                    fontWeight: isToday || hasTask 
                                      ? FontWeight.bold 
                                      : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Today's tasks
          Text(
            'Today\'s Tasks',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          
          ...List.generate(3, (index) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                ][index],
                child: Text(
                  '${index + 9}:00',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('Scheduled Task ${index + 1}'),
              subtitle: Text('Task scheduled for ${index + 9}:00 AM'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task options coming soon!')),
                  );
                },
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task details coming soon!')),
                );
              },
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Calendar legend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legend',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Today'),
                      const SizedBox(width: 24),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Has Tasks'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}