import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/phosphor_icons.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/timeline_milestone.dart';
import '../glassmorphism_container.dart';

/// Milestone marker displayed on the timeline
/// 
/// Features:
/// - Vertical line spanning the entire timeline height
/// - Flag-style marker with milestone icon and title
/// - Color coding based on milestone priority
/// - Completion status visualization
/// - Interactive tooltip with milestone details
/// - Animated hover effects
class MilestoneTimelineMarker extends StatefulWidget {
  /// The milestone to display
  final TimelineMilestone milestone;
  
  /// Total height of the timeline
  final double height;
  
  /// Callback when milestone is tapped
  final VoidCallback? onTap;
  
  /// Whether to show milestone details in a compact format
  final bool isCompact;

  const MilestoneTimelineMarker({
    super.key,
    required this.milestone,
    required this.height,
    this.onTap,
    this.isCompact = false,
  });

  @override
  State<MilestoneTimelineMarker> createState() => _MilestoneTimelineMarkerState();
}

class _MilestoneTimelineMarkerState extends State<MilestoneTimelineMarker>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: widget.height,
      child: Stack(
        children: [
          // Vertical milestone line
          _buildMilestoneLine(),
          
          // Milestone marker
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _buildMilestoneMarker(),
          ),
          
          // Milestone tooltip (on hover)
          if (_isHovering && !widget.isCompact)
            _buildMilestoneTooltip(),
        ],
      ),
    );
  }

  Widget _buildMilestoneLine() {
    return Positioned(
      left: 11,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getMilestoneColor().withValues(alpha: 0.8),
              _getMilestoneColor().withValues(alpha: 0.3),
              _getMilestoneColor().withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: _getMilestoneColor().withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneMarker() {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: _buildMarkerContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarkerContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Milestone flag
        _buildMilestoneFlag(),
        
        // Milestone label (if not compact)
        if (!widget.isCompact) ...[
          const SizedBox(width: 8),
          _buildMilestoneLabel(),
        ],
      ],
    );
  }

  Widget _buildMilestoneFlag() {
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      width: 24,
      height: 24,
      borderRadius: BorderRadius.circular(12),
      glassTint: _getMilestoneColor().withValues(alpha: 0.2),
      borderColor: _getMilestoneColor().withValues(alpha: 0.8),
      borderWidth: 2.0,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _getMilestoneColor().withValues(alpha: 0.8),
              _getMilestoneColor().withValues(alpha: 0.4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getMilestoneColor().withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              // Milestone icon
              Icon(
                _getMilestoneIcon(),
                size: 14,
                color: Colors.white,
              ),
              
              // Completion indicator
              if (widget.milestone.isCompleted)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 6,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneLabel() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(
        horizontal: TypographyConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        border: Border.all(
          color: _getMilestoneColor().withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.milestone.title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            _formatMilestoneDate(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTooltip() {
    return Positioned(
      top: -10,
      left: 30,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 250),
          padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            border: Border.all(
              color: _getMilestoneColor().withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Milestone title
              Row(
                children: [
                  Icon(
                    _getMilestoneIcon(),
                    size: 16,
                    color: _getMilestoneColor(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.milestone.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: TypographyConstants.medium,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.milestone.isCompleted)
                    Icon(
                      PhosphorIcons.checkCircle(),
                      size: 16,
                      color: const Color(0xFF10B981),
                    ),
                ],
              ),
              
              const SizedBox(height: TypographyConstants.spacingSmall),
              
              // Milestone date
              Row(
                children: [
                  Icon(
                    PhosphorIcons.calendar(),
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatMilestoneDateDetailed(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              // Milestone description
              if (widget.milestone.description != null &&
                  widget.milestone.description!.isNotEmpty) ...[
                const SizedBox(height: TypographyConstants.spacingSmall),
                Text(
                  widget.milestone.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Priority indicator
              const SizedBox(height: TypographyConstants.spacingSmall),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getMilestoneColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.milestone.priority.displayName} Priority',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              // Status information
              if (widget.milestone.isOverdue && !widget.milestone.isCompleted) ...[
                const SizedBox(height: TypographyConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.warningCircle(),
                      size: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Overdue by ${widget.milestone.daysUntilDue.abs()} days',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ] else if (widget.milestone.isDueSoon && !widget.milestone.isCompleted) ...[
                const SizedBox(height: TypographyConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.clockCountdown(),
                      size: 14,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due in ${widget.milestone.daysUntilDue} days',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Required tasks info
              if (widget.milestone.requiredTaskIds.isNotEmpty) ...[
                const SizedBox(height: TypographyConstants.spacingSmall),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.listChecks(),
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.milestone.requiredTaskIds.length} required tasks',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getMilestoneColor() {
    if (widget.milestone.isCompleted) {
      return const Color(0xFF10B981); // Green for completed
    } else if (widget.milestone.isOverdue) {
      return Theme.of(context).colorScheme.error;
    } else {
      return Color(int.parse('0xFF${widget.milestone.color.substring(1)}'));
    }
  }

  IconData _getMilestoneIcon() {
    if (widget.milestone.isCompleted) {
      return PhosphorIcons.flagCheckered();
    }
    
    // Use the milestone's custom icon or default to flag
    final iconName = widget.milestone.iconName;
    final icon = PhosphorIconConstants.getIconByName(iconName);
    
    return icon;
  }

  String _formatMilestoneDate() {
    final date = widget.milestone.date;
    final now = DateTime.now();
    
    if (date.year == now.year) {
      return '${_getMonthAbbreviation(date.month)} ${date.day}';
    } else {
      return '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _formatMilestoneDateDetailed() {
    final date = widget.milestone.date;
    final now = DateTime.now();
    final daysDiff = date.difference(now).inDays;
    
    String dateStr;
    if (date.year == now.year) {
      dateStr = '${_getMonthName(date.month)} ${date.day}';
    } else {
      dateStr = '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
    
    if (daysDiff == 0) {
      dateStr += ' (Today)';
    } else if (daysDiff == 1) {
      dateStr += ' (Tomorrow)';
    } else if (daysDiff == -1) {
      dateStr += ' (Yesterday)';
    } else if (daysDiff > 0) {
      dateStr += ' (in $daysDiff days)';
    } else {
      dateStr += ' (${daysDiff.abs()} days ago)';
    }
    
    return dateStr;
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}