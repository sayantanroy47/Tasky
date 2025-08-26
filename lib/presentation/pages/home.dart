import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/providers/core_providers.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/ui/slidable_action_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import '../../services/ui/slidable_theme_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../services/welcome_message_service.dart';
import '../providers/profile_providers.dart';
import '../providers/project_providers.dart';
import '../providers/tag_providers.dart';
import '../providers/task_provider.dart';
import '../providers/task_providers.dart';
import '../widgets/audio_indicator_widget.dart';
import '../widgets/enhanced_glass_button.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_border_radius.dart';
import '../widgets/standardized_card.dart';
import '../widgets/standardized_error_states.dart';
import '../widgets/standardized_icons.dart' show StandardizedIcon, StandardizedIconSize, StandardizedIconStyle;
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/standardized_text.dart';
import '../widgets/tag_chip.dart';
import 'analytics_page.dart';

/// Futuristic Material 3 Home Page
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  late ScrollController _scrollController;

  // Cache welcome data to prevent rebuild storms
  Map<String, dynamic>? _cachedWelcomeData;
  bool _welcomeDataInitialized = false;
  String? _cachedFirstName; // Track previous firstName to detect changes

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Get welcome message and task summary data - cached to prevent rebuild storms
  Map<String, dynamic> _getWelcomeData() {
    // Get current first name to check for changes
    final profileAsync = ref.watch(currentProfileProvider);
    final currentFirstName = profileAsync.maybeWhen(
      data: (profile) => profile?.firstName,
      orElse: () => null,
    );

    // Clear cache if firstName changed (profile was updated)
    if (_cachedFirstName != currentFirstName) {
      _cachedWelcomeData = null;
      _welcomeDataInitialized = false;
      _cachedFirstName = currentFirstName;
    }

    // Return cached data if available to prevent expensive rebuilds
    if (_welcomeDataInitialized && _cachedWelcomeData != null) {
      return _cachedWelcomeData!;
    }

    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);

    final pendingCount = pendingTasks.maybeWhen(data: (tasks) => tasks.length, orElse: () => 0);
    final completedCount = completedTasks.maybeWhen(data: (tasks) => tasks.length, orElse: () => 0);
    final totalCount = pendingCount + completedCount;

    // Use the currentFirstName already fetched above
    final firstName = currentFirstName;

    final welcomeService = WelcomeMessageService();
    final welcomeMessage = welcomeService.getWelcomeMessage(
      firstName: firstName,
      pendingTaskCount: pendingCount,
      completedToday: completedCount,
    );

    final taskSummary = welcomeService.getTaskSummary(
      pendingTasks: pendingCount,
      completedToday: completedCount,
      totalTasks: totalCount,
    );

    _cachedWelcomeData = {
      'welcomeMessage': welcomeMessage,
      'taskSummary': taskSummary,
      'pendingCount': pendingCount,
      'completedCount': completedCount,
      'firstName': firstName,
    };
    _welcomeDataInitialized = true;

    return _cachedWelcomeData!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent to show background
      extendBodyBehindAppBar: true, // Show phone status bar
      appBar: StandardizedAppBar(
        title: 'Home',
        forceBackButton: false, // Home is main tab - no back button
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(PhosphorIcons.chartLine()),
            onPressed: () => _showTaskInsights(context),
            tooltip: 'Task insights',
          ),
          IconButton(
            icon: Icon(PhosphorIcons.magnifyingGlass()),
            onPressed: () => _showTaskSearch(context),
            tooltip: 'Search tasks',
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: StandardizedSpacing.padding(SpacingSize.md),
                child: Column(
                  children: [
                    // Sophisticated welcome - condensed for task focus
                    _buildWelcomeSection(context, theme),
                    const SizedBox(height: SpacingTokens.phi1),
                    // Task overview with detailed stats
                    _buildTaskOverview(theme),
                    const SizedBox(height: SpacingTokens.welcomeSpacing), // Golden ratio spacing
                    // Tasks prioritized - moved to top for immediate focus
                    _buildTaskTabsSection(context, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildSearchDialog(context),
    );
  }

  Widget _buildSearchDialog(BuildContext context) {
    final theme = Theme.of(context);
    String searchQuery = '';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StandardizedTextVariants.pageHeader('Search Tasks'),
            StandardizedGaps.md,
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter search terms...',
                  prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent, // TODO: Use context.colors.backgroundTransparent
                ),
                onChanged: (value) => searchQuery = value,
              ),
            ),
            StandardizedGaps.md,
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 150,
                maxHeight: 400,
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: Consumer(
                  builder: (context, ref, child) {
                    final allTasks = ref.watch(tasksProvider);
                    return allTasks.when(
                      data: (tasks) {
                        if (searchQuery.isEmpty) {
                          return _buildEmptyState(theme);
                        }

                        final filteredTasks = tasks
                            .where((task) =>
                                task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                                (task.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false))
                            .toList();

                        if (filteredTasks.isEmpty) {
                          return Center(
                            child: StandardizedText('No tasks found for "$searchQuery"',
                                style: StandardizedTextStyle.bodyMedium),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 160), // Bottom navigation bar + FAB clearance (80px + 72px FAB + 8px buffer)
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return ListTile(
                              title: StandardizedText(TextUtils.autoCapitalize(task.title), style: StandardizedTextStyle.labelLarge),
                              subtitle: task.description?.isNotEmpty == true
                                  ? StandardizedText(task.description!, style: StandardizedTextStyle.bodySmall)
                                  : null,
                              onTap: () {
                                Navigator.of(context).pop();
                                AppRouter.navigateToTaskDetail(context, task.id);
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  Navigator.of(context).pop();
                                  switch (value) {
                                    case 'edit':
                                      _editTask(task);
                                      break;
                                    case 'share':
                                      _shareTask(task);
                                      break;
                                    case 'delete':
                                      _deleteTask(task);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(PhosphorIcons.pencil()),
                                      title: const StandardizedText('Edit', style: StandardizedTextStyle.bodyMedium),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'share',
                                    child: ListTile(
                                      leading: Icon(PhosphorIcons.share()),
                                      title: const StandardizedText('Share', style: StandardizedTextStyle.bodyMedium),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(PhosphorIcons.trash()),
                                      title: const StandardizedText('Delete', style: StandardizedTextStyle.bodyMedium),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => Center(child: StandardizedErrorStates.loading()),
                      error: (error, _) =>
                          Center(child: StandardizedText('Error: $error', style: StandardizedTextStyle.bodyMedium)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskInsights(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: StandardizedSpacing.padding(SpacingSize.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: double.maxFinite,
              maxHeight: 500, // Increased height for more content
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and X button
                Row(
                  children: [
                    const Flexible(
                      child: StandardizedText(
                        'Insights',
                        style: StandardizedTextStyle.headlineSmall,
                      ),
                    ),
                    const Spacer(),
                    // X button in top right
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            PhosphorIcons.x(),
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                StandardizedGaps.md,
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final allTasks = ref.watch(tasksProvider);
                      return allTasks.when(
                        data: (tasks) {
                          final completedTasks = tasks.where((t) => t.isCompleted).length;
                          final pendingTasks = tasks.where((t) => !t.isCompleted).length;
                          final urgentTasks =
                              tasks.where((t) => t.priority == TaskPriority.urgent && !t.isCompleted).length;
                          final overdueTasks = tasks.where((t) {
                            if (t.dueDate == null || t.isCompleted) return false;
                            return t.dueDate!.isBefore(DateTime.now());
                          }).length;

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Task Statistics Section
                                _buildInsightRow('Total Tasks', '${tasks.length}', PhosphorIcons.list()),
                                _buildInsightRow('Completed', '$completedTasks', PhosphorIcons.checkCircle(),
                                    color: Theme.of(context).colorScheme.primary),
                                _buildInsightRow('Pending', '$pendingTasks', PhosphorIcons.clock(),
                                    color: Theme.of(context).colorScheme.secondary),
                                _buildInsightRow('Urgent', '$urgentTasks', PhosphorIcons.arrowUp(),
                                    color: Theme.of(context).colorScheme.error),
                                _buildInsightRow('Overdue', '$overdueTasks', PhosphorIcons.warning(),
                                    color: Theme.of(context).colorScheme.error),
                                
                                StandardizedGaps.lg,
                                
                                // Quick Actions Section
                                Row(
                                  children: [
                                    // View All Tasks Button
                                    Expanded(
                                      child: EnhancedGlassButton(
                                        height: 48, // Standardized button height
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          AppRouter.navigateToRoute(context, AppRouter.allTasks);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(PhosphorIcons.list(), size: 16),
                                            const SizedBox(width: 8),
                                            const Flexible(
                                              child: StandardizedText('View All Tasks', style: StandardizedTextStyle.buttonText),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Analytics Button
                                    Expanded(
                                      child: EnhancedGlassButton.secondary(
                                        height: 48, // Standardized button height
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Navigate to analytics page
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const AnalyticsPage(),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(PhosphorIcons.chartBar(), size: 16),
                                            const SizedBox(width: 8),
                                            const Flexible(
                                              child: StandardizedText('Analytics', style: StandardizedTextStyle.buttonText),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => Center(child: StandardizedErrorStates.loading()),
                        error: (error, _) =>
                            Center(child: StandardizedText('Error: $error', style: StandardizedTextStyle.bodyMedium)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        children: [
          Icon(icon, color: color),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Expanded(child: StandardizedText(label, style: StandardizedTextStyle.bodyMedium)),
          StandardizedText(value, style: StandardizedTextStyle.bodyMedium, color: color),
        ],
      ),
    );
  }

  void _showTaskContextMenu(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius:
                  BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy
              child: const SizedBox(
                width: 40,
                height: 4,
              ),
            ),
            StandardizedGaps.md,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
              child: StandardizedText(
                task.title,
                style: StandardizedTextStyle.labelLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StandardizedGaps.md,
            ListTile(
              leading: Icon(PhosphorIcons.pencil()),
              title: const StandardizedText('Edit Task', style: StandardizedTextStyle.bodyMedium),
              onTap: () {
                Navigator.of(context).pop();
                _editTask(task);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.share()),
              title: const StandardizedText('Share Task', style: StandardizedTextStyle.bodyMedium),
              onTap: () {
                Navigator.of(context).pop();
                _shareTask(task);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(PhosphorIcons.trash(), color: Theme.of(context).colorScheme.error),
              title: StandardizedText(
                'Delete Task',
                style: StandardizedTextStyle.bodyMedium,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _deleteTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Personalized welcome section with elegant minimal design
  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showWelcomeDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Builder(builder: (context) {
          final welcomeData = _getWelcomeData();
          final welcomeMessage = welcomeData['welcomeMessage'] as WelcomeMessage;

          return Row(
            children: [
              // Clean icon without borders
              if (welcomeMessage.icon != null) ...[
                Icon(
                  welcomeMessage.icon!,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                StandardizedGaps.horizontal(SpacingSize.md),
              ],
              Expanded(
                child: StandardizedText(
                  welcomeMessage.greeting,
                  style: StandardizedTextStyle.headlineSmall,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              // Subtle indicator that this section is interactive
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Show welcome details
  void _showWelcomeDetails(BuildContext context) {
    final theme = Theme.of(context);
    final welcomeData = _getWelcomeData();
    final welcomeMessage = welcomeData['welcomeMessage'] as WelcomeMessage;
    final timeOfDay = welcomeData['timeOfDay'] as String;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (welcomeMessage.icon != null) ...[
              Icon(
                welcomeMessage.icon!,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                'Welcome Details',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Time: $timeOfDay',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Message: ${welcomeMessage.greeting}',
              style: theme.textTheme.bodyMedium,
            ),
            if (welcomeMessage.subtitle.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Focus',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      welcomeMessage.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Builds the main task overview section with quick stats and insights
  Widget _buildTaskOverview(ThemeData theme) {
    final allTasks = ref.watch(tasksProvider);

    return allTasks.when(
      loading: () => _buildLoadingState(theme),
      error: (error, stack) => _buildErrorState(theme, error.toString()),
      data: (tasks) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        // Calculate task counts
        final todayTasks = tasks
            .where((task) =>
                !task.isCompleted &&
                (task.dueDate == null || task.dueDate!.isAfter(todayStart)) &&
                (task.dueDate == null || task.dueDate!.isBefore(todayEnd)))
            .toList();

        final pendingCount = todayTasks.length;
        final urgentCount = todayTasks.where((t) => t.priority == TaskPriority.urgent).length;
        final highCount = todayTasks.where((t) => t.priority == TaskPriority.high).length;
        final completedToday = tasks
            .where((task) =>
                task.isCompleted &&
                task.completedAt != null &&
                task.completedAt!.isAfter(todayStart) &&
                task.completedAt!.isBefore(todayEnd))
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Row
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: StandardizedSpacing.padding(SpacingSize.md),
              child: Row(
                children: [
                  _buildQuickStat(
                    theme: theme,
                    icon: PhosphorIcons.clockCounterClockwise(),
                    label: 'Pending',
                    count: pendingCount,
                    color: theme.colorScheme.primary,
                  ),
                  _buildQuickStat(
                    theme: theme,
                    icon: PhosphorIcons.arrowUp(),
                    label: 'Urgent',
                    count: urgentCount,
                    color: theme.colorScheme.error,
                  ),
                  _buildQuickStat(
                    theme: theme,
                    icon: PhosphorIcons.caretUp(),
                    label: 'High',
                    count: highCount,
                    color: theme.colorScheme.secondary,
                  ),
                  _buildQuickStat(
                    theme: theme,
                    icon: PhosphorIcons.checkCircle(),
                    label: 'Done',
                    count: completedToday,
                    color: context.successColor,
                  ),
                ],
              ),
            ),
            StandardizedGaps.vertical(SpacingSize.sm),
            // Task Insight
            _buildTaskInsight(theme, pendingCount, urgentCount, highCount),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: StandardizedBorderRadius.fab, // Make it circular
            padding: StandardizedSpacing.padding(SpacingSize.lg),
            glassTint: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            child: StandardizedIcon(
              PhosphorIcons.rocket(),
              size: StandardizedIconSize.xxxl,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          StandardizedGaps.md,
          const StandardizedText(
            'Ready to get started?',
            style: StandardizedTextStyle.titleMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          StandardizedText(
            'Create your first task',
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      children: List.generate(
        3,
        (index) => GlassmorphismContainer(
          level: GlassLevel.background,
          height: 120,
          margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000 + (index * 200)),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent, // TODO: Use context.colors.backgroundTransparent
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  Colors.transparent, // TODO: Use context.colors.backgroundTransparent
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        children: [
          StandardizedIcon(
            PhosphorIcons.warningCircle(),
            size: StandardizedIconSize.xxxl,
            style: StandardizedIconStyle.error,
          ),
          StandardizedGaps.md,
          StandardizedText(
            'Something went wrong',
            style: StandardizedTextStyle.titleSmall,
            color: theme.colorScheme.error,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          StandardizedText(
            'Unable to load tasks',
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          StandardizedGaps.md,
          OutlinedButton.icon(
            onPressed: () => ref.refresh(tasksProvider),
            icon: Icon(PhosphorIcons.arrowClockwise()),
            label: const StandardizedText('Retry', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }

  void _editTask(TaskModel task) {
    // Navigate to edit task screen
    AppRouter.navigateToTaskDetail(context, task.id);
  }

  void _deleteTask(TaskModel task) {
    // Show confirmation dialog and delete task
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // TODO: Use context.colors.backgroundTransparent
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge), // 16.0 - Fixed border radius hierarchy
          padding: StandardizedSpacing.padding(SpacingSize.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StandardizedText(
                'Delete Task',
                style: StandardizedTextStyle.headlineSmall,
              ),
              StandardizedGaps.md,
              StandardizedText(
                'Are you sure you want to delete "${task.title}"?',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StandardizedTextStyle.bodyMedium,
              ),
              StandardizedGaps.lg,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EnhancedGlassButton.secondary(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.sm),
                  EnhancedGlassButton(
                    onPressed: () async {
                      // Delete task through provider
                      await ref.read(taskRepositoryProvider).deleteTask(task.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: StandardizedText('Task "${task.title}" deleted',
                                style: StandardizedTextStyle.bodyMedium),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    glassTint: Theme.of(context).colorScheme.error,
                    child: StandardizedText(
                      'Delete',
                      style: StandardizedTextStyle.buttonText,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareTask(TaskModel task) {
    // Implement task sharing functionality
    final shareText = '''
Task: ${task.title}
${task.description?.isNotEmpty == true ? 'Description: ${task.description}' : ''}
Priority: ${task.priority.name.toUpperCase()}
${task.dueDate != null ? 'Due: ${task.dueDate!.toString()}' : ''}

Shared from Tasky - Task Management App
''';

    // Use the platform's native sharing capabilities
    SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'Task: ${task.title}',
      ),
    );
  }

  /// Build current tab view efficiently (only renders active tab)
  Widget _buildCurrentTabView(BuildContext context, ThemeData theme) {
    switch (_currentTabIndex) {
      case 0:
        return _buildTodayTasksList(context, theme);
      case 1:
        return _buildProjectsList(context, theme);
      case 2:
        return _buildPlannedTasksList(context, theme);
      default:
        return _buildTodayTasksList(context, theme);
    }
  }

  /// Sophisticated task tabs with text-only elegance and positive psychology
  Widget _buildTaskTabsSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sophisticated tab bar with elegant styling
        Container(
          height: 56, // Increased for touch accessibility
          padding: StandardizedSpacing.padding(SpacingSize.xs),
          child: TabBar(
              controller: _tabController,
              // Sophisticated gradient indicator for premium feel
              indicator: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 0.5, // Ultra-thin for sophistication
                ),
              ),

              // Sophisticated typography and colors
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent, // TODO: Use context.colors.backgroundTransparent
              indicatorSize: TabBarIndicatorSize.tab,

              // Elegant text styling
              labelStyle: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                    // Using standardized titleMedium (16) for clarity
                    fontWeight: TypographyConstants.regular, // Regular weight for sophistication
                    letterSpacing: 0.1, // Subtle letter spacing
                  ),
              unselectedLabelStyle: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                    // Using standardized titleMedium (16) for consistency
                    fontWeight: TypographyConstants.light, // Light weight for unselected
                    letterSpacing: 0.1,
                  ),

              tabs: [
                // Text-only tabs for sophisticated elegance
                Semantics(
                  label: 'Today\'s tasks tab',
                  hint: 'View tasks due today',
                  button: true,
                  child: const Tab(text: 'Today'),
                ),
                Semantics(
                  label: 'Projects tab',
                  hint: 'View active projects',
                  button: true,
                  child: const Tab(text: 'Projects'),
                ),
                Semantics(
                  label: 'Planned tasks tab',
                  hint: 'View planned upcoming tasks',
                  button: true,
                  child: const Tab(text: 'Planned'), // Renamed from 'Future' for clarity
                ),
            ],
          ),
        ),
        StandardizedGaps.vertical(SpacingSize.md),

        // Task content prioritized - increased from 65% to 75% of screen height
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.75, // More space for tasks
          child: _buildCurrentTabView(context, theme),
        ),
      ],
    );
  }

  // Removed _buildFixedTab method - using simple text-only tabs for sophistication

  /// Build today's tasks list - only tasks due today, not created today
  Widget _buildTodayTasksList(BuildContext context, ThemeData theme) {
    final todayDueTasks = ref.watch(todayTasksProvider);

    return todayDueTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyTasksList(theme, 'No tasks due today', PhosphorIcons.calendar());
        }

        // Sort by priority and creation time
        tasks.sort((a, b) {
          final priorityComparison = b.priority.index.compareTo(a.priority.index);
          if (priorityComparison != 0) return priorityComparison;
          return b.createdAt.compareTo(a.createdAt);
        });

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 160), // Bottom navigation bar + FAB clearance (80px + 72px FAB + 8px buffer)
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildCompactTaskCard(task, theme);
          },
        );
      },
      loading: () => _buildTasksLoadingState(theme),
      error: (error, _) => _buildTasksErrorState(theme, error.toString()),
    );
  }

  /// Build projects list with compact project cards
  Widget _buildProjectsList(BuildContext context, ThemeData theme) {
    final activeProjects = ref.watch(activeProjectsProvider);

    return activeProjects.when(
      data: (projects) {
        if (projects.isEmpty) {
          return _buildEmptyProjectsList(theme);
        }

        // Sort by creation date (newest first) and task count
        projects.sort((a, b) {
          final taskCountCompare = b.taskCount.compareTo(a.taskCount);
          if (taskCountCompare != 0) return taskCountCompare;
          return b.createdAt.compareTo(a.createdAt);
        });

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 160), // Bottom navigation bar + FAB clearance (80px + 72px FAB + 8px buffer)
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildCompactProjectCard(project, theme);
          },
        );
      },
      loading: () => _buildProjectsLoadingState(theme),
      error: (error, _) => _buildProjectsErrorState(theme, error.toString()),
    );
  }

  /// Build planned tasks list (renamed for clarity)
  Widget _buildPlannedTasksList(BuildContext context, ThemeData theme) {
    final allTasks = ref.watch(tasksProvider);

    return allTasks.when(
      data: (tasks) {
        // Filter future tasks (not today and not overdue)
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final futureTasks = tasks.where((task) {
          if (task.dueDate == null) return true; // Tasks without due date go to future
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          return taskDate.isAfter(today);
        }).toList();

        // Sort by priority and due date
        futureTasks.sort((a, b) {
          final priorityCompare = b.priority.index.compareTo(a.priority.index);
          if (priorityCompare != 0) return priorityCompare;

          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });

        if (futureTasks.isEmpty) {
          return _buildEmptyTasksList(theme, 'No future tasks', PhosphorIcons.clock());
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 160), // Bottom navigation bar + FAB clearance (80px + 72px FAB + 8px buffer)
          itemCount: futureTasks.length,
          itemBuilder: (context, index) {
            final task = futureTasks[index];
            return _buildCompactTaskCard(task, theme);
          },
        );
      },
      loading: () => _buildTasksLoadingState(theme),
      error: (error, _) => _buildTasksErrorState(theme, error.toString()),
    );
  }

  /// Get appropriate tertiary card style based on task state
  StandardizedCardStyle _getTaskCardStyle(TaskModel task, bool isOverdue) {
    if (task.isCompleted) {
      return StandardizedCardStyle.tertiarySuccess; // Completed tasks get success styling
    } else if (isOverdue) {
      return StandardizedCardStyle.tertiaryAccent; // Overdue tasks get attention-grabbing accent
    } else if (task.priority == TaskPriority.urgent) {
      return StandardizedCardStyle.tertiaryAccent; // High priority tasks get accent
    } else {
      return StandardizedCardStyle.tertiaryContainer; // Regular tasks get subtle container
    }
  }

  /// Sophisticated task card with golden ratio proportions and premium aesthetics
  Widget _buildCompactTaskCard(TaskModel task, ThemeData theme, {bool isOverdue = false}) {
    final balancedActions = SlidableActionService.getBalancedCompactTaskActions(
      task,
      colorScheme: theme.colorScheme,
      onComplete: () => _toggleTaskCompletion(task),
      onQuickEdit: () => _quickEditTask(task),
      onDelete: () => _confirmDeleteTask(task),
      onMore: () => _showMoreActions(task),
    );

    // Choose card style based on task state for enhanced visual hierarchy
    final cardStyle = _getTaskCardStyle(task, isOverdue);

    final cardContent = SizedBox(
      height: SpacingTokens.taskCardHeight, // Golden ratio optimized height
      child: StandardizedCard(
        style: cardStyle,
        onTap: () => AppRouter.navigateToTaskDetail(context, task.id),
        onLongPress: () => _showTaskContextMenu(context, task),
        margin: EdgeInsets.zero, // No margin - handled by parent
        padding: const EdgeInsets.all(SpacingTokens.taskCardPadding),
        child: Row(
          children: [
            // Sophisticated priority and category indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Priority indicator first - Elegant vertical accent bar
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: task.priority.color,
                    borderRadius:
                        BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy
                  ),
                ),
                const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                // Category icon container second
                if (task.tagIds.isNotEmpty) ...[
                  Builder(builder: (context) {
                    debugPrint('🎨 Showing category icon for task "${task.title}" with tags: ${task.tagIds}');
                    return const SizedBox.shrink();
                  }),
                  CategoryUtils.buildCategoryIconContainer(
                    category: task.tagIds.first,
                    size: 32,
                    theme: theme,
                    iconSizeRatio: 0.5,
                  ),
                  const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                ] else ...[
                  Builder(builder: (context) {
                    debugPrint('❌ No category icon for task "${task.title}" - tags: ${task.tagIds}');
                    return const SizedBox.shrink();
                  }),
                ],
              ],
            ),

            // Title and tags in the middle (takes up most space)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title row with audio indicator
                    Row(
                      children: [
                        Expanded(
                          child: StandardizedText(
                            task.title,
                            style: StandardizedTextStyle.labelLarge,
                            color: theme.colorScheme.onSurface,
                            decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                            lineHeight: 1.2,
                            letterSpacing: 0.1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Sophisticated audio indicator for voice tasks
                        if (task.hasVoiceMetadata) ...[
                          StandardizedGaps.hXs,
                          AudioIndicatorWidget(
                            task: task,
                            size: 20,
                            mode: AudioIndicatorMode.playButton,
                          ),
                        ],
                      ],
                    ),
                    // Tag chips row
                    if (task.tagIds.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final tagsProvider = ref.watch(tagsByIdsProvider(task.tagIds));
                          return tagsProvider.when(
                            data: (tags) => TagChipList(
                              tags: tags,
                              chipSize: TagChipSize.small,
                              maxChips: 4, // More tags for horizontal layout
                              spacing: 3.0,
                              onTagTap: (_) {}, // No action on tap for home cards
                            ),
                            loading: () => const SizedBox(
                              height: 16,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1),
                                  ),
                                ],
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Sophisticated completion indicator on the right
            if (task.status == TaskStatus.completed) ...[
              const SizedBox(width: 16), // 16px spacing
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: context.colors.withSemanticOpacity(context.successColor, SemanticOpacity.subtle),
                  borderRadius: StandardizedBorderRadius.sm,
                  border: Border.all(
                    color: context.colors.withSemanticOpacity(context.successColor, SemanticOpacity.light),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.check(),
                  size: 12,
                  color: context.successColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.taskCardMargin),
      child: SlidableThemeService.createBalancedCompactCardSlidable(
        key: ValueKey('compact-task-${task.id}'),
        groupTag: 'home-compact-cards',
        startActions: balancedActions['startActions'] ?? [],
        endActions: balancedActions['endActions'] ?? [],
        enableFastSwipe: true,
        context: context,
        child: cardContent,
      ),
    );
  }

  // Helper methods for compact card slide actions

  void _toggleTaskCompletion(TaskModel task) async {
    await SlidableFeedbackService.provideFeedback(SlidableActionType.complete);
    try {
      await ref.read(taskOperationsProvider).toggleTaskCompletion(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StandardizedText('Error updating task: $e', style: StandardizedTextStyle.bodyMedium)),
        );
      }
    }
  }

  void _quickEditTask(TaskModel task) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.edit);
    AppRouter.navigateToTaskDetail(context, task.id);
  }

  void _showMoreActions(TaskModel task) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    _showTaskContextMenu(context, task);
  }

  void _confirmDeleteTask(TaskModel task) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.destructive);
    _deleteTask(task);
  }

  /// Sophisticated project card with taller height and category-focused layout
  Widget _buildCompactProjectCard(Project project, ThemeData theme) {
    final projectStatsAsync = ref.watch(projectStatsProvider(project.id));

    // Project card content with increased height
    final cardContent = SizedBox(
      height: SpacingTokens.taskCardHeight * 1.4, // 40% taller than task cards
      child: StandardizedCard(
        style: StandardizedCardStyle.tertiaryContainer,
        onTap: () => _navigateToProjectDetail(project),
        onLongPress: () => _showProjectContextMenu(context, project),
        margin: EdgeInsets.zero, // No margin - handled by parent
        padding: const EdgeInsets.all(SpacingTokens.taskCardPadding),
        child: Row(
          children: [
            // Category icon on the left with color indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Project color indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(project.color.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                  ),
                ),
                const SizedBox(width: SpacingTokens.phi1),
                // Category icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(project.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    border: Border.all(
                      color: Color(int.parse(project.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    PhosphorIcons.folder(), // Default project icon
                    size: 20,
                    color: Color(int.parse(project.color.replaceFirst('#', '0xFF'))),
                  ),
                ),
                const SizedBox(width: SpacingTokens.phi1),
              ],
            ),

            // Project name and details in the middle (expanded layout)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Project name
                  StandardizedText(
                    project.name,
                    style: StandardizedTextStyle.titleMedium,
                    color: theme.colorScheme.onSurface,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Task count and progress
                  Row(
                    children: [
                      projectStatsAsync.when(
                        data: (stats) => Expanded(
                          child: StandardizedText(
                            '${stats.completedTasks}/${stats.totalTasks} tasks',
                            style: StandardizedTextStyle.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        loading: () => Expanded(
                          child: StandardizedText(
                            'Loading...',
                            style: StandardizedTextStyle.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        error: (_, __) => Expanded(
                          child: StandardizedText(
                            'Error loading stats',
                            style: StandardizedTextStyle.bodySmall,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      // Progress percentage badge on the right side of task info
                      projectStatsAsync.when(
                        data: (stats) {
                          final progressPercentage = stats.totalTasks > 0 
                              ? (stats.completedTasks / stats.totalTasks) 
                              : 0.0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(int.parse(project.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                            ),
                            child: StandardizedText(
                              '${(progressPercentage * 100).round()}%',
                              style: StandardizedTextStyle.labelSmall,
                              color: Color(int.parse(project.color.replaceFirst('#', '0xFF'))),
                            ),
                          );
                        },
                        loading: () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                          ),
                          child: StandardizedText(
                            '...',
                            style: StandardizedTextStyle.labelSmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        error: (_, __) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
                          ),
                          child: Icon(
                            PhosphorIcons.warning(),
                            size: 12,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Progress bar below text
                  projectStatsAsync.when(
                    data: (stats) {
                      final progressPercentage = stats.totalTasks > 0 
                          ? (stats.completedTasks / stats.totalTasks) 
                          : 0.0;
                      return LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(int.parse(project.color.replaceFirst('#', '0xFF'))),
                        ),
                        minHeight: 3,
                      );
                    },
                    loading: () => LinearProgressIndicator(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      minHeight: 3,
                    ),
                    error: (_, __) => Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                  // Project tags
                  if (project.tagIds.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Consumer(
                      builder: (context, ref, child) {
                        final tagsProvider = ref.watch(tagsByIdsProvider(project.tagIds));
                        return tagsProvider.when(
                          data: (tags) => TagChipList(
                            tags: tags,
                            chipSize: TagChipSize.small,
                            maxChips: 3, // More tags for project cards horizontal layout
                            spacing: 3.0,
                            onTagTap: (_) {}, // No action on tap for project cards
                          ),
                          loading: () => const SizedBox(
                            height: 16,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 1),
                                ),
                              ],
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Navigation arrow on the right
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: StandardizedBorderRadius.sm,
              ),
              child: Icon(
                PhosphorIcons.arrowRight(),
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with slidable for project actions
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.taskCardMargin),
      child: SlidableThemeService.createBalancedCompactCardSlidable(
        key: ValueKey('compact-project-${project.id}'),
        groupTag: 'home-compact-projects',
        startActions: [
          SlidableAction(
            onPressed: (context) => _quickEditProject(project),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: PhosphorIcons.pencil(),
            label: 'Edit',
          ),
        ],
        endActions: [
          SlidableAction(
            onPressed: (context) => _openProjectKanban(project),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: PhosphorIcons.kanban(),
            label: 'Kanban',
          ),
        ],
        enableFastSwipe: false, // Disable fast swipe for projects
        context: context,
        child: cardContent,
      ),
    );
  }

  /// Build progress indicator for task cards

  /// Build empty tasks list state
  Widget _buildEmptyTasksList(ThemeData theme, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StandardizedIcon(
            icon,
            size: StandardizedIconSize.xxxl,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          StandardizedText(
            message,
            style: StandardizedTextStyle.bodyLarge,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Build tasks loading state
  Widget _buildTasksLoadingState(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160), // Bottom navigation bar + FAB clearance (80px + 72px FAB + 8px buffer)
      itemCount: 3,
      itemBuilder: (context, index) => GlassmorphismContainer(
        level: GlassLevel.background,
        height: 80,
        margin: const EdgeInsets.only(bottom: 8),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Container(),
      ),
    );
  }

  /// Build tasks error state
  Widget _buildTasksErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          StandardizedText(
            'Error loading tasks',
            style: StandardizedTextStyle.bodyLarge,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  // Project helper methods

  void _navigateToProjectDetail(Project project) {
    AppRouter.navigateToProjectDetail(context, project.id);
  }

  void _openProjectKanban(Project project) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    // Navigate to project detail with Kanban view mode
    AppRouter.navigateToProjectDetail(context, project.id);
    // TODO: Add query parameter or navigation argument to open Kanban view specifically
  }

  void _quickEditProject(Project project) {
    SlidableFeedbackService.provideFeedback(SlidableActionType.edit);
    AppRouter.navigateToProjectDetail(context, project.id);
  }

  void _showProjectContextMenu(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
              child: const SizedBox(width: 40, height: 4),
            ),
            StandardizedGaps.md,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
              child: StandardizedText(
                project.name,
                style: StandardizedTextStyle.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StandardizedGaps.md,
            ListTile(
              leading: Icon(PhosphorIcons.folder()),
              title: const StandardizedText('View Project', style: StandardizedTextStyle.bodyMedium),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToProjectDetail(project);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.kanban()),
              title: const StandardizedText('Kanban Board', style: StandardizedTextStyle.bodyMedium),
              onTap: () {
                Navigator.of(context).pop();
                _openProjectKanban(project);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.pencil()),
              title: const StandardizedText('Edit Project', style: StandardizedTextStyle.bodyMedium),
              onTap: () {
                Navigator.of(context).pop();
                _quickEditProject(project);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty projects list state
  Widget _buildEmptyProjectsList(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StandardizedIcon(
            PhosphorIcons.folder(),
            size: StandardizedIconSize.xxxl,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          StandardizedText(
            'No active projects',
            style: StandardizedTextStyle.bodyLarge,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          StandardizedText(
            'Create a project to organize your tasks',
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// Build projects loading state
  Widget _buildProjectsLoadingState(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160), // Bottom navigation bar + FAB clearance (80px + 72px FAB + 8px buffer)
      itemCount: 3,
      itemBuilder: (context, index) => GlassmorphismContainer(
        level: GlassLevel.background,
        height: 80,
        margin: const EdgeInsets.only(bottom: 8),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Container(),
      ),
    );
  }

  /// Build projects error state
  Widget _buildProjectsErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          StandardizedText(
            'Error loading projects',
            style: StandardizedTextStyle.bodyLarge,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  /// Generate natural language task summary

  /// Build quick stat widget for improved density
  Widget _buildQuickStat({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          GlassmorphismContainer(
            level: GlassLevel.content,
            width: 32,
            height: 32,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
            glassTint: color.withValues(alpha: 0.15),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          StandardizedText(
            count.toString(),
            style: StandardizedTextStyle.titleLarge,
            color: theme.colorScheme.onSurface,
          ),
          StandardizedText(
            label,
            style: StandardizedTextStyle.bodySmall,
            color: theme.colorScheme.onSurfaceVariant,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build task insight for contextual information
  Widget _buildTaskInsight(ThemeData theme, int pendingCount, int urgentCount, int highCount) {
    String insight = '';
    Color insightColor = theme.colorScheme.onSurfaceVariant;
    IconData insightIcon = PhosphorIcons.info();

    if (urgentCount > 0) {
      insight = urgentCount == 1
          ? '1 urgent task needs immediate attention'
          : '$urgentCount urgent tasks need immediate attention';
      insightColor = theme.colorScheme.error;
      insightIcon = PhosphorIcons.arrowUp();
    } else if (highCount > 0) {
      insight = highCount == 1 ? '1 high priority task to focus on' : '$highCount high priority tasks to focus on';
      insightColor = theme.colorScheme.secondary;
      insightIcon = PhosphorIcons.caretUp();
    } else if (pendingCount > 0) {
      insight = 'Great progress! Stay focused on remaining tasks';
      insightColor = theme.colorScheme.primary;
      insightIcon = PhosphorIcons.trendUp();
    }

    if (insight.isEmpty) return const SizedBox.shrink();

    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(SpacingTokens.md * 0.75), // 12px
      borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
      glassTint: insightColor.withValues(alpha: 0.1),
      borderColor: insightColor.withValues(alpha: 0.3),
      borderWidth: 1.0,
      child: Row(
        children: [
          Icon(
            insightIcon,
            size: 16,
            color: insightColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StandardizedText(
              insight,
              style: StandardizedTextStyle.bodyMedium,
              color: insightColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search Dialog with Material 3 design
class SearchDialog extends ConsumerStatefulWidget {
  const SearchDialog({super.key});

  @override
  ConsumerState<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        glassTint: theme.colorScheme.surface,
        borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderWidth: 1.0,
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onSubmitted: (query) {
                ref.read(searchQueryProvider.notifier).state = query;
                Navigator.of(context).pop();
                AppRouter.navigateToRoute(context, AppRouter.tasks);
              },
            ),
            StandardizedGaps.md,
            StandardizedText(
              'Press Enter to search',
              style: StandardizedTextStyle.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
