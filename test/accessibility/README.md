# Project Management Accessibility Test Suite

This comprehensive test suite ensures that all project management features in the Tasky Flutter app meet WCAG 2.1 AA accessibility standards and provide excellent screen reader compatibility.

## 📁 Test Files Overview

### Core Test Files

- **`project_management_accessibility_test.dart`** - Main accessibility tests for project management features
- **`kanban_keyboard_navigation_test.dart`** - Keyboard navigation and shortcuts for Kanban boards
- **`timeline_accessibility_test.dart`** - Timeline/Gantt chart accessibility testing
- **`high_contrast_accessibility_test.dart`** - High contrast mode and visual accessibility
- **`touch_targets_wcag_compliance_test.dart`** - Touch target sizes and WCAG compliance
- **`color_accessibility_test.dart`** - Color contrast validation (existing)
- **`widget_accessibility_test.dart`** - Widget-level accessibility tests (existing)
- **`run_all_accessibility_tests.dart`** - Comprehensive test runner

## 🎯 What These Tests Validate

### WCAG 2.1 AA Compliance

#### Perceivable
- ✅ Color contrast ratios ≥ 4.5:1 for normal text, ≥ 3:1 for large text
- ✅ High contrast mode support
- ✅ Alternative text for visual elements
- ✅ Non-color-dependent information communication
- ✅ Scalable text support (up to 200% zoom)

#### Operable
- ✅ Full keyboard accessibility without mouse
- ✅ Touch targets ≥ 44x44 CSS pixels (minimum accessibility requirement)
- ✅ Keyboard shortcuts and navigation patterns
- ✅ Focus indicators and management
- ✅ Drag-and-drop keyboard alternatives

#### Understandable
- ✅ Consistent navigation and functionality
- ✅ Clear error messages and form validation
- ✅ Predictable interface behavior
- ✅ Proper semantic structure and headings

#### Robust
- ✅ Screen reader compatibility (TalkBack/VoiceOver)
- ✅ Semantic markup with Flutter Semantics widgets
- ✅ Cross-platform accessibility support

## 🧪 Test Coverage

### Project Management Features Tested

1. **Project Cards**
   - Semantic labels and descriptions
   - Touch target sizes
   - Keyboard interaction
   - Screen reader announcements

2. **Kanban Boards**
   - Column navigation with arrow keys
   - Task drag-and-drop alternatives
   - Focus management between columns
   - Status change announcements

3. **Timeline/Gantt Charts**
   - Timeline navigation
   - Task selection and interaction
   - Zoom and pan controls
   - Data visualization descriptions

4. **Analytics Dashboard**
   - Chart accessibility
   - Data summaries for screen readers
   - Interactive controls
   - Drill-down navigation

5. **Bulk Operations**
   - Multi-select accessibility
   - Bulk action keyboard shortcuts
   - Operation completion announcements
   - Toolbar navigation

## 🚀 Running the Tests

### Run All Accessibility Tests
```bash
flutter test test/accessibility/run_all_accessibility_tests.dart
```

### Run Individual Test Suites
```bash
# Project management core tests
flutter test test/accessibility/project_management_accessibility_test.dart

# Keyboard navigation tests
flutter test test/accessibility/kanban_keyboard_navigation_test.dart

# Timeline accessibility
flutter test test/accessibility/timeline_accessibility_test.dart

# High contrast mode
flutter test test/accessibility/high_contrast_accessibility_test.dart

# Touch targets and WCAG compliance
flutter test test/accessibility/touch_targets_wcag_compliance_test.dart

# Color accessibility
flutter test test/accessibility/color_accessibility_test.dart

# Widget-level tests
flutter test test/accessibility/widget_accessibility_test.dart
```

### Run with Coverage
```bash
flutter test test/accessibility/ --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔧 Implementation Requirements

### For Tests to Pass, Implement These Features:

#### 1. Semantic Labels
```dart
// Project cards should have semantic labels
Semantics(
  label: 'Project: ${project.name}',
  hint: 'Tap to view project details. ${project.taskCount} tasks, ${project.completionPercentage}% complete',
  button: true,
  onTap: () => onProjectTap(),
  child: ProjectCardContent(),
)
```

#### 2. Touch Target Enhancement
```dart
// Ensure minimum 44dp touch targets
Container(
  constraints: const BoxConstraints(
    minWidth: 44.0,
    minHeight: 44.0,
  ),
  child: IconButton(
    icon: Icon(Icons.star),
    onPressed: onStarTap,
  ),
)
```

#### 3. Keyboard Navigation
```dart
// Implement keyboard shortcuts
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): NewTaskIntent(),
    LogicalKeySet(LogicalKeyboardKey.delete): DeleteTaskIntent(),
  },
  child: Actions(
    actions: {
      NewTaskIntent: CallbackAction(onInvoke: createNewTask),
      DeleteTaskIntent: CallbackAction(onInvoke: deleteTask),
    },
    child: YourWidget(),
  ),
)
```

#### 4. Screen Reader Announcements
```dart
// Announce state changes
void announceTaskMove(TaskModel task, TaskStatus newStatus) {
  SemanticsService.announce(
    'Task "${task.title}" moved to ${newStatus.displayName}',
    TextDirection.ltr,
  );
}
```

#### 5. Live Regions
```dart
// Use live regions for dynamic content
Semantics(
  liveRegion: true,
  label: 'Task count: $taskCount tasks remaining',
  child: TaskCountWidget(),
)
```

## 🎨 High Contrast Support

### Required Theme Support
```dart
// Support high contrast themes
MaterialApp(
  theme: ThemeData.from(
    colorScheme: MediaQuery.of(context).highContrast
      ? const ColorScheme.highContrastLight()
      : ColorScheme.fromSeed(seedColor: Colors.blue),
  ),
)
```

### Color Contrast Requirements
- Normal text: ≥ 4.5:1 contrast ratio
- Large text: ≥ 3:1 contrast ratio
- Interactive elements: Clear visual distinction
- Status colors: Include icons/text, not just color

## ⌨️ Keyboard Navigation Requirements

### Required Navigation Patterns
- **Tab**: Navigate between major sections
- **Arrow Keys**: Navigate within sections (Kanban columns, timeline)
- **Enter/Space**: Activate selected items
- **Escape**: Cancel operations or close modals
- **Ctrl+N**: New task/project
- **Ctrl+F**: Search/filter
- **Delete**: Delete selected items
- **F2**: Edit selected items

### Focus Management
```dart
// Implement focus trapping in modals
FocusScope(
  child: AlertDialog(
    content: YourDialogContent(),
  ),
)
```

## 📱 Screen Reader Testing

### Manual Testing Steps

1. **Enable Screen Reader**
   - Android: Settings > Accessibility > TalkBack
   - iOS: Settings > Accessibility > VoiceOver

2. **Test Navigation**
   - Swipe right/left to navigate elements
   - Double-tap to activate
   - Use explore by touch

3. **Verify Announcements**
   - Check that all UI elements are announced
   - Verify meaningful descriptions
   - Test state change announcements

## 🔍 Debugging Accessibility Issues

### Flutter Inspector
```bash
flutter run --debug
# Use Flutter Inspector > Widget Tree > Properties > Semantics
```

### Accessibility Scanner (Android)
1. Install Accessibility Scanner from Play Store
2. Enable in Settings > Accessibility
3. Tap floating action button to scan current screen

### Semantics Debugging
```dart
// Add semantic debugging
MaterialApp(
  debugShowCheckedModeBanner: false,
  showSemanticsDebugger: true, // Shows semantic boundaries
  home: YourHomePage(),
)
```

## 📊 Test Results Interpretation

### Expected Test Results
- ✅ All color contrast tests should pass
- ⚠️ Some widget tests may fail initially (requires implementation)
- ✅ Touch target tests should pass for Material widgets
- ⚠️ Semantic label tests may fail (requires custom implementation)

### Common Failures and Solutions

#### "Widget not found" Errors
```dart
// Solution: Add semantic labels to widgets
Semantics(
  label: 'Expected label text',
  child: YourWidget(),
)
```

#### "Touch target too small" Errors
```dart
// Solution: Use proper Material widgets or add constraints
SizedBox(
  width: 44,
  height: 44,
  child: YourSmallWidget(),
)
```

#### "No semantic action" Errors
```dart
// Solution: Make widgets interactive
Semantics(
  button: true,
  onTap: yourTapHandler,
  child: YourWidget(),
)
```

## 🎯 Success Criteria

### Test Suite Should Achieve:
- 🎯 95%+ test pass rate for implemented features
- 🎯 0 critical accessibility violations
- 🎯 Full keyboard navigation without mouse
- 🎯 Complete screen reader compatibility
- 🎯 WCAG 2.1 AA compliance across all features

### Production Readiness Checklist:
- [ ] All accessibility tests pass
- [ ] Manual screen reader testing completed
- [ ] Keyboard-only navigation verified
- [ ] High contrast mode tested
- [ ] Touch target sizes validated
- [ ] Color contrast compliance verified
- [ ] Error states are accessible
- [ ] Loading states announced to screen readers
- [ ] Form validation is accessible
- [ ] Dynamic content updates use live regions

## 📚 Additional Resources

### WCAG 2.1 Guidelines
- [WCAG 2.1 AA Success Criteria](https://www.w3.org/WAI/WCAG21/quickref/?versions=2.1&levels=aa)
- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

### Testing Tools
- [Accessibility Scanner](https://play.google.com/store/apps/details?id=com.google.android.apps.accessibility.auditor) (Android)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)
- [axe DevTools](https://www.deque.com/axe/devtools/) (Web)

### Screen Reader Resources
- [TalkBack User Guide](https://support.google.com/accessibility/android/answer/6283677)
- [VoiceOver User Guide](https://support.apple.com/guide/voiceover/)
- [NVDA Screen Reader](https://www.nvaccess.org/) (Desktop testing)

---

*This test suite ensures that the Tasky project management features are accessible to all users, including those using screen readers, keyboard navigation, or high contrast modes. The tests serve as both validation and documentation of accessibility requirements.*