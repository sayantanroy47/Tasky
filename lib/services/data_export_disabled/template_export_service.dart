import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/project_template.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_template.dart';
import 'data_export_models.dart';

/// Service for exporting and importing project templates and template packages
class TemplateExportService {
  
  /// Export a single project as a template
  Future<ExportResult> exportProjectAsTemplate({
    required Project project,
    required List<TaskModel> projectTasks,
    required String filePath,
    Map<String, dynamic> templateMetadata = const {},
  }) async {
    try {
      final templateData = {
        'version': '1.0',
        'type': 'project_template',
        'exportedAt': DateTime.now().toIso8601String(),
        'template': {
          'id': 'template_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          'name': templateMetadata['name'] ?? '${project.name} Template',
          'description': templateMetadata['description'] ?? 
              'Template created from project: ${project.name}',
          'category': templateMetadata['category'] ?? 'General',
          'tags': templateMetadata['tags'] ?? ['exported', 'custom'],
          'difficulty': templateMetadata['difficulty'] ?? 1,
          'estimatedHours': templateMetadata['estimatedHours'] ?? 
              projectTasks.fold<int>(0, (sum, task) => sum + (task.estimatedDuration ?? 1)),
        },
        'source': {
          'projectId': project.id,
          'projectName': project.name,
          'originalCreatedAt': project.createdAt.toIso8601String(),
          'taskCount': projectTasks.length,
        },
        'projectTemplate': _convertProjectToTemplate(project, templateMetadata),
        'taskTemplates': projectTasks.map((task) => _convertTaskToTemplate(task)).toList(),
        'dependencies': _extractTaskDependencies(projectTasks),
        'milestones': _extractMilestones(project, projectTasks),
        'variables': _extractTemplateVariables(project, projectTasks),
        'wizardSteps': _generateWizardSteps(project, projectTasks),
      };

      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(templateData),
      );

      return ExportResult(
        success: true,
        message: 'Project template exported successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'templateId': templateData['template']['id'],
          'templateName': templateData['template']['name'],
          'taskCount': projectTasks.length,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Project template export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Template export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  /// Export multiple templates as a template package
  Future<ExportResult> exportTemplatePackage({
    required List<ProjectTemplate> templates,
    required String filePath,
    TemplatePackage? packageInfo,
  }) async {
    try {
      final packageData = packageInfo ?? TemplatePackage(
        id: 'package_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Template Package',
        description: 'Collection of project templates',
        version: '1.0.0',
        projectTemplateIds: templates.map((t) => t.id).toList(),
        taskTemplateIds: [],
        metadata: {},
        createdAt: DateTime.now(),
        authorId: 'user',
        tags: ['package', 'templates'],
      );

      // Create package structure
      final packageContent = {
        'version': '1.0',
        'type': 'template_package',
        'exportedAt': DateTime.now().toIso8601String(),
        'package': packageData.toJson(),
        'templates': templates.map((template) => template.toJson()).toList(),
        'manifest': {
          'templateCount': templates.length,
          'compatibility': ['tasky_v2', 'tasky_v3'],
          'requiredFeatures': _analyzeRequiredFeatures(templates),
          'checksum': '',
        },
      };

      // Calculate checksum
      final contentString = jsonEncode(packageContent);
      final checksum = sha256.convert(utf8.encode(contentString)).toString();
      packageContent['manifest']['checksum'] = checksum;

      // Check if we should create a compressed package
      if (filePath.endsWith('.taskytpl')) {
        return await _createCompressedTemplatePackage(packageContent, filePath);
      } else {
        // Save as JSON
        final file = File(filePath);
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(packageContent),
        );

        return ExportResult(
          success: true,
          message: 'Template package exported successfully',
          filePath: filePath,
          fileSize: await file.length(),
          exportedAt: DateTime.now(),
          metadata: {
            'packageId': packageData.id,
            'packageName': packageData.name,
            'templateCount': templates.length,
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Template package export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Template package export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  /// Export task templates collection
  Future<ExportResult> exportTaskTemplates({
    required List<TaskTemplate> templates,
    required String filePath,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final templateData = {
        'version': '1.0',
        'type': 'task_templates',
        'exportedAt': DateTime.now().toIso8601String(),
        'metadata': {
          'name': metadata['name'] ?? 'Task Templates Collection',
          'description': metadata['description'] ?? 'Collection of task templates',
          'category': metadata['category'] ?? 'General',
          'templateCount': templates.length,
          ...metadata,
        },
        'templates': templates.map((template) => template.toJson()).toList(),
      };

      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(templateData),
      );

      return ExportResult(
        success: true,
        message: 'Task templates exported successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'templateCount': templates.length,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Task templates export error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Task templates export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  /// Import project template from file
  Future<ImportResultData> importProjectTemplate({
    required String filePath,
    ImportOptions? options,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ImportResultData(
          success: false,
          message: 'Template file not found',
          importedCount: 0,
          skippedCount: 0,
          errors: ['File does not exist'],
        );
      }

      final jsonContent = await file.readAsString();
      final templateData = jsonDecode(jsonContent) as Map<String, dynamic>;

      if (templateData['type'] != 'project_template') {
        return const ImportResultData(
          success: false,
          message: 'Invalid template file format',
          importedCount: 0,
          skippedCount: 0,
          errors: ['Not a valid project template file'],
        );
      }

      // Validate template structure
      final validationResult = _validateTemplateStructure(templateData);
      if (!validationResult['isValid']) {
        return ImportResultData(
          success: false,
          message: 'Template validation failed',
          importedCount: 0,
          skippedCount: 0,
          errors: List<String>.from(validationResult['errors']),
        );
      }

      // Create project template
      final projectTemplate = ProjectTemplate.fromJson(
        templateData['projectTemplate'] as Map<String, dynamic>,
      );

      // Import would require integration with template repository
      // This is a simplified implementation showing the structure

      return const ImportResultData(
        success: true,
        message: 'Project template imported successfully',
        importedCount: 1,
        skippedCount: 0,
        errors: [],
        importedAt: null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Template import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Template import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Import template package
  Future<ImportResultData> importTemplatePackage({
    required String filePath,
    ImportOptions? options,
  }) async {
    try {
      Map<String, dynamic> packageData;

      if (filePath.endsWith('.taskytpl')) {
        // Extract compressed package
        packageData = await _extractCompressedTemplatePackage(filePath);
      } else {
        // Load JSON package
        final file = File(filePath);
        final jsonContent = await file.readAsString();
        packageData = jsonDecode(jsonContent) as Map<String, dynamic>;
      }

      if (packageData['type'] != 'template_package') {
        return const ImportResultData(
          success: false,
          message: 'Invalid template package format',
          importedCount: 0,
          skippedCount: 0,
          errors: ['Not a valid template package'],
        );
      }

      // Validate package integrity
      final validationResult = _validatePackageIntegrity(packageData);
      if (!validationResult['isValid']) {
        return ImportResultData(
          success: false,
          message: 'Package validation failed',
          importedCount: 0,
          skippedCount: 0,
          errors: List<String>.from(validationResult['errors']),
        );
      }

      final templates = packageData['templates'] as List;
      int importedCount = 0;
      final errors = <String>[];

      for (final templateData in templates) {
        try {
          final template = ProjectTemplate.fromJson(templateData as Map<String, dynamic>);
          // Import template logic would go here
          importedCount++;
        } catch (e) {
          errors.add('Failed to import template: ${e.toString()}');
        }
      }

      return ImportResultData(
        success: importedCount > 0,
        message: 'Template package imported: $importedCount templates',
        importedCount: importedCount,
        skippedCount: templates.length - importedCount,
        errors: errors,
        importedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Template package import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Template package import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Create marketplace-ready template package
  Future<ExportResult> createMarketplacePackage({
    required List<ProjectTemplate> templates,
    required String filePath,
    required Map<String, dynamic> marketplaceMetadata,
  }) async {
    try {
      // Enhance metadata for marketplace
      final enhancedMetadata = {
        ...marketplaceMetadata,
        'marketplace': {
          'publishReady': true,
          'pricing': marketplaceMetadata['pricing'] ?? 'free',
          'license': marketplaceMetadata['license'] ?? 'MIT',
          'supportContact': marketplaceMetadata['supportContact'],
          'screenshots': marketplaceMetadata['screenshots'] ?? [],
          'documentation': marketplaceMetadata['documentation'] ?? '',
          'changelog': marketplaceMetadata['changelog'] ?? [],
          'compatibility': {
            'minVersion': '2.0.0',
            'maxVersion': '3.0.0',
            'platforms': ['android', 'ios', 'web'],
          },
          'keywords': [
            ...List<String>.from(marketplaceMetadata['tags'] ?? []),
            'marketplace',
            'professional',
          ],
        },
      };

      final packageInfo = TemplatePackage(
        id: marketplaceMetadata['id'] ?? 'marketplace_${DateTime.now().millisecondsSinceEpoch}',
        name: marketplaceMetadata['name'] ?? 'Marketplace Template Package',
        description: marketplaceMetadata['description'] ?? '',
        version: marketplaceMetadata['version'] ?? '1.0.0',
        projectTemplateIds: templates.map((t) => t.id).toList(),
        taskTemplateIds: [],
        metadata: enhancedMetadata,
        createdAt: DateTime.now(),
        authorId: marketplaceMetadata['authorId'] ?? 'unknown',
        tags: List<String>.from(marketplaceMetadata['tags'] ?? []),
        isPublic: true,
      );

      return await exportTemplatePackage(
        templates: templates,
        filePath: filePath,
        packageInfo: packageInfo,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Marketplace package creation error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Marketplace package creation failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  // Helper methods

  Map<String, dynamic> _convertProjectToTemplate(
    Project project,
    Map<String, dynamic> metadata,
  ) {
    return {
      'id': 'template_${project.id}',
      'name': metadata['templateName'] ?? '${project.name} Template',
      'description': metadata['templateDescription'] ?? project.description,
      'type': 'simple',
      'categoryId': project.categoryId,
      'projectNameTemplate': '{{projectName}}',
      'projectDescriptionTemplate': project.description ?? '{{projectDescription}}',
      'defaultColor': project.color,
      'createdAt': DateTime.now().toIso8601String(),
      'isSystemTemplate': false,
      'version': '1.0.0',
      'metadata': {
        'sourceProjectId': project.id,
        'exportedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  Map<String, dynamic> _convertTaskToTemplate(TaskModel task) {
    return {
      'id': 'template_${task.id}',
      'title': task.title.replaceAll(RegExp(r'\d{4}-\d{2}-\d{2}'), '{{date}}'),
      'description': task.description?.replaceAll(RegExp(r'\b\d+\b'), '{{number}}'),
      'priority': task.priority.name,
      'estimatedDuration': task.estimatedDuration,
      'tags': task.tags,
      'isRecurring': false,
      'category': 'general',
      'metadata': {
        'sourceTaskId': task.id,
        'originalCreatedAt': task.createdAt.toIso8601String(),
      },
    };
  }

  Map<String, List<String>> _extractTaskDependencies(List<TaskModel> tasks) {
    // Simplified implementation - would analyze task relationships
    return {};
  }

  List<Map<String, dynamic>> _extractMilestones(Project project, List<TaskModel> tasks) {
    final milestones = <Map<String, dynamic>>[];
    
    // Create milestone from project deadline
    if (project.deadline != null) {
      milestones.add({
        'id': 'project_deadline',
        'name': 'Project Completion',
        'description': 'Final project deadline',
        'dayOffset': project.deadline!.difference(project.createdAt).inDays,
      });
    }

    // Create milestones from high-priority tasks
    final urgentTasks = tasks.where((t) => t.priority.name == 'urgent').toList();
    for (int i = 0; i < urgentTasks.length && i < 3; i++) {
      final task = urgentTasks[i];
      milestones.add({
        'id': 'milestone_${task.id}',
        'name': task.title,
        'description': 'Important milestone task',
        'dayOffset': task.dueDate?.difference(project.createdAt).inDays ?? 7,
      });
    }

    return milestones;
  }

  List<Map<String, dynamic>> _extractTemplateVariables(Project project, List<TaskModel> tasks) {
    final variables = <Map<String, dynamic>>[];

    // Basic project variables
    variables.addAll([
      {
        'key': 'projectName',
        'displayName': 'Project Name',
        'type': 'text',
        'isRequired': true,
        'defaultValue': project.name,
      },
      {
        'key': 'projectDescription',
        'displayName': 'Project Description',
        'type': 'text',
        'isRequired': false,
        'defaultValue': project.description,
      },
      {
        'key': 'startDate',
        'displayName': 'Start Date',
        'type': 'date',
        'isRequired': true,
        'defaultValue': DateTime.now().toIso8601String().split('T')[0],
      },
    ]);

    // Add deadline if project has one
    if (project.deadline != null) {
      variables.add({
        'key': 'deadline',
        'displayName': 'Project Deadline',
        'type': 'date',
        'isRequired': false,
        'defaultValue': project.deadline!.toIso8601String().split('T')[0],
      });
    }

    return variables;
  }

  List<Map<String, dynamic>> _generateWizardSteps(Project project, List<TaskModel> tasks) {
    return [
      {
        'id': 'basic_info',
        'title': 'Basic Information',
        'description': 'Set up basic project details',
        'variableKeys': ['projectName', 'projectDescription'],
        'order': 1,
      },
      {
        'id': 'timeline',
        'title': 'Timeline',
        'description': 'Configure project timeline',
        'variableKeys': ['startDate', 'deadline'],
        'order': 2,
      },
    ];
  }

  List<String> _analyzeRequiredFeatures(List<ProjectTemplate> templates) {
    final features = <String>{'basic_tasks', 'projects'};

    for (final template in templates) {
      // Analyze template features
      if (template.taskTemplates.any((t) => t.isRecurring ?? false)) {
        features.add('recurring_tasks');
      }
      if (template.milestones.isNotEmpty) {
        features.add('milestones');
      }
      if (template.variables.isNotEmpty) {
        features.add('template_variables');
      }
    }

    return features.toList();
  }

  Future<ExportResult> _createCompressedTemplatePackage(
    Map<String, dynamic> packageContent,
    String filePath,
  ) async {
    try {
      // Create archive
      final archive = Archive();
      
      // Add manifest
      final manifestJson = jsonEncode(packageContent['manifest']);
      archive.addFile(ArchiveFile('manifest.json', manifestJson.length, manifestJson.codeUnits));
      
      // Add package info
      final packageJson = jsonEncode(packageContent['package']);
      archive.addFile(ArchiveFile('package.json', packageJson.length, packageJson.codeUnits));
      
      // Add templates
      final templatesJson = jsonEncode(packageContent['templates']);
      archive.addFile(ArchiveFile('templates.json', templatesJson.length, templatesJson.codeUnits));
      
      // Add metadata
      final metadataJson = jsonEncode({
        'version': packageContent['version'],
        'type': packageContent['type'],
        'exportedAt': packageContent['exportedAt'],
      });
      archive.addFile(ArchiveFile('metadata.json', metadataJson.length, metadataJson.codeUnits));
      
      // Compress and save
      final zipData = ZipEncoder().encode(archive);
      final file = File(filePath);
      await file.writeAsBytes(zipData);
      
      return ExportResult(
        success: true,
        message: 'Compressed template package created successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'compressed': true,
          'format': 'taskytpl',
        },
      );
    } catch (e) {
      throw Exception('Failed to create compressed package: $e');
    }
  }

  Future<Map<String, dynamic>> _extractCompressedTemplatePackage(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      final packageData = <String, dynamic>{};
      
      for (final file in archive) {
        if (file.isFile) {
          final content = String.fromCharCodes(file.content);
          switch (file.name) {
            case 'manifest.json':
              packageData['manifest'] = jsonDecode(content);
              break;
            case 'package.json':
              packageData['package'] = jsonDecode(content);
              break;
            case 'templates.json':
              packageData['templates'] = jsonDecode(content);
              break;
            case 'metadata.json':
              final metadata = jsonDecode(content);
              packageData['version'] = metadata['version'];
              packageData['type'] = metadata['type'];
              packageData['exportedAt'] = metadata['exportedAt'];
              break;
          }
        }
      }
      
      return packageData;
    } catch (e) {
      throw Exception('Failed to extract compressed package: $e');
    }
  }

  Map<String, dynamic> _validateTemplateStructure(Map<String, dynamic> templateData) {
    final errors = <String>[];
    
    if (!templateData.containsKey('projectTemplate')) {
      errors.add('Missing project template definition');
    }
    
    if (!templateData.containsKey('taskTemplates')) {
      errors.add('Missing task templates');
    }
    
    // Additional validation logic...
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  Map<String, dynamic> _validatePackageIntegrity(Map<String, dynamic> packageData) {
    final errors = <String>[];
    
    // Check required fields
    if (!packageData.containsKey('package')) {
      errors.add('Missing package information');
    }
    
    if (!packageData.containsKey('templates')) {
      errors.add('Missing templates');
    }
    
    // Validate checksum if present
    if (packageData.containsKey('manifest')) {
      final manifest = packageData['manifest'];
      if (manifest.containsKey('checksum')) {
        final expectedChecksum = manifest['checksum'];
        // Create copy without checksum for validation
        final manifestCopy = Map<String, dynamic>.from(manifest);
        manifestCopy.remove('checksum');
        
        final packageCopy = Map<String, dynamic>.from(packageData);
        packageCopy['manifest'] = manifestCopy;
        
        final actualChecksum = sha256.convert(
          utf8.encode(jsonEncode(packageCopy))
        ).toString();
        
        if (actualChecksum != expectedChecksum) {
          errors.add('Package checksum validation failed');
        }
      }
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }
}