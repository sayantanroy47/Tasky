# Flutter Task Management App - Comprehensive TODO

**Project:** Tasky Flutter App  
**Created:** 2025-01-22  
**Status:** Implementation Phase  

---

## 🎯 ORIGINAL REQUIREMENTS (0-20)

### REQ 0: Bottom Navigation Overhaul
- [ ] **Remove labels** from bottom navigation items
  - **File:** `lib/presentation/pages/main_scaffold.dart:539-551`
  - **Action:** Remove text labels from navigation items completely
- [ ] **Fix alignment** - ensure active selected rectangle is centrally aligned horizontally and vertically with icons
  - **File:** `lib/presentation/pages/main_scaffold.dart:508-536`
  - **Action:** Adjust container positioning and dimensions
- [ ] **Add theme border** around circular + (FAB) button
  - **File:** `lib/presentation/pages/main_scaffold.dart:396-478`
  - **Action:** Add theme-prevalent border styling to FAB

### REQ 1A: Voice-Only Task Creation
- [ ] **Add Voice-Only option** to task creation menu
  - **File:** `lib/presentation/pages/main_scaffold.dart:561-654`
  - **Action:** Add new option in task creation bottom sheet
- [ ] **Implement multiple voice recordings**
  - **Files:** Create new voice-only service, update audio handling
  - **Action:** Allow user to record multiple voice notes
- [ ] **Audio concatenation** - combine into single playable file
  - **Files:** Create audio concatenation service
  - **Action:** Merge multiple recordings into one file
- [ ] **Playback integration** - playable in compact cards and task details
  - **Files:** Update task cards and detail pages
  - **Action:** Add audio playback widgets

### REQ 1B: Location-Based Task Creation  
- [ ] **Add Location-Based option** to task creation menu
  - **File:** `lib/presentation/pages/main_scaffold.dart:561-654`
  - **Action:** Add location-based option with geolocation icon
- [ ] **Fix Location Setup** - currently doesn't work
  - **Files:** `lib/services/location/`, permission handlers
  - **Action:** Debug permission issues, geofencing setup
- [ ] **Revise existing implementation**
  - **Files:** Location service implementations
  - **Action:** Test and fix location-based task functionality

### REQ 2: Project Creation Fix
- [ ] **Debug project creation** in Settings page
  - **File:** `lib/presentation/pages/settings_page.dart`
  - **Action:** Investigate why project creation doesn't work
- [ ] **Check database constraints**
  - **Files:** Database schemas, project repository
  - **Action:** Verify table constraints and validation rules
- [ ] **Test service configuration**
  - **Files:** Project services, providers
  - **Action:** Ensure proper dependency injection and state management

### REQ 3: Calendar Package Migration
- [ ] **Replace table_calendar** with syncfusion_flutter_calendar ^30.2.6
  - **File:** `pubspec.yaml`
  - **Action:** Update dependency, remove old package
- [ ] **Maintain existing functionality**
  - **Files:** Calendar pages, widgets, providers
  - **Action:** Preserve all current calendar features
- [ ] **Test integration**
  - **Files:** Calendar integration tests
  - **Action:** Verify task integration, event creation

### REQ 5: Calendar Page Padding
- [ ] **Fix top padding** - make same as settings page
  - **File:** `lib/presentation/pages/calendar_page.dart:46`
  - **Current:** `top: kToolbarHeight + 8`
  - **Action:** Match settings page padding exactly

### REQ 6: Button Radius Standardization
- [ ] **Find ALL buttons** throughout the app
  - **Files:** All widget files, custom button components
  - **Action:** Comprehensive search for button widgets
- [ ] **Apply 12px radius** consistently
  - **Files:** All identified button locations
  - **Action:** Standardize BorderRadius.circular(12) everywhere
- [ ] **Update design tokens**
  - **File:** `lib/core/design_system/design_tokens.dart`
  - **Action:** Define standard button radius constant

### REQ 7: Voice-Only Task Flow
- [ ] **Bring back voice-only option** (since transcription isn't working)
  - **Files:** Voice recording services, UI components
  - **Action:** Implement pure voice recording without transcription
- [ ] **Guide to task edit page** after recording
  - **Files:** Navigation flow, voice recording completion handlers
  - **Action:** Direct user to edit page post-recording
- [ ] **Same flow as other options**
  - **Files:** Task creation flow coordination
  - **Action:** Ensure consistent UX across creation methods

### REQ 8: Task Edit Performance
- [ ] **Debug slow loading** - investigate performance bottlenecks
  - **Files:** Task edit page, related services
  - **Action:** Profile loading time, identify slow operations
- [ ] **Optimize performance**
  - **Files:** Task edit components, data loading
  - **Action:** Implement lazy loading, reduce computations

### REQ 9: Default Task Date
- [ ] **Set today as default** for all new tasks
  - **Files:** Task creation forms, default value logic
  - **Action:** Auto-populate date field with current date
- [ ] **Handle unspecified dates**
  - **Files:** Task validation, save logic
  - **Action:** Use today's date when user doesn't specify

### REQ 10: Recurring Task Options
- [ ] **Add end date option** to recurring tasks
  - **Files:** Recurring task creation/edit UI
  - **Action:** Add date picker for recurrence end
- [ ] **Add day selection** (currently only dropdown)
  - **Files:** Recurring task options UI
  - **Action:** Replace dropdown with day selection interface
- [ ] **Update central task edit area**
  - **Files:** Task edit form components
  - **Action:** Integrate new recurring options

### REQ 11: Circular Status Badges
- [ ] **Make status badges circles** in compact cards
  - **Files:** Task card components, status badge widgets
  - **Action:** Change badge shape from current to circular
- [ ] **Update all compact card implementations**
  - **Files:** All task card variants
  - **Action:** Ensure consistent circular badges

### REQ 12: Location-Based Tasks Fix
- [ ] **Investigate missing implementation** for location tasks
  - **Files:** Location service, geofencing logic
  - **Action:** Find what's broken in location functionality
- [ ] **Fix functionality** completely
  - **Files:** Location-based task creation, triggers
  - **Action:** Ensure location tasks work end-to-end

### REQ 14: Background System Replacement
- [ ] **Remove ALL existing background files**
  - **Directory:** `assets/backgrounds/`
  - **Action:** Delete all PNG/JPG background files
- [ ] **Replace with programmatic gradients**
  - **Files:** Theme implementations, background widgets
  - **Action:** Create linear gradients for each theme
- [ ] **Center-to-outward flow** for modern aesthetic
  - **Files:** Gradient implementations
  - **Action:** Start gradients from page center, flow outward
- [ ] **Ensure clear color transitions** for light/dark variants
  - **Files:** Theme-specific gradient definitions
  - **Action:** Make color transitions clearly visible

### REQ 15: Local Font System
- [ ] **Remove google_fonts dependency**
  - **File:** `pubspec.yaml`
  - **Action:** Remove google_fonts package completely
- [ ] **Use local font assets**
  - **Directory:** `assets/fonts/`
  - **Fonts:** Orbitron, FiraCode, Roboto, Montserrat, JetBrainsMono
  - **Action:** Reference local .ttf files instead of network calls
- [ ] **Set Montserrat as fallback**
  - **Files:** All theme files, typography definitions
  - **Action:** Ensure Montserrat is universal fallback font
- [ ] **Eliminate network font downloads**
  - **Files:** All font references throughout app
  - **Action:** Verify no network font loading occurs

### REQ 16A: Theme Preview Redesign
- [ ] **Use rectangular preview blocks**
  - **File:** `lib/presentation/pages/themes_page.dart`
  - **Action:** Replace current previews with rectangular blocks
- [ ] **Represent UI sections** (calendar, background, text areas)
  - **Files:** Theme preview components
  - **Action:** Create geometric sections showing different UI elements
- [ ] **Demonstrate contrasting colors** for light/dark variants
  - **Files:** Theme preview logic
  - **Action:** Show clear color differences between modes

### REQ 16B: Theme Names Display
- [ ] **Show theme names below preview**
  - **Files:** Theme card components
  - **Action:** Position names under preview blocks
- [ ] **Use smaller font size**
  - **Files:** Theme name typography
  - **Action:** Reduce font size for better layout
- [ ] **Allow up to 2 lines** for better visibility
  - **Files:** Theme name text widgets
  - **Action:** Support text wrapping to 2 lines
- [ ] **Ensure selection tick doesn't overlap**
  - **Files:** Theme selection indicators
  - **Action:** Position selection indicators to avoid name overlap
- [ ] **Remove secondary descriptors** (e.g., Cinematic, Vibrant)
  - **Files:** Theme metadata, display logic
  - **Action:** Clean layout by removing extra text

### REQ 16C: Theme Spacing & Alignment
- [ ] **Add consistent padding** between preview and name
  - **Files:** Theme card layout
  - **Action:** Standardize spacing for better readability
- [ ] **Ensure uniform height/width** across all theme cards
  - **Files:** Theme grid/list layout
  - **Action:** Make all theme preview cards same dimensions

### REQ 17A: Home Page Icon Removal
- [ ] **Remove icons from good morning section**
  - **File:** `lib/presentation/pages/home_page_m3.dart`
  - **Action:** Remove icons from first section of home screen

### REQ 17B: Home Page Cleanup
- [ ] **Remove 0% complete progress bar**
  - **File:** `lib/presentation/pages/home_page_m3.dart`
  - **Action:** Remove redundant progress indicators
- [ ] **Remove pending urgent indicators** (already defined below)
  - **Files:** Home page components
  - **Action:** Clean up duplicate information
- [ ] **Remove productivity streak** and associated old code
  - **Files:** Home page, productivity tracking components
  - **Action:** Remove productivity streak section completely

### REQ 18: Debug Log Cleanup
- [ ] **Remove startup debug logs**
  - **Files:** `lib/main.dart`, initialization code
  - **Action:** Clean up debug logging from app startup
- [ ] **Remove debug logs throughout app**
  - **Files:** All service files, UI components
  - **Action:** Remove or conditionally compile debug statements

### REQ 19: Voice Demo Removal
- [ ] **Remove Voice demo page** from Settings
  - **File:** `lib/presentation/pages/settings_page.dart`
  - **Action:** Remove voice demo navigation option
- [ ] **Clean up redundant code**
  - **Files:** Voice demo page, related imports
  - **Action:** Remove all associated voice demo components

### REQ 20: Typography Bold Font Removal
- [ ] **Remove bold fonts** from typography system
  - **File:** `lib/core/theme/app_typography.dart`
  - **Action:** Replace all FontWeight.bold with normal weights
- [ ] **Update all typography references**
  - **Files:** All UI components using bold fonts
  - **Action:** Ensure no bold fonts are used anywhere

---

## 🚀 ADDITIONAL TECHNICAL REQUIREMENTS (21-28)

### ADDITIONAL 21: Haptic Feedback
- [ ] **Add haptic feedback** to navigation interactions
  - **Files:** Navigation handlers, button components
  - **Action:** Implement HapticFeedback.selectionClick() for key interactions

### ADDITIONAL 22: Glassmorphism Performance
- [ ] **Optimize glassmorphism effects**
  - **Files:** Glassmorphism containers, blur effects
  - **Action:** Replace runtime blur calculations with pre-computed effects

### ADDITIONAL 23: Skeleton Loading States
- [ ] **Replace spinners with skeleton screens**
  - **Files:** Loading state components
  - **Action:** Implement content-aware skeleton loading

### ADDITIONAL 24: 8px Grid System
- [ ] **Implement consistent 8px spacing**
  - **Files:** All UI components, spacing constants
  - **Action:** Use 8px grid system throughout application

### ADDITIONAL 25: High Contrast Accessibility
- [ ] **Implement accessibility support**
  - **Files:** Theme system, color definitions
  - **Action:** Add high contrast mode for visual impairments

### ADDITIONAL 26: Keyboard Navigation
- [ ] **Add comprehensive keyboard navigation**
  - **Files:** All interactive components
  - **Action:** Ensure all actions accessible via keyboard

### ADDITIONAL 27: Audio Concatenation Service
- [ ] **Create audio concatenation service**
  - **Files:** New service for combining voice recordings
  - **Action:** Implement service to merge multiple audio files

### ADDITIONAL 28: Voice Recording Error Handling
- [ ] **Handle device limitations**
  - **Files:** Voice recording services, error handling
  - **Action:** Manage storage issues, permission denials, device constraints

---

## 🧪 TESTING & VALIDATION

### TESTING: End-to-End Task Creation
- [ ] **Test voice-only task creation** flow completely
- [ ] **Test location-based task creation** functionality
- [ ] **Test manual task creation** maintains functionality
- [ ] **Verify all creation methods** guide to same edit flow

### TESTING: Calendar Migration
- [ ] **Verify syncfusion calendar** maintains all existing functionality
- [ ] **Test task integration** with new calendar widget
- [ ] **Validate event creation** and editing capabilities
- [ ] **Check performance** and memory usage

### TESTING: Theme System
- [ ] **Test theme switching** without breaking glassmorphism
- [ ] **Verify font rendering** across all theme variants
- [ ] **Check gradient backgrounds** display correctly
- [ ] **Ensure selection indicators** work properly

---

## 🧹 CLEANUP TASKS

### CLEANUP: File Management
- [ ] **Remove all .dart.backup files** throughout codebase
- [ ] **Clean up unused widgets** and imports after changes
- [ ] **Remove redundant background assets** from pubspec.yaml
- [ ] **Optimize import statements** and dependencies

### CLEANUP: Code Quality
- [ ] **Remove unused components** identified during implementation
- [ ] **Clean up commented code** and development artifacts
- [ ] **Standardize code formatting** and style consistency
- [ ] **Update documentation** for changed components

---

## ✅ VALIDATION & COMPATIBILITY

### VALIDATION: System Integrity
- [ ] **Ensure font rendering** works across all themes
- [ ] **Verify backwards compatibility** with existing user data
- [ ] **Test audio file references** for existing voice tasks
- [ ] **Validate theme settings** migration if structure changes

### VALIDATION: Performance Metrics
- [ ] **Measure app startup time** after optimizations
- [ ] **Check memory usage** improvements from glassmorphism changes
- [ ] **Verify smooth animations** and transitions
- [ ] **Test on lower-end devices** for performance validation

---

## 📁 PRIMARY FILES TO MODIFY

### Navigation & Core UI
- `lib/presentation/pages/main_scaffold.dart` - Bottom navigation overhaul
- `lib/presentation/pages/themes_page.dart` - Theme gallery redesign
- `lib/presentation/pages/settings_page.dart` - Settings optimization
- `lib/presentation/pages/home_page_m3.dart` - Home page cleanup
- `lib/presentation/pages/calendar_page.dart` - Calendar migration

### Typography & Design System  
- `lib/core/theme/app_typography.dart` - Typography system overhaul
- `lib/core/theme/themes/` - All theme files for font migration
- `lib/core/design_system/design_tokens.dart` - Design standardization
- `pubspec.yaml` - Dependencies and font asset declarations

### Task Management
- `lib/presentation/widgets/enhanced_task_creation_dialog.dart` - Voice-only option
- `lib/presentation/widgets/voice_task_creation_dialog_m3.dart` - Audio concatenation  
- `lib/presentation/widgets/enhanced_location_task_dialog.dart` - Location fixes
- All task card and recurring task components

### Asset Management
- `assets/backgrounds/` - Complete removal and replacement
- `assets/fonts/` - Local font system implementation
- All background-related theme files and references

---

## 🎯 SUCCESS CRITERIA

### UI/UX Validation
- ✅ Perfect icon alignment in bottom navigation without labels
- ✅ Consistent 12px border radius on ALL buttons
- ✅ Theme gallery matches provided rectangular preview image exactly
- ✅ Zero Google Fonts network calls
- ✅ Smooth glassmorphism performance (60fps+)

### Functionality Validation  
- ✅ Working voice-only task creation with audio concatenation
- ✅ Functional location-based task creation end-to-end
- ✅ Working project creation in settings page
- ✅ Fast task edit page loading (<2 seconds)
- ✅ Successful calendar package migration with full functionality

### Performance Validation
- ✅ Reduced app bundle size after asset cleanup
- ✅ Improved memory usage from optimized glassmorphism
- ✅ Faster home page loading after cleanup
- ✅ Responsive theme switching without glitches
- ✅ Battery usage optimization from reduced blur effects

### Code Quality Validation
- ✅ Zero debug logs in production builds
- ✅ Clean codebase without backup files
- ✅ Proper error handling throughout application
- ✅ Comprehensive test coverage for changed components
- ✅ Backwards compatibility maintained for existing users

---

## 📅 IMPLEMENTATION TIMELINE

### Phase 1: Core Navigation & UI (Week 1)
- REQ 0, 1A, 1B, 6, 21, 22

### Phase 2: Typography & Design System (Week 2)  
- REQ 15, 20, 16A, 16B, 16C, 24

### Phase 3: Calendar & Settings (Week 3)
- REQ 2, 3, 5, 19

### Phase 4: Task Management & Performance (Week 4)
- REQ 7, 8, 9, 10, 11, 12, 23

### Phase 5: Home Page & Background System (Week 5)
- REQ 14, 17A, 17B, 18

### Phase 6: Advanced Features & Testing (Week 6)
- REQ 25, 26, 27, 28, All Testing Tasks

---

**Last Updated:** 2025-01-22  
**Total Tasks:** 37+ comprehensive requirements  
**Estimated Timeline:** 6 weeks  
**Priority:** High - UI/UX improvements critical for user experience