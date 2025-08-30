import 'dart:async';
import 'dart:math';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project_prediction.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';

/// Advanced predictive analytics engine for project completion forecasting
class PredictiveAnalyticsEngine {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  PredictiveAnalyticsEngine({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository;

  /// Generates comprehensive predictive analytics for a project
  Future<ProjectPredictiveAnalytics> generatePredictiveAnalytics(String projectId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw ArgumentError('Project not found: $projectId');
    }

    final tasks = await _taskRepository.getTasksForProject(projectId);
    final predictions = <ProjectPrediction>[];

    // Generate different types of predictions
    final completionDatePrediction = await _predictCompletionDate(project, tasks);
    if (completionDatePrediction != null) predictions.add(completionDatePrediction);

    predictions.addAll(await _generateRiskAssessments(project, tasks));
    predictions.addAll(await _generateWorkloadForecasts(project, tasks));
    predictions.addAll(await _generateResourceRequirements(project, tasks));
    predictions.addAll(await _generateQualityMetricPredictions(project, tasks));

    // Calculate overall risk and success probability
    final overallRisk = _calculateOverallRisk(predictions);
    final successProbability = _calculateSuccessProbability(project, tasks, predictions);
    final riskFactors = _identifyRiskFactors(project, tasks, predictions);
    final recommendedActions = _generateRecommendedActions(project, tasks, predictions);

    return ProjectPredictiveAnalytics(
      projectId: projectId,
      predictions: predictions,
      overallRisk: overallRisk,
      predictedCompletionDate: completionDatePrediction?.predictedValue,
      completionDateConfidence: completionDatePrediction?.confidenceScore ?? 0.0,
      successProbability: successProbability,
      riskFactors: riskFactors,
      recommendedActions: recommendedActions,
      generatedAt: DateTime.now(),
      nextUpdateAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  /// Predicts project completion date using multiple algorithms
  Future<ProjectPrediction?> _predictCompletionDate(
    Project project,
    List<TaskModel> tasks,
  ) async {
    if (tasks.isEmpty) return null;

    final completedTasks = tasks.where((t) => t.status.isCompleted).toList();
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    
    if (remainingTasks.isEmpty) {
      // Project is already complete
      final lastCompletedTask = completedTasks
          .where((t) => t.completedAt != null)
          .reduce((a, b) => a.completedAt!.isAfter(b.completedAt!) ? a : b);
      
      return ProjectPrediction(
        id: 'completion_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: PredictionType.completionDate,
        title: 'Project Completion Date',
        description: 'Project is already complete',
        predictedValue: lastCompletedTask.completedAt,
        currentValue: DateTime.now(),
        confidence: PredictionConfidence.veryHigh,
        confidenceScore: 100.0,
        riskLevel: RiskLevel.veryLow,
        generatedAt: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 30)),
        historicalAccuracy: 100.0,
      );
    }

    final scenarios = <PredictionScenario>[];
    DateTime? bestCasePrediction;
    DateTime? worstCasePrediction;

    // Algorithm 1: Velocity-based prediction
    final velocityPrediction = await _predictByVelocity(project, tasks);
    if (velocityPrediction != null) {
      scenarios.add(PredictionScenario(
        name: 'Current Velocity',
        description: 'Based on recent task completion velocity',
        probability: 40.0,
        impact: 'Most likely scenario if current pace continues',
        adjustedValue: velocityPrediction,
      ));
    }

    // Algorithm 2: Estimation-based prediction
    final estimationPrediction = await _predictByEstimation(project, tasks);
    if (estimationPrediction != null) {
      bestCasePrediction = estimationPrediction;
      scenarios.add(PredictionScenario(
        name: 'Estimation Based',
        description: 'Based on task duration estimates',
        probability: 30.0,
        impact: 'Best case if all estimates are accurate',
        adjustedValue: estimationPrediction,
      ));
    }

    // Algorithm 3: Historical pattern prediction
    final historicalPrediction = await _predictByHistoricalPattern(project, tasks);
    if (historicalPrediction != null) {
      scenarios.add(PredictionScenario(
        name: 'Historical Pattern',
        description: 'Based on similar past projects',
        probability: 20.0,
        impact: 'Realistic based on historical performance',
        adjustedValue: historicalPrediction,
      ));
    }

    // Algorithm 4: Monte Carlo simulation (simplified)
    final monteCarloPrediction = await _predictByMonteCarlo(project, tasks);
    if (monteCarloPrediction != null) {
      worstCasePrediction = monteCarloPrediction;
      scenarios.add(PredictionScenario(
        name: 'Risk-Adjusted',
        description: 'Accounts for potential delays and risks',
        probability: 10.0,
        impact: 'Conservative estimate including risk factors',
        adjustedValue: monteCarloPrediction,
      ));
    }

    // Calculate weighted prediction
    final finalPrediction = _calculateWeightedPrediction([
      if (velocityPrediction != null) velocityPrediction,
      if (estimationPrediction != null) estimationPrediction,
      if (historicalPrediction != null) historicalPrediction,
    ]);

    if (finalPrediction == null) return null;

    // Calculate confidence based on data quality and consistency
    final confidence = _calculateCompletionDateConfidence(
      project,
      tasks,
      [velocityPrediction, estimationPrediction, historicalPrediction].whereType<DateTime>().toList(),
    );

    return ProjectPrediction(
      id: 'completion_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      type: PredictionType.completionDate,
      title: 'Predicted Completion Date',
      description: 'Project completion forecast based on multiple algorithms',
      predictedValue: finalPrediction,
      currentValue: DateTime.now(),
      confidence: _confidenceScoreToLevel(confidence),
      confidenceScore: confidence,
      riskLevel: _calculateCompletionDateRisk(project, finalPrediction),
      influencingFactors: const [
        'Task completion velocity',
        'Remaining task estimates',
        'Historical project patterns',
        'Current project health',
      ],
      scenarios: scenarios,
      generatedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 7)),
      historicalAccuracy: 75.0, // Would be calculated from past predictions
      metadata: {
        'total_tasks': tasks.length,
        'remaining_tasks': remainingTasks.length,
        'completion_rate': completedTasks.length / tasks.length,
        'algorithms_used': scenarios.length,
        'best_case': bestCasePrediction?.toIso8601String(),
        'worst_case': worstCasePrediction?.toIso8601String(),
      },
    );
  }

  /// Predicts completion date based on current velocity
  Future<DateTime?> _predictByVelocity(Project project, List<TaskModel> tasks) async {
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.length < 2) return null;

    // Calculate weekly velocity based on last 4 weeks
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final recentCompletions = completedTasks.where((t) =>
        t.completedAt!.isAfter(fourWeeksAgo)).length;
    
    final weeklyVelocity = recentCompletions / 4.0;
    if (weeklyVelocity <= 0) return null;

    final remainingTasks = tasks.where((t) => !t.status.isCompleted).length;
    final weeksToComplete = remainingTasks / weeklyVelocity;
    
    return now.add(Duration(days: (weeksToComplete * 7).round()));
  }

  /// Predicts completion date based on task estimates
  Future<DateTime?> _predictByEstimation(Project project, List<TaskModel> tasks) async {
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    final tasksWithEstimates = remainingTasks.where((t) => t.estimatedDuration != null).toList();
    
    if (tasksWithEstimates.length < remainingTasks.length * 0.5) return null;

    final totalRemainingMinutes = tasksWithEstimates
        .map((t) => t.estimatedDuration!)
        .reduce((a, b) => a + b);
    
    // Assume 6 productive hours per day (360 minutes)
    final workingDays = totalRemainingMinutes / 360;
    
    // Account for weekends (multiply by 7/5)
    final calendarDays = (workingDays * 7 / 5).round();
    
    return DateTime.now().add(Duration(days: calendarDays));
  }

  /// Predicts completion date based on historical patterns
  Future<DateTime?> _predictByHistoricalPattern(Project project, List<TaskModel> tasks) async {
    // In a real implementation, this would analyze similar completed projects
    // For now, we'll use a simple heuristic based on project age and completion rate
    
    final completedTasks = tasks.where((t) => t.status.isCompleted).length;
    final completionRate = completedTasks / tasks.length;
    
    if (completionRate < 0.1) return null; // Not enough progress to predict

    final projectAge = DateTime.now().difference(project.createdAt).inDays;
    final estimatedTotalDays = projectAge / completionRate;
    final remainingDays = estimatedTotalDays - projectAge;
    
    return DateTime.now().add(Duration(days: remainingDays.round()));
  }

  /// Predicts completion date using Monte Carlo simulation (simplified)
  Future<DateTime?> _predictByMonteCarlo(Project project, List<TaskModel> tasks) async {
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    if (remainingTasks.isEmpty) return null;

    // Simple Monte Carlo: add random delays to estimation-based prediction
    final basePrediction = await _predictByEstimation(project, tasks);
    if (basePrediction == null) return null;

    // Add buffer for risks (20-40% additional time)
    final random = Random();
    final bufferPercentage = 0.2 + random.nextDouble() * 0.2; // 20-40%
    final additionalDays = basePrediction.difference(DateTime.now()).inDays * bufferPercentage;
    
    return basePrediction.add(Duration(days: additionalDays.round()));
  }

  /// Generates risk assessments for various project aspects
  Future<List<ProjectPrediction>> _generateRiskAssessments(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final predictions = <ProjectPrediction>[];

    // Schedule risk assessment
    if (project.deadline != null) {
      final scheduleRisk = _assessScheduleRisk(project, tasks);
      predictions.add(ProjectPrediction(
        id: 'schedule_risk_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: PredictionType.riskAssessment,
        title: 'Schedule Risk Assessment',
        description: 'Likelihood of meeting project deadline',
        predictedValue: scheduleRisk.level,
        confidence: PredictionConfidence.high,
        confidenceScore: scheduleRisk.confidence,
        riskLevel: scheduleRisk.level,
        influencingFactors: scheduleRisk.factors,
        generatedAt: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 3)),
        metadata: scheduleRisk.metadata,
      ));
    }

    // Quality risk assessment
    final qualityRisk = _assessQualityRisk(project, tasks);
    predictions.add(ProjectPrediction(
      id: 'quality_risk_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      type: PredictionType.riskAssessment,
      title: 'Quality Risk Assessment',
      description: 'Likelihood of quality issues or rework',
      predictedValue: qualityRisk.level,
      confidence: PredictionConfidence.medium,
      confidenceScore: qualityRisk.confidence,
      riskLevel: qualityRisk.level,
      influencingFactors: qualityRisk.factors,
      generatedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 7)),
      metadata: qualityRisk.metadata,
    ));

    // Resource risk assessment
    final resourceRisk = _assessResourceRisk(project, tasks);
    predictions.add(ProjectPrediction(
      id: 'resource_risk_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      type: PredictionType.riskAssessment,
      title: 'Resource Risk Assessment',
      description: 'Risk of resource constraints or burnout',
      predictedValue: resourceRisk.level,
      confidence: PredictionConfidence.medium,
      confidenceScore: resourceRisk.confidence,
      riskLevel: resourceRisk.level,
      influencingFactors: resourceRisk.factors,
      generatedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 7)),
      metadata: resourceRisk.metadata,
    ));

    return predictions;
  }

  /// Generates workload forecasts
  Future<List<ProjectPrediction>> _generateWorkloadForecasts(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final predictions = <ProjectPrediction>[];
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    
    if (remainingTasks.isEmpty) return predictions;

    // Weekly workload forecast
    final weeklyWorkload = _forecastWeeklyWorkload(project, tasks);
    predictions.add(ProjectPrediction(
      id: 'weekly_workload_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      type: PredictionType.workloadForecast,
      title: 'Weekly Workload Forecast',
      description: 'Predicted workload distribution over the next 4 weeks',
      predictedValue: weeklyWorkload,
      confidence: PredictionConfidence.medium,
      confidenceScore: 70.0,
      riskLevel: _calculateWorkloadRisk(weeklyWorkload),
      generatedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 7)),
      metadata: {
        'remaining_tasks': remainingTasks.length,
        'forecast_weeks': 4,
      },
    ));

    return predictions;
  }

  /// Generates resource requirement predictions
  Future<List<ProjectPrediction>> _generateResourceRequirements(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final predictions = <ProjectPrediction>[];
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    
    if (remainingTasks.isEmpty) return predictions;

    // Skill requirements forecast
    final skillRequirements = _forecastSkillRequirements(project, tasks);
    predictions.add(ProjectPrediction(
      id: 'skill_requirements_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      type: PredictionType.resourceRequirement,
      title: 'Skill Requirements Forecast',
      description: 'Predicted skill and resource requirements',
      predictedValue: skillRequirements,
      confidence: PredictionConfidence.medium,
      confidenceScore: 65.0,
      riskLevel: RiskLevel.medium,
      generatedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 14)),
      metadata: {
        'task_categories': skillRequirements.length,
        'remaining_tasks': remainingTasks.length,
      },
    ));

    return predictions;
  }

  /// Generates quality metric predictions
  Future<List<ProjectPrediction>> _generateQualityMetricPredictions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final predictions = <ProjectPrediction>[];
    final completedTasks = tasks.where((t) => t.status.isCompleted).toList();
    
    if (completedTasks.length < 3) return predictions;

    // Defect rate prediction based on task completion patterns
    final defectRatePrediction = _predictDefectRate(project, tasks);
    predictions.add(ProjectPrediction(
      id: 'defect_rate_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      type: PredictionType.qualityMetrics,
      title: 'Quality Risk Forecast',
      description: 'Predicted likelihood of quality issues or rework',
      predictedValue: defectRatePrediction,
      confidence: PredictionConfidence.low,
      confidenceScore: 60.0,
      riskLevel: defectRatePrediction > 0.2 ? RiskLevel.high : RiskLevel.medium,
      generatedAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 14)),
      metadata: {
        'completed_tasks': completedTasks.length,
        'prediction_basis': 'task_completion_patterns',
      },
    ));

    return predictions;
  }

  // Helper methods for risk assessments

  ({RiskLevel level, double confidence, List<String> factors, Map<String, dynamic> metadata}) _assessScheduleRisk(
    Project project,
    List<TaskModel> tasks,
  ) {
    final factors = <String>[];
    final metadata = <String, dynamic>{};
    var riskScore = 0.0;

    // Factor 1: Overdue tasks
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    if (overdueTasks > 0) {
      riskScore += overdueTasks * 0.2;
      factors.add('$overdueTasks overdue tasks');
    }

    // Factor 2: Completion rate vs. timeline
    if (project.deadline != null) {
      final totalDuration = project.deadline!.difference(project.createdAt);
      final elapsedDuration = DateTime.now().difference(project.createdAt);
      final expectedProgress = elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;
      final actualProgress = tasks.where((t) => t.status.isCompleted).length / tasks.length;
      
      if (actualProgress < expectedProgress * 0.8) {
        riskScore += (expectedProgress - actualProgress) * 2;
        factors.add('Behind schedule (${(actualProgress * 100).round()}% vs ${(expectedProgress * 100).round()}% expected)');
      }
      
      metadata['expected_progress'] = expectedProgress;
      metadata['actual_progress'] = actualProgress;
    }

    // Factor 3: Task complexity
    final highPriorityTasks = tasks.where((t) => t.priority.isHigh && !t.status.isCompleted).length;
    if (highPriorityTasks > tasks.length * 0.3) {
      riskScore += 0.3;
      factors.add('High proportion of critical tasks remaining');
    }

    metadata['risk_score'] = riskScore;
    metadata['overdue_tasks'] = overdueTasks;

    final level = riskScore >= 1.0 ? RiskLevel.veryHigh :
                  riskScore >= 0.7 ? RiskLevel.high :
                  riskScore >= 0.4 ? RiskLevel.medium :
                  riskScore >= 0.2 ? RiskLevel.low : RiskLevel.veryLow;

    return (
      level: level,
      confidence: 80.0,
      factors: factors,
      metadata: metadata,
    );
  }

  ({RiskLevel level, double confidence, List<String> factors, Map<String, dynamic> metadata}) _assessQualityRisk(
    Project project,
    List<TaskModel> tasks,
  ) {
    final factors = <String>[];
    final metadata = <String, dynamic>{};
    var riskScore = 0.0;

    // Factor 1: Tasks without descriptions
    final tasksWithoutDescription = tasks.where((t) => 
        t.description == null || t.description!.trim().isEmpty).length;
    if (tasksWithoutDescription > tasks.length * 0.3) {
      riskScore += 0.3;
      factors.add('Many tasks lack detailed descriptions');
    }

    // Factor 2: Rushed completion patterns
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && 
        t.completedAt != null && 
        t.dueDate != null).toList();
    
    if (completedTasks.length > 3) {
      final rushedTasks = completedTasks.where((t) {
        final daysBefore = t.dueDate!.difference(t.completedAt!).inHours;
        return daysBefore < 2; // Completed very close to deadline
      }).length;
      
      if (rushedTasks > completedTasks.length * 0.4) {
        riskScore += 0.4;
        factors.add('Pattern of last-minute task completions');
      }
      
      metadata['rushed_tasks'] = rushedTasks;
    }

    // Factor 3: High workload pressure
    final inProgressTasks = tasks.where((t) => t.status.isInProgress).length;
    if (inProgressTasks > 5) {
      riskScore += 0.2;
      factors.add('High number of concurrent tasks may impact quality');
    }

    metadata['risk_score'] = riskScore;
    metadata['tasks_without_description'] = tasksWithoutDescription;

    final level = riskScore >= 0.8 ? RiskLevel.veryHigh :
                  riskScore >= 0.6 ? RiskLevel.high :
                  riskScore >= 0.4 ? RiskLevel.medium :
                  riskScore >= 0.2 ? RiskLevel.low : RiskLevel.veryLow;

    return (
      level: level,
      confidence: 65.0,
      factors: factors,
      metadata: metadata,
    );
  }

  ({RiskLevel level, double confidence, List<String> factors, Map<String, dynamic> metadata}) _assessResourceRisk(
    Project project,
    List<TaskModel> tasks,
  ) {
    final factors = <String>[];
    final metadata = <String, dynamic>{};
    var riskScore = 0.0;

    // Factor 1: Workload intensity
    if (project.deadline != null) {
      final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
      final tasksWithDuration = remainingTasks.where((t) => t.estimatedDuration != null).toList();
      
      if (tasksWithDuration.length > remainingTasks.length * 0.5) {
        final totalHours = tasksWithDuration
            .map((t) => t.estimatedDuration!)
            .reduce((a, b) => a + b) / 60;
        
        final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
        if (daysUntilDeadline > 0) {
          final hoursPerDay = totalHours / daysUntilDeadline;
          
          if (hoursPerDay > 10) {
            riskScore += 0.5;
            factors.add('Unsustainable workload (${hoursPerDay.toStringAsFixed(1)} hours/day)');
          } else if (hoursPerDay > 8) {
            riskScore += 0.3;
            factors.add('High workload pressure');
          }
          
          metadata['hours_per_day'] = hoursPerDay;
        }
      }
    }

    // Factor 2: Task distribution
    final inProgressTasks = tasks.where((t) => t.status.isInProgress).length;
    if (inProgressTasks > 3) {
      riskScore += 0.2;
      factors.add('Too many concurrent tasks');
    }

    metadata['risk_score'] = riskScore;
    metadata['in_progress_tasks'] = inProgressTasks;

    final level = riskScore >= 0.8 ? RiskLevel.veryHigh :
                  riskScore >= 0.6 ? RiskLevel.high :
                  riskScore >= 0.4 ? RiskLevel.medium :
                  riskScore >= 0.2 ? RiskLevel.low : RiskLevel.veryLow;

    return (
      level: level,
      confidence: 70.0,
      factors: factors,
      metadata: metadata,
    );
  }

  // Helper methods

  DateTime? _calculateWeightedPrediction(List<DateTime> predictions) {
    if (predictions.isEmpty) return null;
    if (predictions.length == 1) return predictions.first;

    // Simple average for now - in production would use weighted average
    final totalMilliseconds = predictions
        .map((p) => p.millisecondsSinceEpoch)
        .reduce((a, b) => a + b);
    
    final avgMilliseconds = totalMilliseconds ~/ predictions.length;
    return DateTime.fromMillisecondsSinceEpoch(avgMilliseconds);
  }

  double _calculateCompletionDateConfidence(
    Project project,
    List<TaskModel> tasks,
    List<DateTime> predictions,
  ) {
    var confidence = 50.0; // Base confidence

    // Increase confidence based on data quality
    final tasksWithEstimates = tasks.where((t) => t.estimatedDuration != null).length;
    confidence += (tasksWithEstimates / tasks.length) * 20;

    final completedTasks = tasks.where((t) => t.status.isCompleted).length;
    confidence += (completedTasks / tasks.length) * 15;

    // Increase confidence if predictions are consistent
    if (predictions.length > 1) {
      final maxDifference = predictions
          .map((p) => p.millisecondsSinceEpoch)
          .reduce((a, b) => max(a, b)) -
          predictions
          .map((p) => p.millisecondsSinceEpoch)
          .reduce((a, b) => min(a, b));
      
      final daysDifference = maxDifference / (1000 * 60 * 60 * 24);
      if (daysDifference < 14) {
        confidence += 15;
      } else if (daysDifference < 30) {
        confidence += 10;
      }
    }

    return min(100.0, confidence);
  }

  PredictionConfidence _confidenceScoreToLevel(double score) {
    if (score >= 90) return PredictionConfidence.veryHigh;
    if (score >= 75) return PredictionConfidence.high;
    if (score >= 60) return PredictionConfidence.medium;
    if (score >= 40) return PredictionConfidence.low;
    return PredictionConfidence.veryLow;
  }

  RiskLevel _calculateCompletionDateRisk(Project project, DateTime predictedDate) {
    if (project.deadline == null) return RiskLevel.low;

    final daysLate = predictedDate.difference(project.deadline!).inDays;
    
    if (daysLate > 30) return RiskLevel.veryHigh;
    if (daysLate > 14) return RiskLevel.high;
    if (daysLate > 7) return RiskLevel.medium;
    if (daysLate > 0) return RiskLevel.low;
    return RiskLevel.veryLow;
  }

  RiskLevel _calculateOverallRisk(List<ProjectPrediction> predictions) {
    if (predictions.isEmpty) return RiskLevel.medium;

    final riskLevels = predictions.map((p) => p.riskLevel).toList();
    final highRiskCount = riskLevels.where((r) => 
        r == RiskLevel.high || r == RiskLevel.veryHigh).length;
    
    if (highRiskCount > predictions.length * 0.5) return RiskLevel.high;
    if (highRiskCount > predictions.length * 0.3) return RiskLevel.medium;
    return RiskLevel.low;
  }

  double _calculateSuccessProbability(
    Project project,
    List<TaskModel> tasks,
    List<ProjectPrediction> predictions,
  ) {
    var successProbability = 70.0; // Base probability

    // Adjust based on completion rate
    final completionRate = tasks.where((t) => t.status.isCompleted).length / tasks.length;
    successProbability += (completionRate - 0.5) * 40;

    // Adjust based on risk levels
    final highRiskPredictions = predictions.where((p) => 
        p.riskLevel == RiskLevel.high || p.riskLevel == RiskLevel.veryHigh).length;
    successProbability -= highRiskPredictions * 10;

    // Adjust based on deadline pressure
    if (project.deadline != null) {
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      final remainingTasks = tasks.where((t) => !t.status.isCompleted).length;
      
      if (daysUntilDeadline > 0 && remainingTasks > daysUntilDeadline) {
        successProbability -= 20;
      }
    }

    return max(0.0, min(100.0, successProbability));
  }

  List<String> _identifyRiskFactors(
    Project project,
    List<TaskModel> tasks,
    List<ProjectPrediction> predictions,
  ) {
    final riskFactors = <String>[];

    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    if (overdueTasks > 0) {
      riskFactors.add('$overdueTasks tasks are overdue');
    }

    final blockedTasks = tasks.where((t) => t.dependencies.isNotEmpty && !t.status.isCompleted).length;
    if (blockedTasks > 0) {
      riskFactors.add('$blockedTasks tasks are blocked by dependencies');
    }

    if (project.deadline != null) {
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      if (daysUntilDeadline < 7 && daysUntilDeadline > 0) {
        riskFactors.add('Deadline approaching in $daysUntilDeadline days');
      }
    }

    final inProgressTasks = tasks.where((t) => t.status.isInProgress).length;
    if (inProgressTasks > 5) {
      riskFactors.add('High work-in-progress count may reduce focus');
    }

    final highRiskPredictions = predictions.where((p) => p.riskLevel == RiskLevel.high).length;
    if (highRiskPredictions > 0) {
      riskFactors.add('$highRiskPredictions predictions indicate high risk');
    }

    return riskFactors;
  }

  List<String> _generateRecommendedActions(
    Project project,
    List<TaskModel> tasks,
    List<ProjectPrediction> predictions,
  ) {
    final actions = <String>[];

    // Actions based on overdue tasks
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    if (overdueTasks > 0) {
      actions.add('Prioritize and complete $overdueTasks overdue tasks immediately');
    }

    // Actions based on deadline pressure
    if (project.deadline != null) {
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      if (daysUntilDeadline < 14 && daysUntilDeadline > 0) {
        actions.add('Focus on critical path tasks only');
        actions.add('Consider reducing scope or extending deadline');
      }
    }

    // Actions based on work-in-progress
    final inProgressTasks = tasks.where((t) => t.status.isInProgress).length;
    if (inProgressTasks > 3) {
      actions.add('Implement WIP limits to improve focus');
    }

    // Actions based on predictions
    final highRiskPredictions = predictions.where((p) => p.riskLevel == RiskLevel.high).toList();
    if (highRiskPredictions.isNotEmpty) {
      actions.add('Address high-risk areas identified in predictions');
    }

    // General actions for health
    if (actions.length < 3) {
      actions.add('Maintain regular progress reviews');
      actions.add('Keep stakeholders informed of project status');
    }

    return actions;
  }

  Map<String, double> _forecastWeeklyWorkload(Project project, List<TaskModel> tasks) {
    final forecast = <String, double>{};
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    
    if (remainingTasks.isEmpty) return forecast;

    // Simple distribution over 4 weeks
    final tasksPerWeek = remainingTasks.length / 4;
    
    for (int week = 1; week <= 4; week++) {
      forecast['week_$week'] = tasksPerWeek;
    }

    return forecast;
  }

  Map<String, int> _forecastSkillRequirements(Project project, List<TaskModel> tasks) {
    final requirements = <String, int>{};
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).toList();
    
    for (final task in remainingTasks) {
      for (final tag in task.tags) {
        requirements[tag] = (requirements[tag] ?? 0) + 1;
      }
    }

    return requirements;
  }

  RiskLevel _calculateWorkloadRisk(Map<String, double> weeklyWorkload) {
    if (weeklyWorkload.isEmpty) return RiskLevel.low;

    final maxWeeklyLoad = weeklyWorkload.values.reduce(max);
    
    if (maxWeeklyLoad > 20) return RiskLevel.high;
    if (maxWeeklyLoad > 15) return RiskLevel.medium;
    return RiskLevel.low;
  }

  double _predictDefectRate(Project project, List<TaskModel> tasks) {
    // Simple heuristic based on task completion patterns
    final completedTasks = tasks.where((t) => t.status.isCompleted && t.dueDate != null).toList();
    
    if (completedTasks.length < 3) return 0.1; // Default low rate

    final rushedTasks = completedTasks.where((t) {
      if (t.completedAt == null) return false;
      return t.dueDate!.difference(t.completedAt!).inHours < 4; // Completed very close to deadline
    }).length;

    return min(0.5, rushedTasks / completedTasks.length + 0.05);
  }
}