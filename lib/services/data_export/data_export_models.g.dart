// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportData _$ExportDataFromJson(Map<String, dynamic> json) => ExportData(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      projects: (json['projects'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      appVersion: json['appVersion'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ExportDataToJson(ExportData instance) =>
    <String, dynamic>{
      'tasks': instance.tasks,
      'projects': instance.projects,
      'tags': instance.tags,
      'exportedAt': instance.exportedAt.toIso8601String(),
      'appVersion': instance.appVersion,
      'metadata': instance.metadata,
    };

ImportValidationResult _$ImportValidationResultFromJson(
        Map<String, dynamic> json) =>
    ImportValidationResult(
      isValid: json['isValid'] as bool,
      errors:
          (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
      warnings:
          (json['warnings'] as List<dynamic>).map((e) => e as String).toList(),
      taskCount: (json['taskCount'] as num).toInt(),
      projectCount: (json['projectCount'] as num).toInt(),
      tagCount: (json['tagCount'] as num).toInt(),
    );

Map<String, dynamic> _$ImportValidationResultToJson(
        ImportValidationResult instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'errors': instance.errors,
      'warnings': instance.warnings,
      'taskCount': instance.taskCount,
      'projectCount': instance.projectCount,
      'tagCount': instance.tagCount,
    };

ImportOptions _$ImportOptionsFromJson(Map<String, dynamic> json) =>
    ImportOptions(
      overwriteExisting: json['overwriteExisting'] as bool? ?? false,
      createMissingProjects: json['createMissingProjects'] as bool? ?? true,
      createMissingTags: json['createMissingTags'] as bool? ?? true,
      preserveIds: json['preserveIds'] as bool? ?? false,
      excludeFields: (json['excludeFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ImportOptionsToJson(ImportOptions instance) =>
    <String, dynamic>{
      'overwriteExisting': instance.overwriteExisting,
      'createMissingProjects': instance.createMissingProjects,
      'createMissingTags': instance.createMissingTags,
      'preserveIds': instance.preserveIds,
      'excludeFields': instance.excludeFields,
    };

BackupMetadata _$BackupMetadataFromJson(Map<String, dynamic> json) =>
    BackupMetadata(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      appVersion: json['appVersion'] as String,
      taskCount: (json['taskCount'] as num).toInt(),
      projectCount: (json['projectCount'] as num).toInt(),
      tagCount: (json['tagCount'] as num).toInt(),
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      checksum: json['checksum'] as String,
    );

Map<String, dynamic> _$BackupMetadataToJson(BackupMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'appVersion': instance.appVersion,
      'taskCount': instance.taskCount,
      'projectCount': instance.projectCount,
      'tagCount': instance.tagCount,
      'fileSizeBytes': instance.fileSizeBytes,
      'checksum': instance.checksum,
    };
