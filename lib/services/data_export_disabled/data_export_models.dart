import 'package:json_annotation/json_annotation.dart';


part 'data_export_models.g.dart';

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
  });  @override
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
  });  @override
  String toString() => 'DataImportException: $message';
}

class ExportResult {
  final bool success;
  final String message;
  final String? filePath;
  final int fileSize;
  final DateTime? exportedAt;
  final Map<String, dynamic> metadata;

  const ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.fileSize = 0,
    this.exportedAt,
    this.metadata = const {},
  });
}

class ImportResultData {
  final bool success;
  final String message;
  final int importedCount;
  final int skippedCount;
  final List<String> errors;
  final DateTime? importedAt;
  final Map<String, dynamic> metadata;

  const ImportResultData({
    required this.success,
    required this.message,
    this.importedCount = 0,
    this.skippedCount = 0,
    this.errors = const [],
    this.importedAt,
    this.metadata = const {},
  });
}

class ExportOptions {
  final bool includeCompleted;
  final bool includeArchived;
  final bool includeSubtasks;
  final bool includeDependencies;
  final List<String> selectedFields;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool includeAnalytics;
  final bool includeCharts;
  final bool includeTimeline;
  final bool includeResources;
  final String? templateTheme;
  final Map<String, dynamic> customOptions;

  const ExportOptions({
    this.includeCompleted = true,
    this.includeArchived = false,
    this.includeSubtasks = true,
    this.includeDependencies = true,
    this.selectedFields = const [],
    this.dateFrom,
    this.dateTo,
    this.includeAnalytics = false,
    this.includeCharts = false,
    this.includeTimeline = false,
    this.includeResources = false,
    this.templateTheme,
    this.customOptions = const {},
  });

  ExportOptions copyWith({
    bool? includeCompleted,
    bool? includeArchived,
    bool? includeSubtasks,
    bool? includeDependencies,
    List<String>? selectedFields,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? includeAnalytics,
    bool? includeCharts,
    bool? includeTimeline,
    bool? includeResources,
    String? templateTheme,
    Map<String, dynamic>? customOptions,
  }) {
    return ExportOptions(
      includeCompleted: includeCompleted ?? this.includeCompleted,
      includeArchived: includeArchived ?? this.includeArchived,
      includeSubtasks: includeSubtasks ?? this.includeSubtasks,
      includeDependencies: includeDependencies ?? this.includeDependencies,
      selectedFields: selectedFields ?? this.selectedFields,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      includeAnalytics: includeAnalytics ?? this.includeAnalytics,
      includeCharts: includeCharts ?? this.includeCharts,
      includeTimeline: includeTimeline ?? this.includeTimeline,
      includeResources: includeResources ?? this.includeResources,
      templateTheme: templateTheme ?? this.templateTheme,
      customOptions: customOptions ?? this.customOptions,
    );
  }
}

enum ImportSource {
  csv,
  json,
  trello,
  asana,
  microsoftProject,
  notion,
  todoist,
  jira,
  slack,
  excel,
}

@JsonSerializable()
class ExternalPlatformConfig {
  final ImportSource source;
  final String? apiKey;
  final String? baseUrl;
  final Map<String, String> headers;
  final Map<String, String> fieldMappings;
  final bool requiresAuthentication;

  const ExternalPlatformConfig({
    required this.source,
    this.apiKey,
    this.baseUrl,
    this.headers = const {},
    this.fieldMappings = const {},
    this.requiresAuthentication = false,
  });

  factory ExternalPlatformConfig.fromJson(Map<String, dynamic> json) =>
      _$ExternalPlatformConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalPlatformConfigToJson(this);
}

@JsonSerializable()
class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> sections;
  final Map<String, dynamic> formatting;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isBuiltIn;
  final String? authorId;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.sections,
    required this.formatting,
    required this.createdAt,
    this.updatedAt,
    this.isBuiltIn = false,
    this.authorId,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$ReportTemplateToJson(this);
}

@JsonSerializable()
class CloudStorageConfig {
  final String provider; // 'googleDrive', 'dropbox', 'oneDrive', 'box'
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? folderId;
  final bool isEnabled;
  final Map<String, dynamic> settings;

  const CloudStorageConfig({
    required this.provider,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.folderId,
    this.isEnabled = false,
    this.settings = const {},
  });

  factory CloudStorageConfig.fromJson(Map<String, dynamic> json) =>
      _$CloudStorageConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CloudStorageConfigToJson(this);
}

@JsonSerializable()
class TemplatePackage {
  final String id;
  final String name;
  final String description;
  final String version;
  final List<String> projectTemplateIds;
  final List<String> taskTemplateIds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String authorId;
  final List<String> tags;
  final bool isPublic;

  const TemplatePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.projectTemplateIds,
    required this.taskTemplateIds,
    required this.metadata,
    required this.createdAt,
    required this.authorId,
    required this.tags,
    this.isPublic = false,
  });

  factory TemplatePackage.fromJson(Map<String, dynamic> json) =>
      _$TemplatePackageFromJson(json);

  Map<String, dynamic> toJson() => _$TemplatePackageToJson(this);
}

class ShareConfig {
  final List<String> recipients;
  final String subject;
  final String message;
  final bool includeAttachment;
  final CloudStorageConfig? cloudStorage;
  final DateTime? expiresAt;
  final bool requiresPassword;
  final String? password;

  const ShareConfig({
    required this.recipients,
    required this.subject,
    this.message = '',
    this.includeAttachment = true,
    this.cloudStorage,
    this.expiresAt,
    this.requiresPassword = false,
    this.password,
  });
}
