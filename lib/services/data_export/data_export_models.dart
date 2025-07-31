import 'package:json_annotation/json_annotation.dart';

part 'data_export_models.g.dart';

enum ExportFormat {
  json,
  csv,
  plainText,
}

enum ImportResult {
  success,
  partialSuccess,
  failure,
}

@JsonSerializable()
class ExportData {
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> projects;
  final List<String> tags;
  final DateTime exportedAt;
  final String appVersion;
  final Map<String, dynamic> metadata;

  const ExportData({
    required this.tasks,
    required this.projects,
    required this.tags,
    required this.exportedAt,
    required this.appVersion,
    this.metadata = const {},
  });

  factory ExportData.fromJson(Map<String, dynamic> json) =>
      _$ExportDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExportDataToJson(this);
}

@JsonSerializable()
class ImportValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int taskCount;
  final int projectCount;
  final int tagCount;

  const ImportValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.taskCount,
    required this.projectCount,
    required this.tagCount,
  });

  factory ImportValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ImportValidationResultFromJson(json);

  Map<String, dynamic> toJson() => _$ImportValidationResultToJson(this);
}

@JsonSerializable()
class ImportOptions {
  final bool overwriteExisting;
  final bool createMissingProjects;
  final bool createMissingTags;
  final bool preserveIds;
  final List<String> excludeFields;

  const ImportOptions({
    this.overwriteExisting = false,
    this.createMissingProjects = true,
    this.createMissingTags = true,
    this.preserveIds = false,
    this.excludeFields = const [],
  });

  factory ImportOptions.fromJson(Map<String, dynamic> json) =>
      _$ImportOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$ImportOptionsToJson(this);

  ImportOptions copyWith({
    bool? overwriteExisting,
    bool? createMissingProjects,
    bool? createMissingTags,
    bool? preserveIds,
    List<String>? excludeFields,
  }) {
    return ImportOptions(
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
      createMissingProjects: createMissingProjects ?? this.createMissingProjects,
      createMissingTags: createMissingTags ?? this.createMissingTags,
      preserveIds: preserveIds ?? this.preserveIds,
      excludeFields: excludeFields ?? this.excludeFields,
    );
  }
}

@JsonSerializable()
class BackupMetadata {
  final String id;
  final DateTime createdAt;
  final String appVersion;
  final int taskCount;
  final int projectCount;
  final int tagCount;
  final int fileSizeBytes;
  final String checksum;

  const BackupMetadata({
    required this.id,
    required this.createdAt,
    required this.appVersion,
    required this.taskCount,
    required this.projectCount,
    required this.tagCount,
    required this.fileSizeBytes,
    required this.checksum,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) =>
      _$BackupMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$BackupMetadataToJson(this);
}

class ExportProgress {
  final int totalItems;
  final int processedItems;
  final String currentOperation;
  final double progress;

  const ExportProgress({
    required this.totalItems,
    required this.processedItems,
    required this.currentOperation,
    required this.progress,
  });

  ExportProgress copyWith({
    int? totalItems,
    int? processedItems,
    String? currentOperation,
    double? progress,
  }) {
    return ExportProgress(
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      currentOperation: currentOperation ?? this.currentOperation,
      progress: progress ?? this.progress,
    );
  }
}

class ImportProgress {
  final int totalItems;
  final int processedItems;
  final String currentOperation;
  final double progress;
  final List<String> errors;

  const ImportProgress({
    required this.totalItems,
    required this.processedItems,
    required this.currentOperation,
    required this.progress,
    this.errors = const [],
  });

  ImportProgress copyWith({
    int? totalItems,
    int? processedItems,
    String? currentOperation,
    double? progress,
    List<String>? errors,
  }) {
    return ImportProgress(
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      currentOperation: currentOperation ?? this.currentOperation,
      progress: progress ?? this.progress,
      errors: errors ?? this.errors,
    );
  }
}

class DataExportException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DataExportException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'DataExportException: $message';
}

class DataImportException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DataImportException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'DataImportException: $message';
}