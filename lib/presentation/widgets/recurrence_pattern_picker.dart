import 'package:flutter/material.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/entities/task_enums.dart';

/// Widget for configuring recurrence patterns
class RecurrencePatternPicker extends StatefulWidget {
  final RecurrencePattern? initialPattern;
  final ValueChanged<RecurrencePattern?> onPatternChanged;

  const RecurrencePatternPicker({
    super.key,
    this.initialPattern,
    required this.onPatternChanged,
  });

  @override
  State<RecurrencePatternPicker> createState() => _RecurrencePatternPickerState();
}

class _RecurrencePatternPickerState extends State<RecurrencePatternPicker> {
  RecurrenceType _selectedType = RecurrenceType.none;
  int _interval = 1;
  List<int> _selectedDays = [];
  DateTime? _endDate;
  int? _maxOccurrences;

  @override
  void initState() {
    super.initState();
    if (widget.initialPattern != null) {
      _selectedType = widget.initialPattern!.type;
      _interval = widget.initialPattern!.interval;
      _selectedDays = widget.initialPattern!.daysOfWeek ?? [];
      _endDate = widget.initialPattern!.endDate;
      _maxOccurrences = widget.initialPattern!.maxOccurrences;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurrence Pattern',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        
        // Recurrence type selection
        _buildRecurrenceTypeSelector(),
        
        if (_selectedType != RecurrenceType.none) ...[
          const SizedBox(height: 16),
          _buildIntervalSelector(),
          
          if (_selectedType == RecurrenceType.weekly) ...[
            const SizedBox(height: 16),
            _buildWeekdaySelector(),
          ],
          
          if (_selectedType == RecurrenceType.monthly) ...[
            const SizedBox(height: 16),
            _buildMonthlyDaySelector(),
          ],
          
          const SizedBox(height: 16),
          _buildEndConditionSelector(),
        ],
      ],
    );
  }

  Widget _buildRecurrenceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          value: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: RecurrenceType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              _updatePattern();
            });
          },
        ),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    String label;
    switch (_selectedType) {
      case RecurrenceType.daily:
        label = 'Every _ day(s)';
        break;
      case RecurrenceType.weekly:
        label = 'Every _ week(s)';
        break;
      case RecurrenceType.monthly:
        label = 'Every _ month(s)';
        break;
      case RecurrenceType.yearly:
        label = 'Every _ year(s)';
        break;
      default:
        label = 'Interval';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.replaceAll('_', _interval.toString()),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _interval.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: _interval.toString(),
                onChanged: (value) {
                  setState(() {
                    _interval = value.round();
                    _updatePattern();
                  });
                },
              ),
            ),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _interval.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0 && intValue <= 365) {
                    setState(() {
                      _interval = intValue;
                      _updatePattern();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat on',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedDays.contains(dayNumber);
            
            return FilterChip(
              label: Text(weekdays[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayNumber);
                  } else {
                    _selectedDays.remove(dayNumber);
                  }
                  _selectedDays.sort();
                  _updatePattern();
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlyDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat on day(s) of month',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(31, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedDays.contains(dayNumber);
            
            return FilterChip(
              label: Text(dayNumber.toString()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayNumber);
                  } else {
                    _selectedDays.remove(dayNumber);
                  }
                  _selectedDays.sort();
                  _updatePattern();
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEndConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'End Condition',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        
        // Never ends option
        RadioListTile<String>(
          title: const Text('Never'),
          value: 'never',
          groupValue: _getEndConditionValue(),
          onChanged: (value) {
            setState(() {
              _endDate = null;
              _maxOccurrences = null;
              _updatePattern();
            });
          },
        ),
        
        // End date option
        RadioListTile<String>(
          title: const Text('On date'),
          value: 'date',
          groupValue: _getEndConditionValue(),
          onChanged: (value) {
            setState(() {
              _endDate = DateTime.now().add(const Duration(days: 30));
              _maxOccurrences = null;
              _updatePattern();
            });
          },
        ),
        
        if (_endDate != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: InkWell(
              onTap: () => _selectEndDate(),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                ),
              ),
            ),
          ),
        ],
        
        // Max occurrences option
        RadioListTile<String>(
          title: const Text('After number of occurrences'),
          value: 'count',
          groupValue: _getEndConditionValue(),
          onChanged: (value) {
            setState(() {
              _endDate = null;
              _maxOccurrences = 10;
              _updatePattern();
            });
          },
        ),
        
        if (_maxOccurrences != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _maxOccurrences.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Count',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0) {
                    setState(() {
                      _maxOccurrences = intValue;
                      _updatePattern();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getEndConditionValue() {
    if (_endDate != null) return 'date';
    if (_maxOccurrences != null) return 'count';
    return 'never';
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
        _updatePattern();
      });
    }
  }

  void _updatePattern() {
    RecurrencePattern? pattern;
    
    if (_selectedType != RecurrenceType.none) {
      pattern = RecurrencePattern(
        type: _selectedType,
        interval: _interval,
        daysOfWeek: _selectedDays.isEmpty ? null : _selectedDays,
        endDate: _endDate,
        maxOccurrences: _maxOccurrences,
      );
    }
    
    widget.onPatternChanged(pattern);
  }
}