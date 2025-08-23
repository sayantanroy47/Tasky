import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/simple_theme_toggle.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/enhanced_glass_button.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';

import '../providers/task_providers.dart';
import '../providers/profile_providers.dart';
import '../../core/providers/core_providers.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/welcome_message_service.dart';
import '../../core/routing/app_router.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Futuristic Material 3 Home Page
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Get welcome message and task summary data
  Map<String, dynamic> _getWelcomeData() {
    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    
    final pendingCount = pendingTasks.maybeWhen(data: (tasks) => tasks.length, orElse: () => 0);
    final completedCount = completedTasks.maybeWhen(data: (tasks) => tasks.length, orElse: () => 0);
    final totalCount = pendingCount + completedCount;
    
    // Get user's first name from profile
    final firstName = profileAsync.maybeWhen(
      data: (profile) => profile?.firstName,
      orElse: () => null,
    );
    
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
    
    return {
      'welcomeMessage': welcomeMessage,
      'taskSummary': taskSummary,
      'pendingCount': pendingCount,
      'completedCount': completedCount,
      'firstName': firstName,
    };
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
                padding: const EdgeInsets.all(16.0),
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
            // Enhanced bottom padding to prevent FAB overlap and ensure last task visibility
            const SliverToBoxAdapter(
              child: SizedBox(height: 140), // Increased from 120 to accommodate larger FAB
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search Tasks',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
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
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (value) => searchQuery = value,
                ),
            ),
            const SizedBox(height: 16),
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
                        child: Text('No tasks found for "$searchQuery"'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return ListTile(
                          title: Text(task.title),
                          subtitle: task.description?.isNotEmpty == true ? Text(task.description!) : null,
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
                                  title: const Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'share',
                                child: ListTile(
                                  leading: Icon(PhosphorIcons.share()),
                                  title: const Text('Share'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(PhosphorIcons.trash()),
                                  title: const Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
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
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: double.maxFinite,
              maxHeight: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Insights',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final allTasks = ref.watch(tasksProvider);
                      return allTasks.when(
                        data: (tasks) {
                          final completedTasks = tasks.where((t) => t.isCompleted).length;
                          final pendingTasks = tasks.where((t) => !t.isCompleted).length;
                          final urgentTasks = tasks.where((t) => t.priority == TaskPriority.urgent && !t.isCompleted).length;
                          final overdueTasks = tasks.where((t) {
                            if (t.dueDate == null || t.isCompleted) return false;
                            return t.dueDate!.isBefore(DateTime.now());
                          }).length;
                          
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInsightRow('Total Tasks', '${tasks.length}', PhosphorIcons.list()),
                                _buildInsightRow('Completed', '$completedTasks', PhosphorIcons.checkCircle(), color: Colors.green),
                                _buildInsightRow('Pending', '$pendingTasks', PhosphorIcons.clock(), color: Colors.orange),
                                _buildInsightRow('Urgent', '$urgentTasks', PhosphorIcons.arrowUp(), color: Colors.red),
                                _buildInsightRow('Overdue', '$overdueTasks', PhosphorIcons.warning(), color: Colors.red),
                              ],
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(child: Text('Error: $error')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: EnhancedGlassButton.secondary(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  void _showTaskContextMenu(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(2),
              child: const SizedBox(
                width: 40,
                height: 4,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(PhosphorIcons.pencil()),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.of(context).pop();
                _editTask(task);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIcons.share()),
              title: const Text('Share Task'),
              onTap: () {
                Navigator.of(context).pop();
                _shareTask(task);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(PhosphorIcons.trash(), color: Colors.red),
              title: const Text('Delete Task', style: TextStyle(color: Colors.red)),
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
    return GlassmorphismContainer(
      level: GlassLevel.whisper,  // Ultra-subtle background for elegance
      borderRadius: BorderRadius.circular(BorderRadiusTokens.card),
      padding: const EdgeInsets.all(SpacingTokens.elementPadding),
      child: Builder(builder: (context) {
        final welcomeData = _getWelcomeData();
        final welcomeMessage = welcomeData['welcomeMessage'] as WelcomeMessage;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personalized welcome greeting
            Row(
              children: [
                if (welcomeMessage.icon != null) ...[
                  Icon(
                    welcomeMessage.icon!,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    welcomeMessage.greeting,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 24.0,              // Premium display size
                      fontWeight: FontWeight.w300, // Light weight for sophistication
                      height: 1.3,                 // Refined line height
                      letterSpacing: -0.2,         // Tighter for elegance
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SpacingTokens.phi1), // Golden ratio spacing
            
            // Personalized subtitle (replacing the removed secondary text)
            Text(
              welcomeMessage.subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 15.0,              // Refined size for readability
                fontWeight: FontWeight.w400, // Regular weight
                height: 1.5,                 // Relaxed for scanning
                letterSpacing: 0.1,          // Slight spacing for clarity
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
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
        final todayTasks = tasks.where((task) => 
          !task.isCompleted && 
          (task.dueDate == null || task.dueDate!.isAfter(todayStart)) &&
          (task.dueDate == null || task.dueDate!.isBefore(todayEnd))
        ).toList();
        
        final pendingCount = todayTasks.length;
        final urgentCount = todayTasks.where((t) => t.priority == TaskPriority.urgent).length;
        final highCount = todayTasks.where((t) => t.priority == TaskPriority.high).length;
        final completedToday = tasks.where((task) => 
          task.isCompleted && 
          task.completedAt != null &&
          task.completedAt!.isAfter(todayStart) &&
          task.completedAt!.isBefore(todayEnd)
        ).length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Row
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
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
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
            borderRadius: BorderRadius.circular(100), // Make it circular
            padding: const EdgeInsets.all(24),
            glassTint: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            child: Icon(
              PhosphorIcons.rocket(),
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to get started?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first task',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
      children: List.generate(3, (index) => 
        GlassmorphismContainer(
          level: GlassLevel.background,
          height: 120,
          margin: const EdgeInsets.only(bottom: 8),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000 + (index * 200)),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  Colors.transparent,
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
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load tasks',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.refresh(tasksProvider),
            icon: Icon(PhosphorIcons.arrowClockwise()),
            label: const Text('Retry'),
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
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Task',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete "${task.title}"?',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EnhancedGlassButton.secondary(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  EnhancedGlassButton(
                    onPressed: () async {
                      // Delete task through provider
                      await ref.read(taskRepositoryProvider).deleteTask(task.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task "${task.title}" deleted'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    glassTint: Theme.of(context).colorScheme.error,
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
  
  /// Sophisticated task tabs with text-only elegance and positive psychology
  Widget _buildTaskTabsSection(BuildContext context, ThemeData theme) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sophisticated tab bar with elegant styling
          Container(
            height: 56, // Increased for touch accessibility
            padding: const EdgeInsets.all(4), // 4px padding
            child: TabBar(
              // Sophisticated gradient indicator for premium feel
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
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
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              
              // Elegant text styling
              labelStyle: const TextStyle(
                fontSize: 16, // titleMedium for clarity
                fontWeight: FontWeight.w400, // Regular weight for sophistication
                letterSpacing: 0.1, // Subtle letter spacing
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300, // Light weight for unselected
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
                  label: 'Focus tasks tab', // Positive psychology
                  hint: 'View tasks requiring focus',
                  button: true,
                  child: const Tab(text: 'Focus'), // Renamed from 'Overdue' for positive psychology
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
          const SizedBox(height: SpacingTokens.tabSpacing), // Golden ratio spacing
          
          // Task content prioritized - increased from 65% to 75% of screen height
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75, // More space for tasks
            child: TabBarView(
              children: [
                _buildTodayTasksList(context, theme),
                _buildFocusTasksList(context, theme), // Renamed for positive psychology
                _buildPlannedTasksList(context, theme), // Renamed for clarity
              ],
            ),
          ),
          
          // Enhanced bottom padding to prevent FAB overlap with larger FAB
          const SizedBox(height: 120),
        ],
      ),
    );
  }
  
  // Removed _buildFixedTab method - using simple text-only tabs for sophistication

  /// Build today's tasks list
  Widget _buildTodayTasksList(BuildContext context, ThemeData theme) {
    final todayDueTasks = ref.watch(todayTasksProvider);
    final todayCreatedTasks = ref.watch(tasksCreatedTodayProvider);
    
    return todayDueTasks.when(
      data: (dueTasks) {
        return todayCreatedTasks.when(
          data: (createdTasks) {
            // Combine tasks due today and created today, removing duplicates
            final allTodayTasks = <TaskModel>{
              ...dueTasks,
              ...createdTasks,
            }.toList();
            
            if (allTodayTasks.isEmpty) {
              return _buildEmptyTasksList(theme, 'No tasks for today', PhosphorIcons.calendar());
            }
            
            // Sort by priority and creation time
            allTodayTasks.sort((a, b) {
              final priorityComparison = b.priority.index.compareTo(a.priority.index);
              if (priorityComparison != 0) return priorityComparison;
              return b.createdAt.compareTo(a.createdAt);
            });
            
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // FAB clearance
              itemCount: allTodayTasks.length,
              itemBuilder: (context, index) {
                final task = allTodayTasks[index];
                return _buildCompactTaskCard(task, theme);
              },
            );
          },
          loading: () => dueTasks.isEmpty 
            ? _buildTasksLoadingState(theme)
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // FAB clearance
                itemCount: dueTasks.length,
                itemBuilder: (context, index) {
                  final task = dueTasks[index];
                  return _buildCompactTaskCard(task, theme);
                },
              ),
          error: (error, stack) => dueTasks.isEmpty 
            ? _buildErrorState(theme, 'Failed to load today\'s tasks')
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // FAB clearance
                itemCount: dueTasks.length,
                itemBuilder: (context, index) {
                  final task = dueTasks[index];
                  return _buildCompactTaskCard(task, theme);
                },
              ),
        );
      },
      loading: () => _buildTasksLoadingState(theme),
      error: (error, _) => _buildTasksErrorState(theme, error.toString()),
    );
  }

  /// Build focus tasks list (renamed for positive psychology)
  Widget _buildFocusTasksList(BuildContext context, ThemeData theme) {
    final overdueTasks = ref.watch(overdueTasksProvider);
    
    return overdueTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyTasksList(theme, 'No overdue tasks', PhosphorIcons.checkCircle());
        }
        
        // Sort by priority and how overdue they are
        tasks.sort((a, b) {
          final priorityCompare = b.priority.index.compareTo(a.priority.index);
          if (priorityCompare != 0) return priorityCompare;
          
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!); // Most overdue first
        });
        
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // FAB clearance
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildCompactTaskCard(task, theme, isOverdue: true);
          },
        );
      },
      loading: () => _buildTasksLoadingState(theme),
      error: (error, _) => _buildTasksErrorState(theme, error.toString()),
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
          padding: const EdgeInsets.only(bottom: 80), // FAB clearance
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

  /// Sophisticated task card with golden ratio proportions and premium aesthetics
  Widget _buildCompactTaskCard(TaskModel task, ThemeData theme, {bool isOverdue = false}) {
    return Container(
      height: SpacingTokens.taskCardHeight, // Golden ratio optimized height
      margin: const EdgeInsets.only(bottom: SpacingTokens.taskCardMargin), // 8px margin
      child: GlassmorphismContainer(
        level: GlassLevel.whisper, // Ultra-subtle for sophisticated task focus
        borderRadius: BorderRadius.circular(SpacingTokens.taskCardRadius), // Sophisticated corner radius
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => AppRouter.navigateToTaskDetail(context, task.id),
          onLongPress: () => _showTaskContextMenu(context, task),
          borderRadius: BorderRadius.circular(SpacingTokens.taskCardRadius),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.taskCardPadding), // Golden ratio padding
            child: Row(
              children: [
                // Sophisticated category indicator with icon and accent bar
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Elegant vertical accent bar
                    Container(
                      width: 4,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default'),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                    // Sophisticated category icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default').withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default').withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(task.tags.isNotEmpty ? task.tags.first : 'default'),
                        size: 16,
                        color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default'),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.phi1), // Golden ratio spacing
                  ],
                ),
                
                // Title and description in the middle (takes up most space)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Task title with audio indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500, // Sophisticated medium weight
                                color: theme.colorScheme.onSurface,
                                decoration: task.status == TaskStatus.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                height: 1.3, // Refined line height for readability
                                letterSpacing: 0.1, // Subtle letter spacing for elegance
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Sophisticated audio indicator for voice tasks
                          if (task.hasVoiceMetadata) ...[
                            const SizedBox(width: 4), // 4px spacing
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                PhosphorIcons.waveform(),
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // Elegant task metadata - priority only for sophisticated simplicity
                      if (task.priority != TaskPriority.medium) ...[
                        const SizedBox(height: 4), // 4px spacing
                        Row(
                          children: [
                            Icon(
                              task.priority == TaskPriority.urgent
                                  ? PhosphorIcons.arrowUp()
                                  : PhosphorIcons.caretUp(),
                              size: 12,
                              color: task.priority == TaskPriority.urgent
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4), // 4px spacing
                            Text(
                              task.priority.name.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: task.priority == TaskPriority.urgent
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.secondary,
                                letterSpacing: 0.5, // Wide letter spacing for labels
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Sophisticated completion indicator on the right
                if (task.status == TaskStatus.completed) ...[
                  const SizedBox(width: 16), // 16px spacing
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      PhosphorIcons.check(),
                      size: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }



  /// Get category-based icon for task cards
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return PhosphorIcons.briefcase();
      case 'personal':
        return PhosphorIcons.user();
      case 'shopping':
        return PhosphorIcons.shoppingCart();
      case 'health':
        return PhosphorIcons.heartbeat();
      case 'fitness':
        return PhosphorIcons.barbell();
      case 'finance':
        return PhosphorIcons.wallet();
      case 'education':
        return PhosphorIcons.graduationCap();
      case 'travel':
        return PhosphorIcons.airplane();
      case 'home':
        return PhosphorIcons.house();
      case 'family':
        return PhosphorIcons.users();
      case 'entertainment':
        return PhosphorIcons.filmStrip();
      case 'food':
        return PhosphorIcons.forkKnife();
      case 'project':
        return PhosphorIcons.folder();
      case 'meeting':
        return PhosphorIcons.door();
      case 'call':
        return PhosphorIcons.phone();
      case 'email':
        return PhosphorIcons.envelope();
      case 'urgent':
        return PhosphorIcons.warningCircle();
      case 'important':
        return PhosphorIcons.star();
      default:
        return PhosphorIcons.checkSquare();
    }
  }

  /// Get category-based color for task cards
  Color _getCategoryColor(String category) {
    final theme = Theme.of(context);
    
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF1976D2); // Blue
      case 'personal':
        return const Color(0xFF388E3C); // Green
      case 'shopping':
        return const Color(0xFFFF9800); // Orange
      case 'health':
        return const Color(0xFFE91E63); // Pink
      case 'fitness':
        return const Color(0xFF8BC34A); // Light Green
      case 'finance':
        return const Color(0xFF4CAF50); // Green
      case 'education':
        return const Color(0xFF3F51B5); // Indigo
      case 'travel':
        return const Color(0xFF00BCD4); // Cyan
      case 'home':
        return const Color(0xFF795548); // Brown
      case 'family':
        return const Color(0xFFFF5722); // Deep Orange
      case 'entertainment':
        return const Color(0xFF9C27B0); // Purple
      case 'food':
        return const Color(0xFFFF9800); // Orange
      case 'project':
        return const Color(0xFF607D8B); // Blue Grey
      case 'meeting':
        return const Color(0xFF673AB7); // Deep Purple
      case 'call':
        return const Color(0xFF2196F3); // Blue
      case 'email':
        return const Color(0xFF009688); // Teal
      case 'urgent':
        return const Color(0xFFF44336); // Red
      case 'important':
        return const Color(0xFFFFEB3B); // Yellow
      default:
        return theme.colorScheme.primary; // Default theme color
    }
  }

  /// Build progress indicator for task cards

  /// Build empty tasks list state
  Widget _buildEmptyTasksList(ThemeData theme, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tasks loading state
  Widget _buildTasksLoadingState(ThemeData theme) {
    return ListView.builder(
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
          Text(
            'Error loading tasks',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
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
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: TypographyConstants.textLG,
              fontWeight: TypographyConstants.medium,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: TypographyConstants.textXS,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
      insight = highCount == 1
        ? '1 high priority task to focus on'
        : '$highCount high priority tasks to focus on';
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
      padding: const EdgeInsets.all(12),
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
            child: Text(
              insight,
              style: TextStyle(
                fontSize: TypographyConstants.textSM,
                color: insightColor,
                fontWeight: TypographyConstants.medium,
              ),
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
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
            Text(
              'Press Enter to search',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


