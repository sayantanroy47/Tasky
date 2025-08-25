import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../providers/smart_features_providers.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';

/// Smart features dashboard widget that displays AI insights and health metrics
class SmartFeaturesDashboard extends ConsumerWidget {
  const SmartFeaturesDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(smartFeaturesDashboardProvider);
    final featuresEnabledAsync = ref.watch(smartFeaturesEnabledProvider);

    return featuresEnabledAsync.when(
      data: (enabled) => enabled ? _buildEnabledDashboard(context, ref, dashboardAsync) 
                                : _buildDisabledState(context),
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildEnabledDashboard(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<Map<String, dynamic>> dashboardAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIcons.brain(),
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            StandardizedGaps.horizontal(SpacingSize.xs),
            const StandardizedText(
              'Smart Insights',
              style: StandardizedTextStyle.titleMedium,
            ),
          ],
        ),
        StandardizedGaps.vertical(SpacingSize.md),
        
        dashboardAsync.when(
          data: (data) => _buildDashboardContent(context, ref, data),
          loading: () => _buildLoadingContent(context),
          error: (error, stack) => _buildErrorContent(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, 
    WidgetRef ref, 
    Map<String, dynamic> data,
  ) {
    return Column(
      children: [
        // Quick stats row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Projects Need Attention',
                data['projects_needing_attention']?.toString() ?? '0',
                PhosphorIcons.warning(),
                Colors.orange,
              ),
            ),
            StandardizedGaps.horizontal(SpacingSize.sm),
            Expanded(
              child: _buildStatCard(
                context,
                'Urgent Suggestions',
                data['urgent_suggestions']?.toString() ?? '0',
                PhosphorIcons.lightbulb(),
                Colors.blue,
              ),
            ),
          ],
        ),
        StandardizedGaps.horizontal(SpacingSize.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'High Risk Projects',
                data['high_risk_projects']?.toString() ?? '0',
                PhosphorIcons.shieldWarning(),
                Colors.red,
              ),
            ),
            StandardizedGaps.horizontal(SpacingSize.sm),
            Expanded(
              child: _buildStatCard(
                context,
                'AI Records',
                data['prediction_records']?.toString() ?? '0',
                PhosphorIcons.chartLine(),
                Colors.green,
              ),
            ),
          ],
        ),
        StandardizedGaps.vertical(SpacingSize.md),
        
        // Urgent suggestions section
        _buildUrgentSuggestionsSection(context, ref),
        
        StandardizedGaps.vertical(SpacingSize.md),
        
        // Projects needing attention section
        _buildProjectsNeedingAttentionSection(context, ref),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      padding: StandardizedSpacing.padding(SpacingSize.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              StandardizedGaps.horizontal(SpacingSize.xs),
              Expanded(
                child: StandardizedText(
                  title,
                  style: StandardizedTextStyle.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          StandardizedText(
            value,
            style: StandardizedTextStyle.titleLarge,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentSuggestionsSection(BuildContext context, WidgetRef ref) {
    final urgentSuggestionsAsync = ref.watch(urgentSuggestionsProvider);
    
    return urgentSuggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();
        
        return GlassmorphismContainer(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.lightbulbFilament(),
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  Text(
                    'Urgent AI Suggestions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _viewAllSuggestions(context, ref),
                    child: const StandardizedText('View All', style: StandardizedTextStyle.buttonText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...suggestions.take(3).map((suggestion) => _buildSuggestionTile(
                context,
                ref,
                suggestion,
              )),
            ],
          ),
        );
      },
      loading: () => _buildSectionLoading(context, 'Loading suggestions...'),
      error: (error, stack) => _buildSectionError(context, 'Error loading suggestions'),
    );
  }

  Widget _buildProjectsNeedingAttentionSection(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsNeedingAttentionProvider);
    
    return projectsAsync.when(
      data: (projectIds) {
        if (projectIds.isEmpty) return const SizedBox.shrink();
        
        return GlassmorphismContainer(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          padding: StandardizedSpacing.padding(SpacingSize.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIcons.warningCircle(),
                    size: 16,
                    color: Colors.orange,
                  ),
                  StandardizedGaps.horizontal(SpacingSize.xs),
                  Text(
                    'Projects Need Attention',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _viewProjectHealth(context, ref),
                    child: const StandardizedText('View Details', style: StandardizedTextStyle.buttonText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...projectIds.take(3).map((projectId) => _buildProjectHealthTile(
                context,
                ref,
                projectId,
              )),
            ],
          ),
        );
      },
      loading: () => _buildSectionLoading(context, 'Loading project health...'),
      error: (error, stack) => _buildSectionError(context, 'Error loading project health'),
    );
  }

  Widget _buildSuggestionTile(
    BuildContext context,
    WidgetRef ref,
    AISuggestion suggestion,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getSuggestionPriorityColor(suggestion.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                StandardizedGaps.vertical(SpacingSize.xs),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.target(),
                      size: 12,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    ),
                    StandardizedGaps.horizontal(SpacingSize.xs),
                    Text(
                      '${suggestion.confidence.round()}% confidence',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 16,
            onPressed: () => _handleSuggestionAction(context, ref, suggestion),
            icon: Icon(
              PhosphorIcons.caretRight(),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHealthTile(
    BuildContext context,
    WidgetRef ref,
    String projectId,
  ) {
    final healthAsync = ref.watch(projectHealthProvider(projectId));
    
    return healthAsync.when(
      data: (health) {
        if (health == null) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getHealthLevelColor(health.level),
                  shape: BoxShape.circle,
                ),
              ),
              StandardizedGaps.horizontal(SpacingSize.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project ${projectId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${health.criticalIssues.length} critical issues',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${health.healthScore.round()}/100',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _getHealthLevelColor(health.level),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildHealthTileLoading(context),
      error: (error, stack) => _buildHealthTileError(context),
    );
  }

  Widget _buildSectionLoading(BuildContext context, String message) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionError(BuildContext context, String message) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTileLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                StandardizedGaps.vertical(SpacingSize.xs),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTileError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.x(),
            size: 12,
            color: Theme.of(context).colorScheme.error,
          ),
          StandardizedGaps.horizontal(SpacingSize.sm),
          Text(
            'Error loading project health',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.robot(),
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Smart Features Disabled',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable AI-powered insights in settings to see project health monitoring, suggestions, and predictions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Smart Features Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: _StatCardSkeleton()),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCardSkeleton()),
            SizedBox(width: 12),
            Expanded(child: _StatCardSkeleton()),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Error: $error',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  // Helper methods
  
  Color _getSuggestionPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.urgent:
        return Colors.red;
      case SuggestionPriority.high:
        return Colors.orange;
      case SuggestionPriority.medium:
        return Colors.blue;
      case SuggestionPriority.low:
        return Colors.green;
    }
  }

  Color _getHealthLevelColor(ProjectHealthLevel level) {
    switch (level) {
      case ProjectHealthLevel.excellent:
        return Colors.green;
      case ProjectHealthLevel.good:
        return Colors.lightGreen;
      case ProjectHealthLevel.warning:
        return Colors.orange;
      case ProjectHealthLevel.critical:
        return Colors.red;
    }
  }

  // Navigation methods
  
  void _viewAllSuggestions(BuildContext context, WidgetRef ref) {
    // Navigate to suggestions page
    Navigator.of(context).pushNamed('/smart-suggestions');
  }

  void _viewProjectHealth(BuildContext context, WidgetRef ref) {
    // Navigate to project health page
    Navigator.of(context).pushNamed('/project-health');
  }

  void _handleSuggestionAction(
    BuildContext context,
    WidgetRef ref,
    AISuggestion suggestion,
  ) {
    // Show suggestion details dialog or navigate to details
    showDialog(
      context: context,
      builder: (context) => _SuggestionDetailsDialog(suggestion: suggestion),
    );
  }
}

/// Skeleton widget for loading stat cards
class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      padding: StandardizedSpacing.padding(SpacingSize.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for showing suggestion details
class _SuggestionDetailsDialog extends ConsumerWidget {
  final AISuggestion suggestion;

  const _SuggestionDetailsDialog({required this.suggestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(suggestion.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestion.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          StandardizedGaps.vertical(SpacingSize.md),
          Text(
            'Expected Impact:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          Text(
            suggestion.expectedImpact,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Recommendations:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          StandardizedGaps.vertical(SpacingSize.xs),
          ...suggestion.recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                  child: Text(
                    rec,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(smartFeaturesNotifierProvider.notifier)
                .updateSuggestionStatus(suggestion.id, false, true, 'Dismissed from dashboard');
            Navigator.of(context).pop();
          },
          child: const StandardizedText('Dismiss', style: StandardizedTextStyle.buttonText),
        ),
        FilledButton(
          onPressed: () {
            ref.read(smartFeaturesNotifierProvider.notifier)
                .updateSuggestionStatus(suggestion.id, true, false, null);
            Navigator.of(context).pop();
          },
          child: const StandardizedText('Accept', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }
}