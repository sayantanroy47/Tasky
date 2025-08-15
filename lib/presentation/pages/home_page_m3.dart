import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Temporarily disabled
import '../widgets/standardized_app_bar.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/advanced_task_card.dart';
import '../widgets/audio_widgets.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/status_badge_widget.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;
import '../../core/theme/material3/motion_system.dart';
import '../widgets/enhanced_list_animations.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/task_providers.dart';
import '../../core/providers/core_providers.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/welcome_message_service.dart';
import '../../core/routing/app_router.dart';

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
    
    _scrollController = ScrollController();
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
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent to show background
      extendBodyBehindAppBar: true, // Show phone status bar
      appBar: StandardizedAppBar(
        title: 'Home',
        forceBackButton: false, // Home is main tab - no back button
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
                    const SizedBox(height: 20),
                    _buildTodayTasksSummarySection(context, theme),
                    const SizedBox(height: 20),
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
        level: GlassLevel.content, // Use content level for welcome section
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        padding: const EdgeInsets.all(20.0),
        child: Builder(builder: (context) {
          final welcomeData = _getWelcomeData();
          final pendingCount = welcomeData['pendingCount'] as int;
          final completedCount = welcomeData['completedCount'] as int;
          
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
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Here\'s your task overview',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Text-based Task Summary with Bullets
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Header
                    Row(
                      children: [
                        Icon(
                          Icons.summarize,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Today\'s Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bulleted Summary Text
                    _buildBulletPoint(
                      theme: theme,
                      icon: Icons.circle,
                      iconColor: theme.colorScheme.primary,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300, // Light weight but readable
                        height: 1.3, // Better line height for readability
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'Roboto', // Force standard font to bypass theme
                        inherit: false, // Don't inherit theme properties
                      ),
                      text: pendingCount == 0 
                          ? 'All tasks are completed - great job!'
                          : pendingCount == 1
                              ? '1 task is pending completion'
                              : '$pendingCount tasks are pending completion',
                    ),
                    
                    if (urgentCount > 0) ...[
                      _buildBulletPoint(
                        theme: theme,
                        icon: Icons.priority_high,
                        iconColor: theme.colorScheme.error,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300, // Light weight but readable
                          height: 1.3, // Better line height for readability
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'Roboto', // Force standard font to bypass theme
                          inherit: false, // Don't inherit theme properties
                        ),
                        text: urgentCount == 1
                            ? '1 urgent task requires immediate attention'
                            : '$urgentCount urgent tasks require immediate attention',
                      ),
                    ],
                    
                    if (highCount > 0) ...[
                      _buildBulletPoint(
                        theme: theme,
                        icon: Icons.arrow_upward,
                        iconColor: theme.colorScheme.tertiary,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300, // Light weight but readable
                          height: 1.3, // Better line height for readability
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'Roboto', // Force standard font to bypass theme
                          inherit: false, // Don't inherit theme properties
                        ),
                        text: highCount == 1
                            ? '1 high-priority task needs focus'
                            : '$highCount high-priority tasks need focus',
                      ),
                    ],
                    
                    if (completedCount > 0) ...[
                      _buildBulletPoint(
                        theme: theme,
                        icon: Icons.check_circle,
                        iconColor: theme.colorScheme.tertiary,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300, // Light weight but readable
                          height: 1.3, // Better line height for readability
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'Roboto', // Force standard font to bypass theme
                          inherit: false, // Don't inherit theme properties
                        ),
                        text: completedCount == 1
                            ? '1 task completed today'
                            : '$completedCount tasks completed today',
                      ),
                    ],
                    
                    // Motivational message if all done
                    if (pendingCount == 0 && urgentCount == 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                          border: Border.all(
                            color: theme.colorScheme.tertiary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 16,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You\'re all caught up! Time to relax or plan ahead.',
                                style: TextStyle(
                                  fontSize: TypographyConstants.textXS,
                                  color: theme.colorScheme.tertiary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
  Widget _buildTodayTasksSummarySection(BuildContext context, ThemeData theme) {
    final allTasks = ref.watch(tasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    
    final summaryCards = [
      // Card 1: Completion Streak
      _buildTodaySummaryCard(
        theme: theme,
        title: 'Streak',
        subtitle: _getCompletionStreakText(completedTasks),
        count: _getCompletionStreakDays(completedTasks),
        icon: Icons.local_fire_department,
        iconColor: Colors.orange,
        onTap: () => AppRouter.navigateToRoute(context, AppRouter.analytics),
      ),
      
      // Card 2: Total Completed Tasks
      _buildTodaySummaryCard(
        theme: theme,
        title: 'Finished',
        subtitle: _getTotalCompletedText(completedTasks),
        count: 2, // Show fixed count of 2
        icon: Icons.task_alt,
        iconColor: Colors.green,
        onTap: () => AppRouter.navigateToRoute(context, AppRouter.analytics),
      ),
      
      // Card 3: Weekly Progress
      _buildTodaySummaryCard(
        theme: theme,
        title: 'This Week',
        subtitle: _getWeeklyProgressText(allTasks, completedTasks),
        count: _getWeeklyCompletionPercentage(allTasks, completedTasks),
        icon: Icons.trending_up,
        iconColor: Colors.blue,
        onTap: () => AppRouter.navigateToRoute(context, AppRouter.analytics),
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Summary cards
        Row(
          children: [
            for (int i = 0; i < summaryCards.length; i++) ...[
              Expanded(
                child: AnimatedListItem(
                  pattern: AnimationPattern.slideUp,
                  duration: Duration(milliseconds: 300 + (i * 150)),
                  child: summaryCards[i],
                ),
              ),
              if (i < summaryCards.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
  
  // Helper methods for new summary cards
  
  int _getCompletionStreakDays(AsyncValue<List<TaskModel>> completedTasksAsync) {
    return completedTasksAsync.maybeWhen(
      data: (tasks) {
        int streak = 0;
        final now = DateTime.now();
        
        // Check each day backwards from today
        for (int i = 0; i < 30; i++) { // Check last 30 days maximum
          final checkDate = now.subtract(Duration(days: i));
          final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
          final dayEnd = dayStart.add(const Duration(days: 1));
          
          final hasCompletedTask = tasks.any((task) => 
            task.completedAt != null &&
            task.completedAt!.isAfter(dayStart) &&
            task.completedAt!.isBefore(dayEnd)
          );
          
          if (hasCompletedTask) {
            streak++;
          } else if (i > 0) { // Don't break streak for today if it's still early
            break;
          }
        }
        
        return streak;
      },
      orElse: () => 0,
    );
  }
  
  String _getCompletionStreakText(AsyncValue<List<TaskModel>> completedTasksAsync) {
    final streak = _getCompletionStreakDays(completedTasksAsync);
    if (streak == 0) return 'Start today!';
    if (streak == 1) return 'Keep it up!';
    if (streak < 7) return 'Building momentum';
    if (streak < 30) return 'On fire!';
    return 'Unstoppable!';
  }
  
  Color _getStreakIconColor(ThemeData theme, int streak) {
    if (streak == 0) return theme.colorScheme.outline;
    if (streak < 3) return theme.colorScheme.primary;
    if (streak < 7) return theme.colorScheme.secondary;
    return theme.colorScheme.error; // Fire color for hot streaks
  }
  
  /// Get total completed tasks count
  int _getTotalCompletedCount(AsyncValue<List<TaskModel>> completedTasksAsync) {
    return completedTasksAsync.maybeWhen(
      data: (tasks) => tasks.length,
      orElse: () => 0,
    );
  }
  
  /// Get descriptive text for total completed tasks
  String _getTotalCompletedText(AsyncValue<List<TaskModel>> completedTasksAsync) {
    final count = _getTotalCompletedCount(completedTasksAsync);
    if (count == 0) return 'Get started!';
    if (count < 5) return 'Great start';
    if (count < 20) return 'Building momentum';
    if (count < 50) return 'Getting productive';
    if (count < 100) return 'Highly productive';
    return 'Task master!';
  }
  
  /// Get icon color based on total completed tasks
  Color _getCompletedIconColor(ThemeData theme, int count) {
    if (count == 0) return theme.colorScheme.outline;
    if (count < 20) return theme.colorScheme.primary;
    if (count < 50) return theme.colorScheme.secondary;
    return theme.colorScheme.tertiary; // Success color for high achievers
  }
  
  
  int _getWeeklyCompletionPercentage(AsyncValue<List<TaskModel>> allTasksAsync, AsyncValue<List<TaskModel>> completedTasksAsync) {
    return allTasksAsync.maybeWhen(
      data: (allTasks) => completedTasksAsync.maybeWhen(
        data: (completedTasks) {
          final now = DateTime.now();
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          final weekEnd = weekStartDate.add(const Duration(days: 7));
          
          // Tasks due this week
          final weekTasks = allTasks.where((task) => 
            task.dueDate != null &&
            task.dueDate!.isAfter(weekStartDate) &&
            task.dueDate!.isBefore(weekEnd)
          ).toList();
          
          if (weekTasks.isEmpty) return 0;
          
          // Tasks completed this week
          final weekCompletedTasks = weekTasks.where((task) => 
            task.status == TaskStatus.completed
          ).length;
          
          return ((weekCompletedTasks / weekTasks.length) * 100).round();
        },
        orElse: () => 0,
      ),
      orElse: () => 0,
    );
  }
  
  String _getWeeklyProgressText(AsyncValue<List<TaskModel>> allTasksAsync, AsyncValue<List<TaskModel>> completedTasksAsync) {
    final percentage = _getWeeklyCompletionPercentage(allTasksAsync, completedTasksAsync);
    if (percentage == 0) return 'Just started';
    if (percentage < 25) return 'Getting going';
    if (percentage < 50) return 'Making progress';
    if (percentage < 75) return 'Strong week';
    if (percentage < 100) return 'Almost there!';
    return 'Perfect week!';
  }
  
  Color _getWeeklyProgressIconColor(ThemeData theme, int percentage) {
    if (percentage < 25) return theme.colorScheme.outline;
    if (percentage < 50) return theme.colorScheme.primary;
    if (percentage < 75) return theme.colorScheme.secondary;
    return theme.colorScheme.tertiary;
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
        level: GlassLevel.interactive, // Use interactive level for stat cards
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

  /// Build today's summary card for the enhanced welcome section
  Widget _buildTodaySummaryCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required int? count,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        height: 140, // Fixed height for consistency
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon and count row
            Row(
              children: [
                // Icon with enhanced glassmorphism background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    border: Border.all(
                      color: iconColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                
                // Count beside the icon
                if (count != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    count.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: TypographyConstants.textXL,
                    ),
                  ),
                ],
              ],
            ),
            
            // Content section with consistent spacing
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: TypographyConstants.textSM,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Subtitle
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: TypographyConstants.textXS,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Generate focus time text based on task workload
  String _getFocusTimeText(BuildContext context, AsyncValue<List<TaskModel>> allTasksAsync) {
    return allTasksAsync.maybeWhen(
      data: (tasks) {
        final pendingToday = tasks.where((task) {
          if (task.dueDate == null) return false;
          final today = DateTime.now();
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          final todayDate = DateTime(today.year, today.month, today.day);
          return taskDate.isAtSameMomentAs(todayDate) && task.status != TaskStatus.completed;
        }).length;
        
        if (pendingToday == 0) return 'Free day';
        if (pendingToday <= 2) return 'Light day';
        if (pendingToday <= 4) return 'Busy day';
        return 'Packed day';
      },
      orElse: () => 'Loading...',
    );
  }

  /// Get focus time icon color based on workload (consistent with other cards)
  Color _getFocusTimeIconColor(ThemeData theme, AsyncValue<List<TaskModel>> allTasksAsync) {
    return allTasksAsync.maybeWhen(
      data: (tasks) {
        final pendingToday = tasks.where((task) {
          if (task.dueDate == null) return false;
          final today = DateTime.now();
          final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
          final todayDate = DateTime(today.year, today.month, today.day);
          return taskDate.isAtSameMomentAs(todayDate) && task.status != TaskStatus.completed;
        }).length;
        
        // Match the color logic with other cards for consistency
        if (pendingToday == 0) return theme.colorScheme.tertiary; // Free day - green/tertiary
        if (pendingToday <= 2) return theme.colorScheme.primary; // Light day - blue/primary
        if (pendingToday <= 4) return theme.colorScheme.secondary; // Busy day - orange/secondary
        return theme.colorScheme.error; // Packed day - red/error for urgency
      },
      orElse: () => theme.colorScheme.primary, // Default fallback
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
              
              final recentTasks = tasks.toList();
              
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
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
    // Navigate to edit task screen
    AppRouter.navigateToTaskDetail(context, task.id);
  }

  void _deleteTask(TaskModel task) {
    // Show confirmation dialog and delete task
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
    // Implement task sharing functionality
    final shareText = '''
Task: ${task.title}
${task.description?.isNotEmpty == true ? 'Description: ${task.description}' : ''}
Priority: ${task.priority.name.toUpperCase()}
${task.dueDate != null ? 'Due: ${task.dueDate!.toString()}' : ''}

Shared from Tasky - Task Management App
''';
    
    // Use the platform's native sharing capabilities
    Share.share(
      shareText,
      subject: 'Task: ${task.title}',
    );
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
            level: GlassLevel.interactive, // Use interactive level for tab bar
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 48.0,  // Fixed height for consistent alignment
            child: TabBar(
              // ENHANCED: Beautiful selection indicator with improved glow
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),  // Standardized 5px
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),  // Increased opacity for better visibility
                    blurRadius: 8.0,  // Increased blur for more prominent glow
                    spreadRadius: 1.0,  // Added spread for wider glow effect
                    offset: const Offset(0, 2),  // Slightly larger offset for depth
                  ),
                  // Additional subtle inner glow
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 4.0,
                    spreadRadius: 0.5,
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
                Semantics(
                  label: 'Today\'s tasks tab',
                  hint: 'View tasks due today',
                  button: true,
                  child: _buildFixedTab(
                    icon: Icons.today_outlined,
                    selectedIcon: Icons.today,
                    label: 'Today',
                    theme: theme,
                  ),
                ),
                Semantics(
                  label: 'Overdue tasks tab',
                  hint: 'View overdue tasks',
                  button: true,
                  child: _buildFixedTab(
                    icon: Icons.warning_amber_outlined,
                    selectedIcon: Icons.warning_amber,
                    label: 'Overdue',
                    theme: theme,
                  ),
                ),
                Semantics(
                  label: 'Future tasks tab',
                  hint: 'View upcoming tasks',
                  button: true,
                  child: _buildFixedTab(
                    icon: Icons.schedule_outlined,
                    selectedIcon: Icons.schedule,
                    label: 'Future',
                    theme: theme,
                  ),
                ),
              ],
            ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tab content with proper FAB padding
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65, // Increased height for better task visibility
            child: TabBarView(
              children: [
                _buildTodayTasksList(context, theme),
                _buildOverdueTasksList(context, theme),
                _buildFutureTasksList(context, theme),
              ],
            ),
          ),
          
          // Enhanced bottom padding to prevent FAB overlap with larger FAB
          const SizedBox(height: 120),
        ],
      ),
    );
  }
  
  /// ENHANCED: Helper method to build perfectly aligned tab with larger, more visible elements
  Widget _buildFixedTab({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required ThemeData theme,
  }) {
    return Tab(
      height: 42.0,  // Reduced height for more compact tabs
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),  // Reduced padding
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,  // Will show selected/unselected based on tab state
              size: 20.0,  // Reduced to 20px for better proportion
            ),
            const SizedBox(width: 8.0),  // Reduced spacing
            Flexible(  // Prevent text overflow
              child: Text(
                label,
                style: TextStyle(
                  fontSize: TypographyConstants.textSM,  // Use small text size (14px)
                  fontWeight: TypographyConstants.medium,  // Medium weight for readability
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,  // Handle long text gracefully
                maxLines: 1,  // Ensure single line to prevent cutoff
              ),
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
      height: 100, // Increased height to accommodate stacked badges
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassmorphismContainer(
        level: GlassLevel.content, // Use content level for compact task cards
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => AppRouter.navigateToTaskDetail(context, task.id),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Category-based task icon (big) on the left
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default').withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default').withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(task.tags.isNotEmpty ? task.tags.first : 'default'),
                    color: _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default'),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
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
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface, // Ensure theme-aware color
                                decoration: task.status == TaskStatus.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Audio indicator for voice tasks
                          if (task.hasAudio) ...[
                            const SizedBox(width: 6),
                            AudioIndicatorWidget(
                              taskId: task.id,
                              audioFilePath: task.audioFilePath,
                              duration: task.audioDuration,
                              size: 20, // Increased from 14 to make it more visible
                              // Remove onTap override - let it use default audio play behavior
                            ),
                          ],
                        ],
                      ),
                      
                      // Task description (single line, maxed)
                      if (task.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Status and priority badges stacked vertically on the right
                SizedBox(
                  width: 100, // Fixed width for badges
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Priority badge on top
                      PriorityBadgeWidget(
                        priority: task.priority,
                        showText: false,
                        compact: false,
                        fontSize: 11,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Status badge below priority
                      StatusBadgeWidget(
                        status: task.status,
                        showText: false,
                        compact: false,
                        fontSize: 11,
                      ),
                      
                      // Progress indicator if applicable
                      if (task.subTasks.isNotEmpty || task.status == TaskStatus.inProgress) ...[
                        const SizedBox(height: 6),
                        _buildProgressIndicator(task, theme),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

  /// Get category-based icon for task cards
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.health_and_safety;
      case 'fitness':
        return Icons.fitness_center;
      case 'finance':
        return Icons.account_balance_wallet;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'family':
        return Icons.family_restroom;
      case 'entertainment':
        return Icons.movie;
      case 'food':
        return Icons.restaurant;
      case 'project':
        return Icons.folder;
      case 'meeting':
        return Icons.meeting_room;
      case 'call':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'urgent':
        return Icons.error;
      case 'important':
        return Icons.star;
      default:
        return Icons.task_alt; // Default task icon
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
  Widget _buildProgressIndicator(TaskModel task, ThemeData theme) {
    if (task.subTasks.isEmpty && task.status != TaskStatus.inProgress) {
      return const SizedBox.shrink();
    }

    double progress = 0.0;
    String progressText = '';

    if (task.subTasks.isNotEmpty) {
      final completedSubtasks = task.subTasks.where((s) => s.isCompleted).length;
      progress = completedSubtasks / task.subTasks.length;
      progressText = '$completedSubtasks/${task.subTasks.length}';
    } else if (task.status == TaskStatus.inProgress) {
      progress = 0.5; // Show 50% for in-progress tasks without subtasks
      progressText = 'Working';
    }

    return SizedBox(
      width: 60,
      height: 16, // Fixed height to prevent overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 2,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCategoryColor(task.tags.isNotEmpty ? task.tags.first : 'default'),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            progressText,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
    final parts = <String>[];
    
    // Today's tasks
    if (pendingCount > 0) {
      parts.add('Today you have $pendingCount pending task${pendingCount != 1 ? 's' : ''}');
      
      if (urgentCount > 0 || highCount > 0) {
        final priorityParts = <String>[];
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
    
    return '${parts.join(pendingCount > 0 ? ', ' : ' and ')}.';
  }

  /// Build enhanced bulleted task summary with consistent typography
  List<Widget> _buildBulletedTaskSummary(ThemeData theme, int pendingCount, int urgentCount, int highCount, int completedCount) {
    final bullets = <Widget>[];
    
    // Consistent typography style for all bullets
    final bulletTextStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
      height: 1.4,
      fontSize: TypographyConstants.bodyLarge,
    );
    
    // Today's Pending Tasks
    if (pendingCount > 0) {
      bullets.add(_buildBulletPoint(
        theme: theme,
        icon: Icons.pending_actions,
        iconColor: theme.colorScheme.primary,
        text: '$pendingCount pending task${pendingCount != 1 ? 's' : ''} today',
        style: bulletTextStyle,
      ));
      
      // Priority breakdown if applicable
      if (urgentCount > 0) {
        bullets.add(_buildBulletPoint(
          theme: theme,
          icon: Icons.priority_high,
          iconColor: Colors.red,
          text: '$urgentCount urgent task${urgentCount != 1 ? 's' : ''} requiring immediate attention',
          style: bulletTextStyle,
          isSubBullet: true,
        ));
      }
      
      if (highCount > 0) {
        bullets.add(_buildBulletPoint(
          theme: theme,
          icon: Icons.keyboard_arrow_up,
          iconColor: Colors.orange,
          text: '$highCount high priority task${highCount != 1 ? 's' : ''} to focus on',
          style: bulletTextStyle,
          isSubBullet: true,
        ));
      }
    } else {
      bullets.add(_buildBulletPoint(
        theme: theme,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        text: 'All caught up! No pending tasks today',
        style: bulletTextStyle,
      ));
    }
    
    // Completed Tasks (Yesterday's achievement)
    if (completedCount > 0) {
      bullets.add(_buildBulletPoint(
        theme: theme,
        icon: Icons.task_alt,
        iconColor: Colors.green,
        text: '$completedCount task${completedCount != 1 ? 's' : ''} completed yesterday',
        style: bulletTextStyle,
      ));
    } else {
      bullets.add(_buildBulletPoint(
        theme: theme,
        icon: Icons.wb_sunny_outlined,
        iconColor: theme.colorScheme.secondary,
        text: 'Fresh start today - ready to make progress',
        style: bulletTextStyle,
      ));
    }
    
    return bullets;
  }
  
  /// Build individual bullet point with consistent styling
  Widget _buildBulletPoint({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String text,
    required TextStyle? style,
    bool isSubBullet = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.0,
        left: isSubBullet ? 24.0 : 0.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: isSubBullet ? 12 : 14,
              color: iconColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: style, // Use the provided style without overriding fontSize
            ),
          ),
        ],
      ),
    );
  }

  /// Get time-based greeting
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
            ),
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
              fontWeight: TypographyConstants.bold,
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
    IconData insightIcon = Icons.info_outline;

    if (urgentCount > 0) {
      insight = urgentCount == 1 
        ? '1 urgent task needs immediate attention'
        : '$urgentCount urgent tasks need immediate attention';
      insightColor = theme.colorScheme.error;
      insightIcon = Icons.priority_high;
    } else if (highCount > 0) {
      insight = highCount == 1
        ? '1 high priority task to focus on'
        : '$highCount high priority tasks to focus on';
      insightColor = theme.colorScheme.secondary;
      insightIcon = Icons.keyboard_arrow_up;
    } else if (pendingCount > 0) {
      insight = 'Great progress! Stay focused on remaining tasks';
      insightColor = theme.colorScheme.primary;
      insightIcon = Icons.trending_up;
    }

    if (insight.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
        border: Border.all(
          color: insightColor.withOpacity(0.3),
          width: 1,
        ),
      ),
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

  /// Show priority options for accessibility
  void _showPriorityOptions(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Priority for "${task.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values.map((priority) => 
            ListTile(
              leading: Icon(
                _getPriorityIcon(priority),
                color: _getPriorityColor(priority),
              ),
              title: Text(priority.name.toUpperCase()),
              selected: task.priority == priority,
              onTap: () async {
                // Update task priority through provider
                final updatedTask = task.copyWith(priority: priority);
                await ref.read(taskRepositoryProvider).updateTask(updatedTask);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Priority updated to ${priority.name}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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