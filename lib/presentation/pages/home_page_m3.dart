import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/voice_task_creation_dialog_m3.dart';
import '../widgets/manual_task_creation_dialog.dart';
import '../widgets/voice_only_creation_dialog.dart';
import '../widgets/advanced_task_card.dart';
import '../widgets/animated_priority_chip.dart';
import '../widgets/smart_text_widgets.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../widgets/enhanced_list_animations.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/task_providers.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/welcome_message_service.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/material3/motion_system.dart';
// Removed testing imports
import 'dart:math' as math;

/// Futuristic Material 3 Home Page
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium4,
      vsync: this,
    )..forward();
    
    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong2,
      vsync: this,
    )..forward();
    
    _slideController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    )..forward();
    
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Get welcome message and task summary data
  Map<String, dynamic> _getWelcomeData() {
    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    
    final pendingCount = pendingTasks.maybeWhen(data: (tasks) => tasks.length, orElse: () => 0);
    final completedCount = completedTasks.maybeWhen(data: (tasks) => tasks.length, orElse: () => 0);
    final totalCount = pendingCount + completedCount;
    
    final welcomeService = WelcomeMessageService();
    final welcomeMessage = welcomeService.getWelcomeMessage(
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
    };
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent to show background
      extendBodyBehindAppBar: true,
      appBar: StandardizedAppBar(
        title: 'Home',
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.search),
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
                    _buildWelcomeSection(context, theme),
                    const SizedBox(height: 16),
                    _buildAnalyticsCardsSection(context, theme),
                    const SizedBox(height: 16),
                    _buildTaskTabsSection(context, theme),
                  ],
                ),
              ),
            ),
            // Bottom padding to prevent FAB overlap
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTaskSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task search coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// REVAMPED: Clean Summary Card with Perfect Alignment - NO motivational content
  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: ExpressiveMotionSystem.emphasizedDecelerate,
      )),
      child: GlassmorphismContainer(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        padding: const EdgeInsets.all(20.0),
        child: Builder(builder: (context) {
          final welcomeData = _getWelcomeData();
          final pendingCount = welcomeData['pendingCount'] as int;
          final completedCount = welcomeData['completedCount'] as int;
          final totalTasks = pendingCount + completedCount;
          final completionRate = totalTasks > 0 ? (completedCount / totalTasks * 100).toInt() : 0;
          
          // Get task data for summary
          final pendingTasks = ref.watch(pendingTasksProvider);
          final urgentCount = pendingTasks.maybeWhen(
            data: (tasks) => tasks.where((task) => task.priority == TaskPriority.urgent).length,
            orElse: () => 0,
          );
          final highCount = pendingTasks.maybeWhen(
            data: (tasks) => tasks.where((task) => task.priority == TaskPriority.high).length,
            orElse: () => 0,
          );
          
          // Generate natural task summary text
          String taskSummaryText = _generateTaskSummary(pendingCount, urgentCount, highCount, completedCount);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Welcome Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.waving_hand,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getTimeOfDay()}!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Here\'s your task overview',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Task Summary Text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  taskSummaryText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  /// Helper method to build individual summary stat items with perfect alignment
  Widget _buildSummaryStatItem({
    required ThemeData theme,
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20.0,
            color: color,
          ),
          const SizedBox(height: 6.0),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: TypographyConstants.titleMedium,
              fontWeight: TypographyConstants.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: TypographyConstants.labelSmall,
              fontWeight: TypographyConstants.medium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildAnalyticsCardsSection(BuildContext context, ThemeData theme) {
    final pendingTasks = ref.watch(pendingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    
    final statCards = [
      _buildStatCard(
        theme: theme,
        title: 'Pending',
        count: pendingTasks.maybeWhen(
          data: (tasks) => tasks.length,
          orElse: () => 0,
        ),
        icon: Icons.pending_actions,
        gradient: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.7),
        ],
        onTap: () => AppRouter.navigateToRoute(context, AppRouter.tasks),
      ),
      _buildStatCard(
        theme: theme,
        title: 'Today',
        count: todayTasks.maybeWhen(
          data: (tasks) => tasks.length,
          orElse: () => 0,
        ),
        icon: Icons.today,
        gradient: [
          theme.colorScheme.secondary,
          theme.colorScheme.secondary.withOpacity(0.7),
        ],
        onTap: () => AppRouter.navigateToRoute(context, AppRouter.calendar),
      ),
      _buildStatCard(
        theme: theme,
        title: 'Done',
        count: completedTasks.maybeWhen(
          data: (tasks) => tasks.length,
          orElse: () => 0,
        ),
        icon: Icons.check_circle,
        gradient: [
          theme.colorScheme.tertiary,
          theme.colorScheme.tertiary.withOpacity(0.7),
        ],
        onTap: () => AppRouter.navigateToRoute(context, AppRouter.analytics),
      ),
    ];
    
    return Row(
      children: [
        for (int i = 0; i < statCards.length; i++) ...[
          Expanded(
            child: AnimatedListItem(
              pattern: AnimationPattern.scale,
              duration: Duration(milliseconds: 300 + (i * 100)),
              child: statCards[i],
            ),
          ),
          if (i < statCards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
  
  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required int count,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismContainer(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge),
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 60, // Reduced height since padding is handled by glassmorphism
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: gradient.first, size: 16),
                  Text(
                    count.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: TypographyConstants.bodyMedium,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: TypographyConstants.labelSmall,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentTasksSection(BuildContext context, ThemeData theme) {
    final allTasks = ref.watch(tasksProvider);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Tasks',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: TypographyConstants.bodyLarge,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => AppRouter.navigateToRoute(context, AppRouter.tasks),
                child: Text('View All', style: TextStyle(fontSize: TypographyConstants.bodySmall)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          allTasks.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return _buildEmptyState(theme);
              }
              
              final recentTasks = tasks.take(4).toList();
              
              return EnhancedStaggeredListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                pattern: AnimationPattern.slideUp,
                itemDelay: const Duration(milliseconds: 100),
                children: recentTasks.map((task) => 
                  AdvancedTaskCard(
                    task: task,
                    margin: const EdgeInsets.only(bottom: 8),
                    onTap: () => AppRouter.navigateToTaskDetail(context, task.id),
                    onEdit: () => _editTask(task),
                    onDelete: () => _deleteTask(task),
                    onShare: () => _shareTask(task),
                    showProgress: true,
                    showSubtasks: true,
                    style: TaskCardStyle.elevated,
                  )
                ).toList(),
              );
            },
            loading: () => _buildLoadingState(theme),
            error: (error, _) => _buildErrorState(theme, error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to get started?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
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
        Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000 + (index * 200)),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.primary.withOpacity(0.1),
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
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
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
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _editTask(TaskModel task) {
    // TODO: Navigate to edit task screen
    AppRouter.navigateToTaskDetail(context, task.id);
  }

  void _deleteTask(TaskModel task) {
    // TODO: Show confirmation dialog and delete task
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Delete task through provider
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareTask(TaskModel task) {
    // TODO: Implement task sharing
  }
  
  Widget _buildTaskItem(TaskModel task, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            AppRouter.taskDetail,
            arguments: task.id,
          ),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                  theme.colorScheme.secondaryContainer.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: task.status == TaskStatus.completed,
                  onChanged: (value) {
                    ref.read(taskOperationsProvider).toggleTaskCompletion(task);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        ),
                      ),
                      if (task.dueDate != null)
                        Text(
                          'Due ${_formatDueDate(task.dueDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  theme: theme,
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  gradient: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                  ],
                  onPressed: () => AppRouter.navigateToRoute(context, AppRouter.calendar),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: Border.all(
              color: gradient.first.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: gradient.first),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: gradient.first,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }
  
  /// Build task tabs section with Today's, Overdue, and Future Tasks
  /// FIXED: Perfect Tab Selection with Horizontal Scroll and Proper Logic
  Widget _buildTaskTabsSection(BuildContext context, ThemeData theme) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Tab Bar with Perfect Padding and Horizontal Scroll
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 48.0,  // Fixed height for consistent alignment
            child: TabBar(
              // FIXED: Perfect selection indicator
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),  // Standardized 5px
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              
              // FIXED: Proper colors and styling
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              
              // FIXED: Perfect horizontal scrolling
              isScrollable: true,
              tabAlignment: TabAlignment.start,  // Align tabs to start for better UX
              
              // FIXED: Perfect padding and spacing
              labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),  // Consistent padding
              padding: const EdgeInsets.all(4.0),  // Inner container padding
              
              tabs: [
                _buildFixedTab(
                  icon: Icons.today_outlined,
                  selectedIcon: Icons.today,
                  label: 'Today',
                  theme: theme,
                ),
                _buildFixedTab(
                  icon: Icons.warning_amber_outlined,
                  selectedIcon: Icons.warning_amber,
                  label: 'Overdue',
                  theme: theme,
                ),
                _buildFixedTab(
                  icon: Icons.schedule_outlined,
                  selectedIcon: Icons.schedule,
                  label: 'Future',
                  theme: theme,
                ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab content with proper FAB padding
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5, // Responsive height
            child: TabBarView(
              children: [
                _buildTodayTasksList(context, theme),
                _buildOverdueTasksList(context, theme),
                _buildFutureTasksList(context, theme),
              ],
            ),
          ),
          
          // Bottom padding to prevent FAB overlap
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  /// FIXED: Helper method to build perfectly aligned tab with proper padding and icons
  Widget _buildFixedTab({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required ThemeData theme,
  }) {
    return Tab(
      height: 40.0,  // Fixed height for consistency
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),  // Perfect padding
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,  // Will show selected/unselected based on tab state
              size: 18.0,  // Consistent icon size
            ),
            const SizedBox(width: 8.0),  // Perfect spacing between icon and text
            Text(
              label,
              style: TextStyle(
                fontSize: TypographyConstants.labelLarge,  // Fixed: Using new font size
                fontWeight: TypographyConstants.medium,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,  // Handle long text gracefully
            ),
          ],
        ),
      ),
    );
  }

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
              return _buildEmptyTasksList(theme, 'No tasks for today', Icons.today);
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

  /// Build overdue tasks list
  Widget _buildOverdueTasksList(BuildContext context, ThemeData theme) {
    final overdueTasks = ref.watch(overdueTasksProvider);
    
    return overdueTasks.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyTasksList(theme, 'No overdue tasks', Icons.check_circle);
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

  /// Build future tasks list
  Widget _buildFutureTasksList(BuildContext context, ThemeData theme) {
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
          return _buildEmptyTasksList(theme, 'No future tasks', Icons.schedule);
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

  /// Build compact task card
  Widget _buildCompactTaskCard(TaskModel task, ThemeData theme, {bool isOverdue = false}) {
    return Container(
      height: 80, // Smaller card height as specified
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          // Main card container
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: double.infinity,
              height: 80,
            child: InkWell(
              onTap: () => AppRouter.navigateToTaskDetail(context, task.id),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Task completion checkbox
                    Checkbox(
                      value: task.status == TaskStatus.completed,
                      onChanged: (value) {
                        // TODO: Toggle task completion
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Task content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Task title (16-18dp as specified)
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: TypographyConstants.bodyLarge,
                              decoration: task.status == TaskStatus.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 2),
                          
                          // Task description and due date
                          Row(
                            children: [
                              if (task.description?.isNotEmpty == true) ...[
                                Expanded(
                                  child: Text(
                                    task.description!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: TypographyConstants.bodySmall,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              if (task.dueDate != null) ...[
                                if (task.description?.isNotEmpty == true) const SizedBox(width: 8),
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _formatDueDate(task.dueDate!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: TypographyConstants.labelSmall,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Add some space on the right for the priority circle
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
            ),
          ),
          
          // Priority circle badge on top right corner
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getPriorityColor(task.priority).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getPriorityIcon(task.priority),
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get priority color for the circular badge
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.deepPurple;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  /// Get priority icon for the circular badge
  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Icons.priority_high;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

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
      itemBuilder: (context, index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        ),
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
            Icons.error_outline,
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

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }

  /// Generate natural language task summary
  String _generateTaskSummary(int pendingCount, int urgentCount, int highCount, int completedCount) {
    List<String> parts = [];
    
    // Today's tasks
    if (pendingCount > 0) {
      parts.add('Today you have $pendingCount pending task${pendingCount != 1 ? 's' : ''}');
      
      if (urgentCount > 0 || highCount > 0) {
        List<String> priorityParts = [];
        if (urgentCount > 0) {
          priorityParts.add('$urgentCount urgent');
        }
        if (highCount > 0) {
          priorityParts.add('$highCount high priority');
        }
        parts.add('out of which ${priorityParts.join(' and ')} task${(urgentCount + highCount) != 1 ? 's are' : ' is'} critical');
      }
    } else {
      parts.add('Great! You have no pending tasks today');
    }
    
    // Yesterday's completion (simulated)
    if (completedCount > 0) {
      parts.add('Yesterday you completed $completedCount task${completedCount != 1 ? 's' : ''}');
    } else {
      parts.add('ready to tackle today with a fresh start');
    }
    
    return parts.join(pendingCount > 0 ? ', ' : ' and ') + '.';
  }

  /// Get time-based greeting
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
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
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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