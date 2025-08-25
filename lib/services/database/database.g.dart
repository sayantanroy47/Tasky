// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        color,
        categoryId,
        createdAt,
        updatedAt,
        isArchived,
        deadline
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isArchived;
  final DateTime? deadline;
  const Project(
      {required this.id,
      required this.name,
      this.description,
      required this.color,
      this.categoryId,
      required this.createdAt,
      this.updatedAt,
      required this.isArchived,
      this.deadline});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color: Value(color),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isArchived: Value(isArchived),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<String>(json['color']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<String>(color),
      'categoryId': serializer.toJson<String?>(categoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'deadline': serializer.toJson<DateTime?>(deadline),
    };
  }

  Project copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? color,
          Value<String?> categoryId = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          bool? isArchived,
          Value<DateTime?> deadline = const Value.absent()}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        color: color ?? this.color,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        isArchived: isArchived ?? this.isArchived,
        deadline: deadline.present ? deadline.value : this.deadline,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      color: data.color.present ? data.color.value : this.color,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('deadline: $deadline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, color, categoryId,
      createdAt, updatedAt, isArchived, deadline);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.color == this.color &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived &&
          other.deadline == this.deadline);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> color;
  final Value<String?> categoryId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isArchived;
  final Value<DateTime?> deadline;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deadline = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String color,
    this.categoryId = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deadline = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        color = Value(color),
        createdAt = Value(createdAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? color,
    Expression<String>? categoryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
    Expression<DateTime>? deadline,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (deadline != null) 'deadline': deadline,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? color,
      Value<String?>? categoryId,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<bool>? isArchived,
      Value<DateTime?>? deadline,
      Value<int>? rowid}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      deadline: deadline ?? this.deadline,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('deadline: $deadline, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _locationTriggerMeta =
      const VerificationMeta('locationTrigger');
  @override
  late final GeneratedColumn<String> locationTrigger = GeneratedColumn<String>(
      'location_trigger', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _estimatedDurationMeta =
      const VerificationMeta('estimatedDuration');
  @override
  late final GeneratedColumn<int> estimatedDuration = GeneratedColumn<int>(
      'estimated_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _actualDurationMeta =
      const VerificationMeta('actualDuration');
  @override
  late final GeneratedColumn<int> actualDuration = GeneratedColumn<int>(
      'actual_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceTypeMeta =
      const VerificationMeta('recurrenceType');
  @override
  late final GeneratedColumn<int> recurrenceType = GeneratedColumn<int>(
      'recurrence_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
      'recurrence_interval', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceDaysOfWeekMeta =
      const VerificationMeta('recurrenceDaysOfWeek');
  @override
  late final GeneratedColumn<String> recurrenceDaysOfWeek =
      GeneratedColumn<String>('recurrence_days_of_week', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceEndDateMeta =
      const VerificationMeta('recurrenceEndDate');
  @override
  late final GeneratedColumn<DateTime> recurrenceEndDate =
      GeneratedColumn<DateTime>('recurrence_end_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceMaxOccurrencesMeta =
      const VerificationMeta('recurrenceMaxOccurrences');
  @override
  late final GeneratedColumn<int> recurrenceMaxOccurrences =
      GeneratedColumn<int>('recurrence_max_occurrences', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        createdAt,
        updatedAt,
        dueDate,
        completedAt,
        priority,
        status,
        locationTrigger,
        projectId,
        metadata,
        isPinned,
        estimatedDuration,
        actualDuration,
        recurrenceType,
        recurrenceInterval,
        recurrenceDaysOfWeek,
        recurrenceEndDate,
        recurrenceMaxOccurrences
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('location_trigger')) {
      context.handle(
          _locationTriggerMeta,
          locationTrigger.isAcceptableOrUnknown(
              data['location_trigger']!, _locationTriggerMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    } else if (isInserting) {
      context.missing(_metadataMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('estimated_duration')) {
      context.handle(
          _estimatedDurationMeta,
          estimatedDuration.isAcceptableOrUnknown(
              data['estimated_duration']!, _estimatedDurationMeta));
    }
    if (data.containsKey('actual_duration')) {
      context.handle(
          _actualDurationMeta,
          actualDuration.isAcceptableOrUnknown(
              data['actual_duration']!, _actualDurationMeta));
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
          _recurrenceTypeMeta,
          recurrenceType.isAcceptableOrUnknown(
              data['recurrence_type']!, _recurrenceTypeMeta));
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
          _recurrenceIntervalMeta,
          recurrenceInterval.isAcceptableOrUnknown(
              data['recurrence_interval']!, _recurrenceIntervalMeta));
    }
    if (data.containsKey('recurrence_days_of_week')) {
      context.handle(
          _recurrenceDaysOfWeekMeta,
          recurrenceDaysOfWeek.isAcceptableOrUnknown(
              data['recurrence_days_of_week']!, _recurrenceDaysOfWeekMeta));
    }
    if (data.containsKey('recurrence_end_date')) {
      context.handle(
          _recurrenceEndDateMeta,
          recurrenceEndDate.isAcceptableOrUnknown(
              data['recurrence_end_date']!, _recurrenceEndDateMeta));
    }
    if (data.containsKey('recurrence_max_occurrences')) {
      context.handle(
          _recurrenceMaxOccurrencesMeta,
          recurrenceMaxOccurrences.isAcceptableOrUnknown(
              data['recurrence_max_occurrences']!,
              _recurrenceMaxOccurrencesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      locationTrigger: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}location_trigger']),
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      estimatedDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_duration']),
      actualDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_duration']),
      recurrenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_type']),
      recurrenceInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}recurrence_interval']),
      recurrenceDaysOfWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_days_of_week']),
      recurrenceEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}recurrence_end_date']),
      recurrenceMaxOccurrences: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recurrence_max_occurrences']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final int priority;
  final int status;
  final String? locationTrigger;
  final String? projectId;
  final String metadata;
  final bool isPinned;
  final int? estimatedDuration;
  final int? actualDuration;
  final int? recurrenceType;
  final int? recurrenceInterval;
  final String? recurrenceDaysOfWeek;
  final DateTime? recurrenceEndDate;
  final int? recurrenceMaxOccurrences;
  const Task(
      {required this.id,
      required this.title,
      this.description,
      required this.createdAt,
      this.updatedAt,
      this.dueDate,
      this.completedAt,
      required this.priority,
      required this.status,
      this.locationTrigger,
      this.projectId,
      required this.metadata,
      required this.isPinned,
      this.estimatedDuration,
      this.actualDuration,
      this.recurrenceType,
      this.recurrenceInterval,
      this.recurrenceDaysOfWeek,
      this.recurrenceEndDate,
      this.recurrenceMaxOccurrences});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || locationTrigger != null) {
      map['location_trigger'] = Variable<String>(locationTrigger);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['metadata'] = Variable<String>(metadata);
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || estimatedDuration != null) {
      map['estimated_duration'] = Variable<int>(estimatedDuration);
    }
    if (!nullToAbsent || actualDuration != null) {
      map['actual_duration'] = Variable<int>(actualDuration);
    }
    if (!nullToAbsent || recurrenceType != null) {
      map['recurrence_type'] = Variable<int>(recurrenceType);
    }
    if (!nullToAbsent || recurrenceInterval != null) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    }
    if (!nullToAbsent || recurrenceDaysOfWeek != null) {
      map['recurrence_days_of_week'] = Variable<String>(recurrenceDaysOfWeek);
    }
    if (!nullToAbsent || recurrenceEndDate != null) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate);
    }
    if (!nullToAbsent || recurrenceMaxOccurrences != null) {
      map['recurrence_max_occurrences'] =
          Variable<int>(recurrenceMaxOccurrences);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      priority: Value(priority),
      status: Value(status),
      locationTrigger: locationTrigger == null && nullToAbsent
          ? const Value.absent()
          : Value(locationTrigger),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      metadata: Value(metadata),
      isPinned: Value(isPinned),
      estimatedDuration: estimatedDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDuration),
      actualDuration: actualDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDuration),
      recurrenceType: recurrenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceType),
      recurrenceInterval: recurrenceInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceInterval),
      recurrenceDaysOfWeek: recurrenceDaysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceDaysOfWeek),
      recurrenceEndDate: recurrenceEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndDate),
      recurrenceMaxOccurrences: recurrenceMaxOccurrences == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceMaxOccurrences),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
      locationTrigger: serializer.fromJson<String?>(json['locationTrigger']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      metadata: serializer.fromJson<String>(json['metadata']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      estimatedDuration: serializer.fromJson<int?>(json['estimatedDuration']),
      actualDuration: serializer.fromJson<int?>(json['actualDuration']),
      recurrenceType: serializer.fromJson<int?>(json['recurrenceType']),
      recurrenceInterval: serializer.fromJson<int?>(json['recurrenceInterval']),
      recurrenceDaysOfWeek:
          serializer.fromJson<String?>(json['recurrenceDaysOfWeek']),
      recurrenceEndDate:
          serializer.fromJson<DateTime?>(json['recurrenceEndDate']),
      recurrenceMaxOccurrences:
          serializer.fromJson<int?>(json['recurrenceMaxOccurrences']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
      'locationTrigger': serializer.toJson<String?>(locationTrigger),
      'projectId': serializer.toJson<String?>(projectId),
      'metadata': serializer.toJson<String>(metadata),
      'isPinned': serializer.toJson<bool>(isPinned),
      'estimatedDuration': serializer.toJson<int?>(estimatedDuration),
      'actualDuration': serializer.toJson<int?>(actualDuration),
      'recurrenceType': serializer.toJson<int?>(recurrenceType),
      'recurrenceInterval': serializer.toJson<int?>(recurrenceInterval),
      'recurrenceDaysOfWeek': serializer.toJson<String?>(recurrenceDaysOfWeek),
      'recurrenceEndDate': serializer.toJson<DateTime?>(recurrenceEndDate),
      'recurrenceMaxOccurrences':
          serializer.toJson<int?>(recurrenceMaxOccurrences),
    };
  }

  Task copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          int? priority,
          int? status,
          Value<String?> locationTrigger = const Value.absent(),
          Value<String?> projectId = const Value.absent(),
          String? metadata,
          bool? isPinned,
          Value<int?> estimatedDuration = const Value.absent(),
          Value<int?> actualDuration = const Value.absent(),
          Value<int?> recurrenceType = const Value.absent(),
          Value<int?> recurrenceInterval = const Value.absent(),
          Value<String?> recurrenceDaysOfWeek = const Value.absent(),
          Value<DateTime?> recurrenceEndDate = const Value.absent(),
          Value<int?> recurrenceMaxOccurrences = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        locationTrigger: locationTrigger.present
            ? locationTrigger.value
            : this.locationTrigger,
        projectId: projectId.present ? projectId.value : this.projectId,
        metadata: metadata ?? this.metadata,
        isPinned: isPinned ?? this.isPinned,
        estimatedDuration: estimatedDuration.present
            ? estimatedDuration.value
            : this.estimatedDuration,
        actualDuration:
            actualDuration.present ? actualDuration.value : this.actualDuration,
        recurrenceType:
            recurrenceType.present ? recurrenceType.value : this.recurrenceType,
        recurrenceInterval: recurrenceInterval.present
            ? recurrenceInterval.value
            : this.recurrenceInterval,
        recurrenceDaysOfWeek: recurrenceDaysOfWeek.present
            ? recurrenceDaysOfWeek.value
            : this.recurrenceDaysOfWeek,
        recurrenceEndDate: recurrenceEndDate.present
            ? recurrenceEndDate.value
            : this.recurrenceEndDate,
        recurrenceMaxOccurrences: recurrenceMaxOccurrences.present
            ? recurrenceMaxOccurrences.value
            : this.recurrenceMaxOccurrences,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      locationTrigger: data.locationTrigger.present
          ? data.locationTrigger.value
          : this.locationTrigger,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      estimatedDuration: data.estimatedDuration.present
          ? data.estimatedDuration.value
          : this.estimatedDuration,
      actualDuration: data.actualDuration.present
          ? data.actualDuration.value
          : this.actualDuration,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      recurrenceDaysOfWeek: data.recurrenceDaysOfWeek.present
          ? data.recurrenceDaysOfWeek.value
          : this.recurrenceDaysOfWeek,
      recurrenceEndDate: data.recurrenceEndDate.present
          ? data.recurrenceEndDate.value
          : this.recurrenceEndDate,
      recurrenceMaxOccurrences: data.recurrenceMaxOccurrences.present
          ? data.recurrenceMaxOccurrences.value
          : this.recurrenceMaxOccurrences,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('locationTrigger: $locationTrigger, ')
          ..write('projectId: $projectId, ')
          ..write('metadata: $metadata, ')
          ..write('isPinned: $isPinned, ')
          ..write('estimatedDuration: $estimatedDuration, ')
          ..write('actualDuration: $actualDuration, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceDaysOfWeek: $recurrenceDaysOfWeek, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('recurrenceMaxOccurrences: $recurrenceMaxOccurrences')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      createdAt,
      updatedAt,
      dueDate,
      completedAt,
      priority,
      status,
      locationTrigger,
      projectId,
      metadata,
      isPinned,
      estimatedDuration,
      actualDuration,
      recurrenceType,
      recurrenceInterval,
      recurrenceDaysOfWeek,
      recurrenceEndDate,
      recurrenceMaxOccurrences);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dueDate == this.dueDate &&
          other.completedAt == this.completedAt &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.locationTrigger == this.locationTrigger &&
          other.projectId == this.projectId &&
          other.metadata == this.metadata &&
          other.isPinned == this.isPinned &&
          other.estimatedDuration == this.estimatedDuration &&
          other.actualDuration == this.actualDuration &&
          other.recurrenceType == this.recurrenceType &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.recurrenceDaysOfWeek == this.recurrenceDaysOfWeek &&
          other.recurrenceEndDate == this.recurrenceEndDate &&
          other.recurrenceMaxOccurrences == this.recurrenceMaxOccurrences);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> completedAt;
  final Value<int> priority;
  final Value<int> status;
  final Value<String?> locationTrigger;
  final Value<String?> projectId;
  final Value<String> metadata;
  final Value<bool> isPinned;
  final Value<int?> estimatedDuration;
  final Value<int?> actualDuration;
  final Value<int?> recurrenceType;
  final Value<int?> recurrenceInterval;
  final Value<String?> recurrenceDaysOfWeek;
  final Value<DateTime?> recurrenceEndDate;
  final Value<int?> recurrenceMaxOccurrences;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.locationTrigger = const Value.absent(),
    this.projectId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.estimatedDuration = const Value.absent(),
    this.actualDuration = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceDaysOfWeek = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.recurrenceMaxOccurrences = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int priority,
    required int status,
    this.locationTrigger = const Value.absent(),
    this.projectId = const Value.absent(),
    required String metadata,
    this.isPinned = const Value.absent(),
    this.estimatedDuration = const Value.absent(),
    this.actualDuration = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceDaysOfWeek = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.recurrenceMaxOccurrences = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        priority = Value(priority),
        status = Value(status),
        metadata = Value(metadata);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? completedAt,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<String>? locationTrigger,
    Expression<String>? projectId,
    Expression<String>? metadata,
    Expression<bool>? isPinned,
    Expression<int>? estimatedDuration,
    Expression<int>? actualDuration,
    Expression<int>? recurrenceType,
    Expression<int>? recurrenceInterval,
    Expression<String>? recurrenceDaysOfWeek,
    Expression<DateTime>? recurrenceEndDate,
    Expression<int>? recurrenceMaxOccurrences,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dueDate != null) 'due_date': dueDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (locationTrigger != null) 'location_trigger': locationTrigger,
      if (projectId != null) 'project_id': projectId,
      if (metadata != null) 'metadata': metadata,
      if (isPinned != null) 'is_pinned': isPinned,
      if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
      if (actualDuration != null) 'actual_duration': actualDuration,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceDaysOfWeek != null)
        'recurrence_days_of_week': recurrenceDaysOfWeek,
      if (recurrenceEndDate != null) 'recurrence_end_date': recurrenceEndDate,
      if (recurrenceMaxOccurrences != null)
        'recurrence_max_occurrences': recurrenceMaxOccurrences,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? completedAt,
      Value<int>? priority,
      Value<int>? status,
      Value<String?>? locationTrigger,
      Value<String?>? projectId,
      Value<String>? metadata,
      Value<bool>? isPinned,
      Value<int?>? estimatedDuration,
      Value<int?>? actualDuration,
      Value<int?>? recurrenceType,
      Value<int?>? recurrenceInterval,
      Value<String?>? recurrenceDaysOfWeek,
      Value<DateTime?>? recurrenceEndDate,
      Value<int?>? recurrenceMaxOccurrences,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      locationTrigger: locationTrigger ?? this.locationTrigger,
      projectId: projectId ?? this.projectId,
      metadata: metadata ?? this.metadata,
      isPinned: isPinned ?? this.isPinned,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceDaysOfWeek: recurrenceDaysOfWeek ?? this.recurrenceDaysOfWeek,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceMaxOccurrences:
          recurrenceMaxOccurrences ?? this.recurrenceMaxOccurrences,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (locationTrigger.present) {
      map['location_trigger'] = Variable<String>(locationTrigger.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (estimatedDuration.present) {
      map['estimated_duration'] = Variable<int>(estimatedDuration.value);
    }
    if (actualDuration.present) {
      map['actual_duration'] = Variable<int>(actualDuration.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<int>(recurrenceType.value);
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (recurrenceDaysOfWeek.present) {
      map['recurrence_days_of_week'] =
          Variable<String>(recurrenceDaysOfWeek.value);
    }
    if (recurrenceEndDate.present) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate.value);
    }
    if (recurrenceMaxOccurrences.present) {
      map['recurrence_max_occurrences'] =
          Variable<int>(recurrenceMaxOccurrences.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('locationTrigger: $locationTrigger, ')
          ..write('projectId: $projectId, ')
          ..write('metadata: $metadata, ')
          ..write('isPinned: $isPinned, ')
          ..write('estimatedDuration: $estimatedDuration, ')
          ..write('actualDuration: $actualDuration, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceDaysOfWeek: $recurrenceDaysOfWeek, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('recurrenceMaxOccurrences: $recurrenceMaxOccurrences, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubTasksTable extends SubTasks with TableInfo<$SubTasksTable, SubTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, title, isCompleted, completedAt, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<SubTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubTasksTable createAlias(String alias) {
    return $SubTasksTable(attachedDatabase, alias);
  }
}

class SubTask extends DataClass implements Insertable<SubTask> {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;
  final DateTime createdAt;
  const SubTask(
      {required this.id,
      required this.taskId,
      required this.title,
      required this.isCompleted,
      this.completedAt,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubTasksCompanion toCompanion(bool nullToAbsent) {
    return SubTasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubTask(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubTask copyWith(
          {String? id,
          String? taskId,
          String? title,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt}) =>
      SubTask(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  SubTask copyWithCompanion(SubTasksCompanion data) {
    return SubTask(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubTask(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, taskId, title, isCompleted, completedAt, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubTask &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class SubTasksCompanion extends UpdateCompanion<SubTask> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SubTasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubTasksCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<SubTask> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<String>? title,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SubTasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubTasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String? color;
  final DateTime createdAt;
  const Tag(
      {required this.id,
      required this.name,
      this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tag copyWith(
          {String? id,
          String? name,
          Value<String?> color = const Value.absent(),
          DateTime? createdAt}) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color.present ? color.value : this.color,
        createdAt: createdAt ?? this.createdAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> color;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? color,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTagsTable extends TaskTags with TableInfo<$TaskTagsTable, TaskTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [taskId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tags';
  @override
  VerificationContext validateIntegrity(Insertable<TaskTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, tagId};
  @override
  TaskTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTag(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $TaskTagsTable createAlias(String alias) {
    return $TaskTagsTable(attachedDatabase, alias);
  }
}

class TaskTag extends DataClass implements Insertable<TaskTag> {
  final String taskId;
  final String tagId;
  const TaskTag({required this.taskId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  TaskTagsCompanion toCompanion(bool nullToAbsent) {
    return TaskTagsCompanion(
      taskId: Value(taskId),
      tagId: Value(tagId),
    );
  }

  factory TaskTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTag(
      taskId: serializer.fromJson<String>(json['taskId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  TaskTag copyWith({String? taskId, String? tagId}) => TaskTag(
        taskId: taskId ?? this.taskId,
        tagId: tagId ?? this.tagId,
      );
  TaskTag copyWithCompanion(TaskTagsCompanion data) {
    return TaskTag(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTag(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTag &&
          other.taskId == this.taskId &&
          other.tagId == this.tagId);
}

class TaskTagsCompanion extends UpdateCompanion<TaskTag> {
  final Value<String> taskId;
  final Value<String> tagId;
  final Value<int> rowid;
  const TaskTagsCompanion({
    this.taskId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTagsCompanion.insert({
    required String taskId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        tagId = Value(tagId);
  static Insertable<TaskTag> custom({
    Expression<String>? taskId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTagsCompanion copyWith(
      {Value<String>? taskId, Value<String>? tagId, Value<int>? rowid}) {
    return TaskTagsCompanion(
      taskId: taskId ?? this.taskId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTagsTable extends ProjectTags
    with TableInfo<$ProjectTagsTable, ProjectTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [projectId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId, tagId};
  @override
  ProjectTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTag(
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $ProjectTagsTable createAlias(String alias) {
    return $ProjectTagsTable(attachedDatabase, alias);
  }
}

class ProjectTag extends DataClass implements Insertable<ProjectTag> {
  final String projectId;
  final String tagId;
  const ProjectTag({required this.projectId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  ProjectTagsCompanion toCompanion(bool nullToAbsent) {
    return ProjectTagsCompanion(
      projectId: Value(projectId),
      tagId: Value(tagId),
    );
  }

  factory ProjectTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTag(
      projectId: serializer.fromJson<String>(json['projectId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  ProjectTag copyWith({String? projectId, String? tagId}) => ProjectTag(
        projectId: projectId ?? this.projectId,
        tagId: tagId ?? this.tagId,
      );
  ProjectTag copyWithCompanion(ProjectTagsCompanion data) {
    return ProjectTag(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTag(')
          ..write('projectId: $projectId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTag &&
          other.projectId == this.projectId &&
          other.tagId == this.tagId);
}

class ProjectTagsCompanion extends UpdateCompanion<ProjectTag> {
  final Value<String> projectId;
  final Value<String> tagId;
  final Value<int> rowid;
  const ProjectTagsCompanion({
    this.projectId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTagsCompanion.insert({
    required String projectId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : projectId = Value(projectId),
        tagId = Value(tagId);
  static Insertable<ProjectTag> custom({
    Expression<String>? projectId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTagsCompanion copyWith(
      {Value<String>? projectId, Value<String>? tagId, Value<int>? rowid}) {
    return ProjectTagsCompanion(
      projectId: projectId ?? this.projectId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTagsCompanion(')
          ..write('projectId: $projectId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectCategoriesTable extends ProjectCategories
    with TableInfo<$ProjectCategoriesTable, ProjectCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSystemDefinedMeta =
      const VerificationMeta('isSystemDefined');
  @override
  late final GeneratedColumn<bool> isSystemDefined = GeneratedColumn<bool>(
      'is_system_defined', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_system_defined" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iconName,
        color,
        parentId,
        isSystemDefined,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('is_system_defined')) {
      context.handle(
          _isSystemDefinedMeta,
          isSystemDefined.isAcceptableOrUnknown(
              data['is_system_defined']!, _isSystemDefinedMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      isSystemDefined: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_system_defined'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
    );
  }

  @override
  $ProjectCategoriesTable createAlias(String alias) {
    return $ProjectCategoriesTable(attachedDatabase, alias);
  }
}

class ProjectCategory extends DataClass implements Insertable<ProjectCategory> {
  final String id;
  final String name;
  final String iconName;
  final String color;
  final String? parentId;
  final bool isSystemDefined;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String metadata;
  const ProjectCategory(
      {required this.id,
      required this.name,
      required this.iconName,
      required this.color,
      this.parentId,
      required this.isSystemDefined,
      required this.isActive,
      required this.sortOrder,
      required this.createdAt,
      this.updatedAt,
      required this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_system_defined'] = Variable<bool>(isSystemDefined);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  ProjectCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ProjectCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      color: Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isSystemDefined: Value(isSystemDefined),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      metadata: Value(metadata),
    );
  }

  factory ProjectCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      color: serializer.fromJson<String>(json['color']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isSystemDefined: serializer.fromJson<bool>(json['isSystemDefined']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'color': serializer.toJson<String>(color),
      'parentId': serializer.toJson<String?>(parentId),
      'isSystemDefined': serializer.toJson<bool>(isSystemDefined),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  ProjectCategory copyWith(
          {String? id,
          String? name,
          String? iconName,
          String? color,
          Value<String?> parentId = const Value.absent(),
          bool? isSystemDefined,
          bool? isActive,
          int? sortOrder,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          String? metadata}) =>
      ProjectCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        color: color ?? this.color,
        parentId: parentId.present ? parentId.value : this.parentId,
        isSystemDefined: isSystemDefined ?? this.isSystemDefined,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        metadata: metadata ?? this.metadata,
      );
  ProjectCategory copyWithCompanion(ProjectCategoriesCompanion data) {
    return ProjectCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isSystemDefined: data.isSystemDefined.present
          ? data.isSystemDefined.value
          : this.isSystemDefined,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('isSystemDefined: $isSystemDefined, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, color, parentId,
      isSystemDefined, isActive, sortOrder, createdAt, updatedAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.isSystemDefined == this.isSystemDefined &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadata == this.metadata);
}

class ProjectCategoriesCompanion extends UpdateCompanion<ProjectCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<String> color;
  final Value<String?> parentId;
  final Value<bool> isSystemDefined;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> metadata;
  final Value<int> rowid;
  const ProjectCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isSystemDefined = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectCategoriesCompanion.insert({
    required String id,
    required String name,
    required String iconName,
    required String color,
    this.parentId = const Value.absent(),
    this.isSystemDefined = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconName = Value(iconName),
        color = Value(color),
        createdAt = Value(createdAt);
  static Insertable<ProjectCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<String>? color,
    Expression<String>? parentId,
    Expression<bool>? isSystemDefined,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (isSystemDefined != null) 'is_system_defined': isSystemDefined,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? iconName,
      Value<String>? color,
      Value<String?>? parentId,
      Value<bool>? isSystemDefined,
      Value<bool>? isActive,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String>? metadata,
      Value<int>? rowid}) {
    return ProjectCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isSystemDefined: isSystemDefined ?? this.isSystemDefined,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isSystemDefined.present) {
      map['is_system_defined'] = Variable<bool>(isSystemDefined.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('isSystemDefined: $isSystemDefined, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskDependenciesTable extends TaskDependencies
    with TableInfo<$TaskDependenciesTable, TaskDependency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskDependenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dependentTaskIdMeta =
      const VerificationMeta('dependentTaskId');
  @override
  late final GeneratedColumn<String> dependentTaskId = GeneratedColumn<String>(
      'dependent_task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prerequisiteTaskIdMeta =
      const VerificationMeta('prerequisiteTaskId');
  @override
  late final GeneratedColumn<String> prerequisiteTaskId =
      GeneratedColumn<String>('prerequisite_task_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [dependentTaskId, prerequisiteTaskId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_dependencies';
  @override
  VerificationContext validateIntegrity(Insertable<TaskDependency> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dependent_task_id')) {
      context.handle(
          _dependentTaskIdMeta,
          dependentTaskId.isAcceptableOrUnknown(
              data['dependent_task_id']!, _dependentTaskIdMeta));
    } else if (isInserting) {
      context.missing(_dependentTaskIdMeta);
    }
    if (data.containsKey('prerequisite_task_id')) {
      context.handle(
          _prerequisiteTaskIdMeta,
          prerequisiteTaskId.isAcceptableOrUnknown(
              data['prerequisite_task_id']!, _prerequisiteTaskIdMeta));
    } else if (isInserting) {
      context.missing(_prerequisiteTaskIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dependentTaskId, prerequisiteTaskId};
  @override
  TaskDependency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskDependency(
      dependentTaskId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dependent_task_id'])!,
      prerequisiteTaskId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prerequisite_task_id'])!,
    );
  }

  @override
  $TaskDependenciesTable createAlias(String alias) {
    return $TaskDependenciesTable(attachedDatabase, alias);
  }
}

class TaskDependency extends DataClass implements Insertable<TaskDependency> {
  final String dependentTaskId;
  final String prerequisiteTaskId;
  const TaskDependency(
      {required this.dependentTaskId, required this.prerequisiteTaskId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dependent_task_id'] = Variable<String>(dependentTaskId);
    map['prerequisite_task_id'] = Variable<String>(prerequisiteTaskId);
    return map;
  }

  TaskDependenciesCompanion toCompanion(bool nullToAbsent) {
    return TaskDependenciesCompanion(
      dependentTaskId: Value(dependentTaskId),
      prerequisiteTaskId: Value(prerequisiteTaskId),
    );
  }

  factory TaskDependency.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskDependency(
      dependentTaskId: serializer.fromJson<String>(json['dependentTaskId']),
      prerequisiteTaskId:
          serializer.fromJson<String>(json['prerequisiteTaskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dependentTaskId': serializer.toJson<String>(dependentTaskId),
      'prerequisiteTaskId': serializer.toJson<String>(prerequisiteTaskId),
    };
  }

  TaskDependency copyWith(
          {String? dependentTaskId, String? prerequisiteTaskId}) =>
      TaskDependency(
        dependentTaskId: dependentTaskId ?? this.dependentTaskId,
        prerequisiteTaskId: prerequisiteTaskId ?? this.prerequisiteTaskId,
      );
  TaskDependency copyWithCompanion(TaskDependenciesCompanion data) {
    return TaskDependency(
      dependentTaskId: data.dependentTaskId.present
          ? data.dependentTaskId.value
          : this.dependentTaskId,
      prerequisiteTaskId: data.prerequisiteTaskId.present
          ? data.prerequisiteTaskId.value
          : this.prerequisiteTaskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskDependency(')
          ..write('dependentTaskId: $dependentTaskId, ')
          ..write('prerequisiteTaskId: $prerequisiteTaskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dependentTaskId, prerequisiteTaskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskDependency &&
          other.dependentTaskId == this.dependentTaskId &&
          other.prerequisiteTaskId == this.prerequisiteTaskId);
}

class TaskDependenciesCompanion extends UpdateCompanion<TaskDependency> {
  final Value<String> dependentTaskId;
  final Value<String> prerequisiteTaskId;
  final Value<int> rowid;
  const TaskDependenciesCompanion({
    this.dependentTaskId = const Value.absent(),
    this.prerequisiteTaskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskDependenciesCompanion.insert({
    required String dependentTaskId,
    required String prerequisiteTaskId,
    this.rowid = const Value.absent(),
  })  : dependentTaskId = Value(dependentTaskId),
        prerequisiteTaskId = Value(prerequisiteTaskId);
  static Insertable<TaskDependency> custom({
    Expression<String>? dependentTaskId,
    Expression<String>? prerequisiteTaskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dependentTaskId != null) 'dependent_task_id': dependentTaskId,
      if (prerequisiteTaskId != null)
        'prerequisite_task_id': prerequisiteTaskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskDependenciesCompanion copyWith(
      {Value<String>? dependentTaskId,
      Value<String>? prerequisiteTaskId,
      Value<int>? rowid}) {
    return TaskDependenciesCompanion(
      dependentTaskId: dependentTaskId ?? this.dependentTaskId,
      prerequisiteTaskId: prerequisiteTaskId ?? this.prerequisiteTaskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dependentTaskId.present) {
      map['dependent_task_id'] = Variable<String>(dependentTaskId.value);
    }
    if (prerequisiteTaskId.present) {
      map['prerequisite_task_id'] = Variable<String>(prerequisiteTaskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskDependenciesCompanion(')
          ..write('dependentTaskId: $dependentTaskId, ')
          ..write('prerequisiteTaskId: $prerequisiteTaskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTemplatesTable extends TaskTemplates
    with TableInfo<$TaskTemplatesTable, TaskTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleTemplateMeta =
      const VerificationMeta('titleTemplate');
  @override
  late final GeneratedColumn<String> titleTemplate = GeneratedColumn<String>(
      'title_template', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionTemplateMeta =
      const VerificationMeta('descriptionTemplate');
  @override
  late final GeneratedColumn<String> descriptionTemplate =
      GeneratedColumn<String>('description_template', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subTaskTemplatesMeta =
      const VerificationMeta('subTaskTemplates');
  @override
  late final GeneratedColumn<String> subTaskTemplates = GeneratedColumn<String>(
      'sub_task_templates', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationTriggerMeta =
      const VerificationMeta('locationTrigger');
  @override
  late final GeneratedColumn<String> locationTrigger = GeneratedColumn<String>(
      'location_trigger', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedDurationMeta =
      const VerificationMeta('estimatedDuration');
  @override
  late final GeneratedColumn<int> estimatedDuration = GeneratedColumn<int>(
      'estimated_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceTypeMeta =
      const VerificationMeta('recurrenceType');
  @override
  late final GeneratedColumn<int> recurrenceType = GeneratedColumn<int>(
      'recurrence_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
      'recurrence_interval', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceDaysOfWeekMeta =
      const VerificationMeta('recurrenceDaysOfWeek');
  @override
  late final GeneratedColumn<String> recurrenceDaysOfWeek =
      GeneratedColumn<String>('recurrence_days_of_week', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceEndDateMeta =
      const VerificationMeta('recurrenceEndDate');
  @override
  late final GeneratedColumn<DateTime> recurrenceEndDate =
      GeneratedColumn<DateTime>('recurrence_end_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceMaxOccurrencesMeta =
      const VerificationMeta('recurrenceMaxOccurrences');
  @override
  late final GeneratedColumn<int> recurrenceMaxOccurrences =
      GeneratedColumn<int>('recurrence_max_occurrences', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        titleTemplate,
        descriptionTemplate,
        priority,
        tags,
        subTaskTemplates,
        locationTrigger,
        projectId,
        estimatedDuration,
        metadata,
        createdAt,
        updatedAt,
        usageCount,
        isFavorite,
        category,
        recurrenceType,
        recurrenceInterval,
        recurrenceDaysOfWeek,
        recurrenceEndDate,
        recurrenceMaxOccurrences
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_templates';
  @override
  VerificationContext validateIntegrity(Insertable<TaskTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('title_template')) {
      context.handle(
          _titleTemplateMeta,
          titleTemplate.isAcceptableOrUnknown(
              data['title_template']!, _titleTemplateMeta));
    } else if (isInserting) {
      context.missing(_titleTemplateMeta);
    }
    if (data.containsKey('description_template')) {
      context.handle(
          _descriptionTemplateMeta,
          descriptionTemplate.isAcceptableOrUnknown(
              data['description_template']!, _descriptionTemplateMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('sub_task_templates')) {
      context.handle(
          _subTaskTemplatesMeta,
          subTaskTemplates.isAcceptableOrUnknown(
              data['sub_task_templates']!, _subTaskTemplatesMeta));
    } else if (isInserting) {
      context.missing(_subTaskTemplatesMeta);
    }
    if (data.containsKey('location_trigger')) {
      context.handle(
          _locationTriggerMeta,
          locationTrigger.isAcceptableOrUnknown(
              data['location_trigger']!, _locationTriggerMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('estimated_duration')) {
      context.handle(
          _estimatedDurationMeta,
          estimatedDuration.isAcceptableOrUnknown(
              data['estimated_duration']!, _estimatedDurationMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    } else if (isInserting) {
      context.missing(_metadataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
          _recurrenceTypeMeta,
          recurrenceType.isAcceptableOrUnknown(
              data['recurrence_type']!, _recurrenceTypeMeta));
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
          _recurrenceIntervalMeta,
          recurrenceInterval.isAcceptableOrUnknown(
              data['recurrence_interval']!, _recurrenceIntervalMeta));
    }
    if (data.containsKey('recurrence_days_of_week')) {
      context.handle(
          _recurrenceDaysOfWeekMeta,
          recurrenceDaysOfWeek.isAcceptableOrUnknown(
              data['recurrence_days_of_week']!, _recurrenceDaysOfWeekMeta));
    }
    if (data.containsKey('recurrence_end_date')) {
      context.handle(
          _recurrenceEndDateMeta,
          recurrenceEndDate.isAcceptableOrUnknown(
              data['recurrence_end_date']!, _recurrenceEndDateMeta));
    }
    if (data.containsKey('recurrence_max_occurrences')) {
      context.handle(
          _recurrenceMaxOccurrencesMeta,
          recurrenceMaxOccurrences.isAcceptableOrUnknown(
              data['recurrence_max_occurrences']!,
              _recurrenceMaxOccurrencesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      titleTemplate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_template'])!,
      descriptionTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}description_template']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      subTaskTemplates: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sub_task_templates'])!,
      locationTrigger: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}location_trigger']),
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id']),
      estimatedDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_duration']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      recurrenceType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recurrence_type']),
      recurrenceInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}recurrence_interval']),
      recurrenceDaysOfWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_days_of_week']),
      recurrenceEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}recurrence_end_date']),
      recurrenceMaxOccurrences: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recurrence_max_occurrences']),
    );
  }

  @override
  $TaskTemplatesTable createAlias(String alias) {
    return $TaskTemplatesTable(attachedDatabase, alias);
  }
}

class TaskTemplate extends DataClass implements Insertable<TaskTemplate> {
  final String id;
  final String name;
  final String? description;
  final String titleTemplate;
  final String? descriptionTemplate;
  final int priority;
  final String tags;
  final String subTaskTemplates;
  final String? locationTrigger;
  final String? projectId;
  final int? estimatedDuration;
  final String metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int usageCount;
  final bool isFavorite;
  final String? category;
  final int? recurrenceType;
  final int? recurrenceInterval;
  final String? recurrenceDaysOfWeek;
  final DateTime? recurrenceEndDate;
  final int? recurrenceMaxOccurrences;
  const TaskTemplate(
      {required this.id,
      required this.name,
      this.description,
      required this.titleTemplate,
      this.descriptionTemplate,
      required this.priority,
      required this.tags,
      required this.subTaskTemplates,
      this.locationTrigger,
      this.projectId,
      this.estimatedDuration,
      required this.metadata,
      required this.createdAt,
      this.updatedAt,
      required this.usageCount,
      required this.isFavorite,
      this.category,
      this.recurrenceType,
      this.recurrenceInterval,
      this.recurrenceDaysOfWeek,
      this.recurrenceEndDate,
      this.recurrenceMaxOccurrences});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['title_template'] = Variable<String>(titleTemplate);
    if (!nullToAbsent || descriptionTemplate != null) {
      map['description_template'] = Variable<String>(descriptionTemplate);
    }
    map['priority'] = Variable<int>(priority);
    map['tags'] = Variable<String>(tags);
    map['sub_task_templates'] = Variable<String>(subTaskTemplates);
    if (!nullToAbsent || locationTrigger != null) {
      map['location_trigger'] = Variable<String>(locationTrigger);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    if (!nullToAbsent || estimatedDuration != null) {
      map['estimated_duration'] = Variable<int>(estimatedDuration);
    }
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['usage_count'] = Variable<int>(usageCount);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || recurrenceType != null) {
      map['recurrence_type'] = Variable<int>(recurrenceType);
    }
    if (!nullToAbsent || recurrenceInterval != null) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    }
    if (!nullToAbsent || recurrenceDaysOfWeek != null) {
      map['recurrence_days_of_week'] = Variable<String>(recurrenceDaysOfWeek);
    }
    if (!nullToAbsent || recurrenceEndDate != null) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate);
    }
    if (!nullToAbsent || recurrenceMaxOccurrences != null) {
      map['recurrence_max_occurrences'] =
          Variable<int>(recurrenceMaxOccurrences);
    }
    return map;
  }

  TaskTemplatesCompanion toCompanion(bool nullToAbsent) {
    return TaskTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      titleTemplate: Value(titleTemplate),
      descriptionTemplate: descriptionTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionTemplate),
      priority: Value(priority),
      tags: Value(tags),
      subTaskTemplates: Value(subTaskTemplates),
      locationTrigger: locationTrigger == null && nullToAbsent
          ? const Value.absent()
          : Value(locationTrigger),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      estimatedDuration: estimatedDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDuration),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      usageCount: Value(usageCount),
      isFavorite: Value(isFavorite),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      recurrenceType: recurrenceType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceType),
      recurrenceInterval: recurrenceInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceInterval),
      recurrenceDaysOfWeek: recurrenceDaysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceDaysOfWeek),
      recurrenceEndDate: recurrenceEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndDate),
      recurrenceMaxOccurrences: recurrenceMaxOccurrences == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceMaxOccurrences),
    );
  }

  factory TaskTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      titleTemplate: serializer.fromJson<String>(json['titleTemplate']),
      descriptionTemplate:
          serializer.fromJson<String?>(json['descriptionTemplate']),
      priority: serializer.fromJson<int>(json['priority']),
      tags: serializer.fromJson<String>(json['tags']),
      subTaskTemplates: serializer.fromJson<String>(json['subTaskTemplates']),
      locationTrigger: serializer.fromJson<String?>(json['locationTrigger']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      estimatedDuration: serializer.fromJson<int?>(json['estimatedDuration']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      category: serializer.fromJson<String?>(json['category']),
      recurrenceType: serializer.fromJson<int?>(json['recurrenceType']),
      recurrenceInterval: serializer.fromJson<int?>(json['recurrenceInterval']),
      recurrenceDaysOfWeek:
          serializer.fromJson<String?>(json['recurrenceDaysOfWeek']),
      recurrenceEndDate:
          serializer.fromJson<DateTime?>(json['recurrenceEndDate']),
      recurrenceMaxOccurrences:
          serializer.fromJson<int?>(json['recurrenceMaxOccurrences']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'titleTemplate': serializer.toJson<String>(titleTemplate),
      'descriptionTemplate': serializer.toJson<String?>(descriptionTemplate),
      'priority': serializer.toJson<int>(priority),
      'tags': serializer.toJson<String>(tags),
      'subTaskTemplates': serializer.toJson<String>(subTaskTemplates),
      'locationTrigger': serializer.toJson<String?>(locationTrigger),
      'projectId': serializer.toJson<String?>(projectId),
      'estimatedDuration': serializer.toJson<int?>(estimatedDuration),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'usageCount': serializer.toJson<int>(usageCount),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'category': serializer.toJson<String?>(category),
      'recurrenceType': serializer.toJson<int?>(recurrenceType),
      'recurrenceInterval': serializer.toJson<int?>(recurrenceInterval),
      'recurrenceDaysOfWeek': serializer.toJson<String?>(recurrenceDaysOfWeek),
      'recurrenceEndDate': serializer.toJson<DateTime?>(recurrenceEndDate),
      'recurrenceMaxOccurrences':
          serializer.toJson<int?>(recurrenceMaxOccurrences),
    };
  }

  TaskTemplate copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? titleTemplate,
          Value<String?> descriptionTemplate = const Value.absent(),
          int? priority,
          String? tags,
          String? subTaskTemplates,
          Value<String?> locationTrigger = const Value.absent(),
          Value<String?> projectId = const Value.absent(),
          Value<int?> estimatedDuration = const Value.absent(),
          String? metadata,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          int? usageCount,
          bool? isFavorite,
          Value<String?> category = const Value.absent(),
          Value<int?> recurrenceType = const Value.absent(),
          Value<int?> recurrenceInterval = const Value.absent(),
          Value<String?> recurrenceDaysOfWeek = const Value.absent(),
          Value<DateTime?> recurrenceEndDate = const Value.absent(),
          Value<int?> recurrenceMaxOccurrences = const Value.absent()}) =>
      TaskTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        titleTemplate: titleTemplate ?? this.titleTemplate,
        descriptionTemplate: descriptionTemplate.present
            ? descriptionTemplate.value
            : this.descriptionTemplate,
        priority: priority ?? this.priority,
        tags: tags ?? this.tags,
        subTaskTemplates: subTaskTemplates ?? this.subTaskTemplates,
        locationTrigger: locationTrigger.present
            ? locationTrigger.value
            : this.locationTrigger,
        projectId: projectId.present ? projectId.value : this.projectId,
        estimatedDuration: estimatedDuration.present
            ? estimatedDuration.value
            : this.estimatedDuration,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        usageCount: usageCount ?? this.usageCount,
        isFavorite: isFavorite ?? this.isFavorite,
        category: category.present ? category.value : this.category,
        recurrenceType:
            recurrenceType.present ? recurrenceType.value : this.recurrenceType,
        recurrenceInterval: recurrenceInterval.present
            ? recurrenceInterval.value
            : this.recurrenceInterval,
        recurrenceDaysOfWeek: recurrenceDaysOfWeek.present
            ? recurrenceDaysOfWeek.value
            : this.recurrenceDaysOfWeek,
        recurrenceEndDate: recurrenceEndDate.present
            ? recurrenceEndDate.value
            : this.recurrenceEndDate,
        recurrenceMaxOccurrences: recurrenceMaxOccurrences.present
            ? recurrenceMaxOccurrences.value
            : this.recurrenceMaxOccurrences,
      );
  TaskTemplate copyWithCompanion(TaskTemplatesCompanion data) {
    return TaskTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      titleTemplate: data.titleTemplate.present
          ? data.titleTemplate.value
          : this.titleTemplate,
      descriptionTemplate: data.descriptionTemplate.present
          ? data.descriptionTemplate.value
          : this.descriptionTemplate,
      priority: data.priority.present ? data.priority.value : this.priority,
      tags: data.tags.present ? data.tags.value : this.tags,
      subTaskTemplates: data.subTaskTemplates.present
          ? data.subTaskTemplates.value
          : this.subTaskTemplates,
      locationTrigger: data.locationTrigger.present
          ? data.locationTrigger.value
          : this.locationTrigger,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      estimatedDuration: data.estimatedDuration.present
          ? data.estimatedDuration.value
          : this.estimatedDuration,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      category: data.category.present ? data.category.value : this.category,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      recurrenceDaysOfWeek: data.recurrenceDaysOfWeek.present
          ? data.recurrenceDaysOfWeek.value
          : this.recurrenceDaysOfWeek,
      recurrenceEndDate: data.recurrenceEndDate.present
          ? data.recurrenceEndDate.value
          : this.recurrenceEndDate,
      recurrenceMaxOccurrences: data.recurrenceMaxOccurrences.present
          ? data.recurrenceMaxOccurrences.value
          : this.recurrenceMaxOccurrences,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('titleTemplate: $titleTemplate, ')
          ..write('descriptionTemplate: $descriptionTemplate, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags, ')
          ..write('subTaskTemplates: $subTaskTemplates, ')
          ..write('locationTrigger: $locationTrigger, ')
          ..write('projectId: $projectId, ')
          ..write('estimatedDuration: $estimatedDuration, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('usageCount: $usageCount, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('category: $category, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceDaysOfWeek: $recurrenceDaysOfWeek, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('recurrenceMaxOccurrences: $recurrenceMaxOccurrences')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        description,
        titleTemplate,
        descriptionTemplate,
        priority,
        tags,
        subTaskTemplates,
        locationTrigger,
        projectId,
        estimatedDuration,
        metadata,
        createdAt,
        updatedAt,
        usageCount,
        isFavorite,
        category,
        recurrenceType,
        recurrenceInterval,
        recurrenceDaysOfWeek,
        recurrenceEndDate,
        recurrenceMaxOccurrences
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.titleTemplate == this.titleTemplate &&
          other.descriptionTemplate == this.descriptionTemplate &&
          other.priority == this.priority &&
          other.tags == this.tags &&
          other.subTaskTemplates == this.subTaskTemplates &&
          other.locationTrigger == this.locationTrigger &&
          other.projectId == this.projectId &&
          other.estimatedDuration == this.estimatedDuration &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.usageCount == this.usageCount &&
          other.isFavorite == this.isFavorite &&
          other.category == this.category &&
          other.recurrenceType == this.recurrenceType &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.recurrenceDaysOfWeek == this.recurrenceDaysOfWeek &&
          other.recurrenceEndDate == this.recurrenceEndDate &&
          other.recurrenceMaxOccurrences == this.recurrenceMaxOccurrences);
}

class TaskTemplatesCompanion extends UpdateCompanion<TaskTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> titleTemplate;
  final Value<String?> descriptionTemplate;
  final Value<int> priority;
  final Value<String> tags;
  final Value<String> subTaskTemplates;
  final Value<String?> locationTrigger;
  final Value<String?> projectId;
  final Value<int?> estimatedDuration;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> usageCount;
  final Value<bool> isFavorite;
  final Value<String?> category;
  final Value<int?> recurrenceType;
  final Value<int?> recurrenceInterval;
  final Value<String?> recurrenceDaysOfWeek;
  final Value<DateTime?> recurrenceEndDate;
  final Value<int?> recurrenceMaxOccurrences;
  final Value<int> rowid;
  const TaskTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.titleTemplate = const Value.absent(),
    this.descriptionTemplate = const Value.absent(),
    this.priority = const Value.absent(),
    this.tags = const Value.absent(),
    this.subTaskTemplates = const Value.absent(),
    this.locationTrigger = const Value.absent(),
    this.projectId = const Value.absent(),
    this.estimatedDuration = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.category = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceDaysOfWeek = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.recurrenceMaxOccurrences = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTemplatesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String titleTemplate,
    this.descriptionTemplate = const Value.absent(),
    required int priority,
    required String tags,
    required String subTaskTemplates,
    this.locationTrigger = const Value.absent(),
    this.projectId = const Value.absent(),
    this.estimatedDuration = const Value.absent(),
    required String metadata,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.category = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceDaysOfWeek = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.recurrenceMaxOccurrences = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        titleTemplate = Value(titleTemplate),
        priority = Value(priority),
        tags = Value(tags),
        subTaskTemplates = Value(subTaskTemplates),
        metadata = Value(metadata),
        createdAt = Value(createdAt);
  static Insertable<TaskTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? titleTemplate,
    Expression<String>? descriptionTemplate,
    Expression<int>? priority,
    Expression<String>? tags,
    Expression<String>? subTaskTemplates,
    Expression<String>? locationTrigger,
    Expression<String>? projectId,
    Expression<int>? estimatedDuration,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? usageCount,
    Expression<bool>? isFavorite,
    Expression<String>? category,
    Expression<int>? recurrenceType,
    Expression<int>? recurrenceInterval,
    Expression<String>? recurrenceDaysOfWeek,
    Expression<DateTime>? recurrenceEndDate,
    Expression<int>? recurrenceMaxOccurrences,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (titleTemplate != null) 'title_template': titleTemplate,
      if (descriptionTemplate != null)
        'description_template': descriptionTemplate,
      if (priority != null) 'priority': priority,
      if (tags != null) 'tags': tags,
      if (subTaskTemplates != null) 'sub_task_templates': subTaskTemplates,
      if (locationTrigger != null) 'location_trigger': locationTrigger,
      if (projectId != null) 'project_id': projectId,
      if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (usageCount != null) 'usage_count': usageCount,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (category != null) 'category': category,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceDaysOfWeek != null)
        'recurrence_days_of_week': recurrenceDaysOfWeek,
      if (recurrenceEndDate != null) 'recurrence_end_date': recurrenceEndDate,
      if (recurrenceMaxOccurrences != null)
        'recurrence_max_occurrences': recurrenceMaxOccurrences,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? titleTemplate,
      Value<String?>? descriptionTemplate,
      Value<int>? priority,
      Value<String>? tags,
      Value<String>? subTaskTemplates,
      Value<String?>? locationTrigger,
      Value<String?>? projectId,
      Value<int?>? estimatedDuration,
      Value<String>? metadata,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? usageCount,
      Value<bool>? isFavorite,
      Value<String?>? category,
      Value<int?>? recurrenceType,
      Value<int?>? recurrenceInterval,
      Value<String?>? recurrenceDaysOfWeek,
      Value<DateTime?>? recurrenceEndDate,
      Value<int?>? recurrenceMaxOccurrences,
      Value<int>? rowid}) {
    return TaskTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      descriptionTemplate: descriptionTemplate ?? this.descriptionTemplate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      subTaskTemplates: subTaskTemplates ?? this.subTaskTemplates,
      locationTrigger: locationTrigger ?? this.locationTrigger,
      projectId: projectId ?? this.projectId,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceDaysOfWeek: recurrenceDaysOfWeek ?? this.recurrenceDaysOfWeek,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceMaxOccurrences:
          recurrenceMaxOccurrences ?? this.recurrenceMaxOccurrences,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (titleTemplate.present) {
      map['title_template'] = Variable<String>(titleTemplate.value);
    }
    if (descriptionTemplate.present) {
      map['description_template'] = Variable<String>(descriptionTemplate.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (subTaskTemplates.present) {
      map['sub_task_templates'] = Variable<String>(subTaskTemplates.value);
    }
    if (locationTrigger.present) {
      map['location_trigger'] = Variable<String>(locationTrigger.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (estimatedDuration.present) {
      map['estimated_duration'] = Variable<int>(estimatedDuration.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<int>(recurrenceType.value);
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (recurrenceDaysOfWeek.present) {
      map['recurrence_days_of_week'] =
          Variable<String>(recurrenceDaysOfWeek.value);
    }
    if (recurrenceEndDate.present) {
      map['recurrence_end_date'] = Variable<DateTime>(recurrenceEndDate.value);
    }
    if (recurrenceMaxOccurrences.present) {
      map['recurrence_max_occurrences'] =
          Variable<int>(recurrenceMaxOccurrences.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('titleTemplate: $titleTemplate, ')
          ..write('descriptionTemplate: $descriptionTemplate, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags, ')
          ..write('subTaskTemplates: $subTaskTemplates, ')
          ..write('locationTrigger: $locationTrigger, ')
          ..write('projectId: $projectId, ')
          ..write('estimatedDuration: $estimatedDuration, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('usageCount: $usageCount, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('category: $category, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceDaysOfWeek: $recurrenceDaysOfWeek, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('recurrenceMaxOccurrences: $recurrenceMaxOccurrences, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTemplatesTable extends ProjectTemplates
    with TableInfo<$ProjectTemplatesTable, ProjectTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shortDescriptionMeta =
      const VerificationMeta('shortDescription');
  @override
  late final GeneratedColumn<String> shortDescription = GeneratedColumn<String>(
      'short_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _industryTagsMeta =
      const VerificationMeta('industryTags');
  @override
  late final GeneratedColumn<String> industryTags = GeneratedColumn<String>(
      'industry_tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyLevelMeta =
      const VerificationMeta('difficultyLevel');
  @override
  late final GeneratedColumn<int> difficultyLevel = GeneratedColumn<int>(
      'difficulty_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _estimatedHoursMeta =
      const VerificationMeta('estimatedHours');
  @override
  late final GeneratedColumn<int> estimatedHours = GeneratedColumn<int>(
      'estimated_hours', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _projectNameTemplateMeta =
      const VerificationMeta('projectNameTemplate');
  @override
  late final GeneratedColumn<String> projectNameTemplate =
      GeneratedColumn<String>('project_name_template', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectDescriptionTemplateMeta =
      const VerificationMeta('projectDescriptionTemplate');
  @override
  late final GeneratedColumn<String> projectDescriptionTemplate =
      GeneratedColumn<String>('project_description_template', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultColorMeta =
      const VerificationMeta('defaultColor');
  @override
  late final GeneratedColumn<String> defaultColor = GeneratedColumn<String>(
      'default_color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#2196F3'));
  static const VerificationMeta _projectCategoryIdMeta =
      const VerificationMeta('projectCategoryId');
  @override
  late final GeneratedColumn<String> projectCategoryId =
      GeneratedColumn<String>('project_category_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineOffsetDaysMeta =
      const VerificationMeta('deadlineOffsetDays');
  @override
  late final GeneratedColumn<int> deadlineOffsetDays = GeneratedColumn<int>(
      'deadline_offset_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _taskTemplatesMeta =
      const VerificationMeta('taskTemplates');
  @override
  late final GeneratedColumn<String> taskTemplates = GeneratedColumn<String>(
      'task_templates', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variablesMeta =
      const VerificationMeta('variables');
  @override
  late final GeneratedColumn<String> variables = GeneratedColumn<String>(
      'variables', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wizardStepsMeta =
      const VerificationMeta('wizardSteps');
  @override
  late final GeneratedColumn<String> wizardSteps = GeneratedColumn<String>(
      'wizard_steps', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskDependenciesMeta =
      const VerificationMeta('taskDependencies');
  @override
  late final GeneratedColumn<String> taskDependencies = GeneratedColumn<String>(
      'task_dependencies', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _milestonesMeta =
      const VerificationMeta('milestones');
  @override
  late final GeneratedColumn<String> milestones = GeneratedColumn<String>(
      'milestones', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resourceTemplatesMeta =
      const VerificationMeta('resourceTemplates');
  @override
  late final GeneratedColumn<String> resourceTemplates =
      GeneratedColumn<String>('resource_templates', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSystemTemplateMeta =
      const VerificationMeta('isSystemTemplate');
  @override
  late final GeneratedColumn<bool> isSystemTemplate = GeneratedColumn<bool>(
      'is_system_template', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_system_template" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPublishedMeta =
      const VerificationMeta('isPublished');
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
      'is_published', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_published" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('1.0.0'));
  static const VerificationMeta _usageStatsMeta =
      const VerificationMeta('usageStats');
  @override
  late final GeneratedColumn<String> usageStats = GeneratedColumn<String>(
      'usage_stats', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
      'rating', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _previewImagesMeta =
      const VerificationMeta('previewImages');
  @override
  late final GeneratedColumn<String> previewImages = GeneratedColumn<String>(
      'preview_images', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supportedLocalesMeta =
      const VerificationMeta('supportedLocales');
  @override
  late final GeneratedColumn<String> supportedLocales = GeneratedColumn<String>(
      'supported_locales', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPremiumMeta =
      const VerificationMeta('isPremium');
  @override
  late final GeneratedColumn<bool> isPremium = GeneratedColumn<bool>(
      'is_premium', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_premium" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sizeEstimateMeta =
      const VerificationMeta('sizeEstimate');
  @override
  late final GeneratedColumn<String> sizeEstimate = GeneratedColumn<String>(
      'size_estimate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        shortDescription,
        type,
        categoryId,
        industryTags,
        difficultyLevel,
        estimatedHours,
        projectNameTemplate,
        projectDescriptionTemplate,
        defaultColor,
        projectCategoryId,
        deadlineOffsetDays,
        taskTemplates,
        variables,
        wizardSteps,
        taskDependencies,
        milestones,
        resourceTemplates,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        isSystemTemplate,
        isPublished,
        version,
        usageStats,
        rating,
        previewImages,
        tags,
        supportedLocales,
        isPremium,
        sizeEstimate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_templates';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('short_description')) {
      context.handle(
          _shortDescriptionMeta,
          shortDescription.isAcceptableOrUnknown(
              data['short_description']!, _shortDescriptionMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('industry_tags')) {
      context.handle(
          _industryTagsMeta,
          industryTags.isAcceptableOrUnknown(
              data['industry_tags']!, _industryTagsMeta));
    } else if (isInserting) {
      context.missing(_industryTagsMeta);
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
          _difficultyLevelMeta,
          difficultyLevel.isAcceptableOrUnknown(
              data['difficulty_level']!, _difficultyLevelMeta));
    }
    if (data.containsKey('estimated_hours')) {
      context.handle(
          _estimatedHoursMeta,
          estimatedHours.isAcceptableOrUnknown(
              data['estimated_hours']!, _estimatedHoursMeta));
    }
    if (data.containsKey('project_name_template')) {
      context.handle(
          _projectNameTemplateMeta,
          projectNameTemplate.isAcceptableOrUnknown(
              data['project_name_template']!, _projectNameTemplateMeta));
    } else if (isInserting) {
      context.missing(_projectNameTemplateMeta);
    }
    if (data.containsKey('project_description_template')) {
      context.handle(
          _projectDescriptionTemplateMeta,
          projectDescriptionTemplate.isAcceptableOrUnknown(
              data['project_description_template']!,
              _projectDescriptionTemplateMeta));
    }
    if (data.containsKey('default_color')) {
      context.handle(
          _defaultColorMeta,
          defaultColor.isAcceptableOrUnknown(
              data['default_color']!, _defaultColorMeta));
    }
    if (data.containsKey('project_category_id')) {
      context.handle(
          _projectCategoryIdMeta,
          projectCategoryId.isAcceptableOrUnknown(
              data['project_category_id']!, _projectCategoryIdMeta));
    }
    if (data.containsKey('deadline_offset_days')) {
      context.handle(
          _deadlineOffsetDaysMeta,
          deadlineOffsetDays.isAcceptableOrUnknown(
              data['deadline_offset_days']!, _deadlineOffsetDaysMeta));
    }
    if (data.containsKey('task_templates')) {
      context.handle(
          _taskTemplatesMeta,
          taskTemplates.isAcceptableOrUnknown(
              data['task_templates']!, _taskTemplatesMeta));
    } else if (isInserting) {
      context.missing(_taskTemplatesMeta);
    }
    if (data.containsKey('variables')) {
      context.handle(_variablesMeta,
          variables.isAcceptableOrUnknown(data['variables']!, _variablesMeta));
    } else if (isInserting) {
      context.missing(_variablesMeta);
    }
    if (data.containsKey('wizard_steps')) {
      context.handle(
          _wizardStepsMeta,
          wizardSteps.isAcceptableOrUnknown(
              data['wizard_steps']!, _wizardStepsMeta));
    } else if (isInserting) {
      context.missing(_wizardStepsMeta);
    }
    if (data.containsKey('task_dependencies')) {
      context.handle(
          _taskDependenciesMeta,
          taskDependencies.isAcceptableOrUnknown(
              data['task_dependencies']!, _taskDependenciesMeta));
    } else if (isInserting) {
      context.missing(_taskDependenciesMeta);
    }
    if (data.containsKey('milestones')) {
      context.handle(
          _milestonesMeta,
          milestones.isAcceptableOrUnknown(
              data['milestones']!, _milestonesMeta));
    } else if (isInserting) {
      context.missing(_milestonesMeta);
    }
    if (data.containsKey('resource_templates')) {
      context.handle(
          _resourceTemplatesMeta,
          resourceTemplates.isAcceptableOrUnknown(
              data['resource_templates']!, _resourceTemplatesMeta));
    } else if (isInserting) {
      context.missing(_resourceTemplatesMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    } else if (isInserting) {
      context.missing(_metadataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('is_system_template')) {
      context.handle(
          _isSystemTemplateMeta,
          isSystemTemplate.isAcceptableOrUnknown(
              data['is_system_template']!, _isSystemTemplateMeta));
    }
    if (data.containsKey('is_published')) {
      context.handle(
          _isPublishedMeta,
          isPublished.isAcceptableOrUnknown(
              data['is_published']!, _isPublishedMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('usage_stats')) {
      context.handle(
          _usageStatsMeta,
          usageStats.isAcceptableOrUnknown(
              data['usage_stats']!, _usageStatsMeta));
    } else if (isInserting) {
      context.missing(_usageStatsMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('preview_images')) {
      context.handle(
          _previewImagesMeta,
          previewImages.isAcceptableOrUnknown(
              data['preview_images']!, _previewImagesMeta));
    } else if (isInserting) {
      context.missing(_previewImagesMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('supported_locales')) {
      context.handle(
          _supportedLocalesMeta,
          supportedLocales.isAcceptableOrUnknown(
              data['supported_locales']!, _supportedLocalesMeta));
    } else if (isInserting) {
      context.missing(_supportedLocalesMeta);
    }
    if (data.containsKey('is_premium')) {
      context.handle(_isPremiumMeta,
          isPremium.isAcceptableOrUnknown(data['is_premium']!, _isPremiumMeta));
    }
    if (data.containsKey('size_estimate')) {
      context.handle(
          _sizeEstimateMeta,
          sizeEstimate.isAcceptableOrUnknown(
              data['size_estimate']!, _sizeEstimateMeta));
    } else if (isInserting) {
      context.missing(_sizeEstimateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      shortDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}short_description']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      industryTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}industry_tags'])!,
      difficultyLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty_level'])!,
      estimatedHours: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_hours']),
      projectNameTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}project_name_template'])!,
      projectDescriptionTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}project_description_template']),
      defaultColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_color'])!,
      projectCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}project_category_id']),
      deadlineOffsetDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}deadline_offset_days']),
      taskTemplates: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_templates'])!,
      variables: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variables'])!,
      wizardSteps: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wizard_steps'])!,
      taskDependencies: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}task_dependencies'])!,
      milestones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}milestones'])!,
      resourceTemplates: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resource_templates'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      isSystemTemplate: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_system_template'])!,
      isPublished: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_published'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
      usageStats: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usage_stats'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rating']),
      previewImages: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preview_images'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      supportedLocales: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}supported_locales'])!,
      isPremium: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_premium'])!,
      sizeEstimate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}size_estimate'])!,
    );
  }

  @override
  $ProjectTemplatesTable createAlias(String alias) {
    return $ProjectTemplatesTable(attachedDatabase, alias);
  }
}

class ProjectTemplate extends DataClass implements Insertable<ProjectTemplate> {
  final String id;
  final String name;
  final String? description;
  final String? shortDescription;
  final int type;
  final String? categoryId;
  final String industryTags;
  final int difficultyLevel;
  final int? estimatedHours;
  final String projectNameTemplate;
  final String? projectDescriptionTemplate;
  final String defaultColor;
  final String? projectCategoryId;
  final int? deadlineOffsetDays;
  final String taskTemplates;
  final String variables;
  final String wizardSteps;
  final String taskDependencies;
  final String milestones;
  final String resourceTemplates;
  final String metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final bool isSystemTemplate;
  final bool isPublished;
  final String version;
  final String usageStats;
  final String? rating;
  final String previewImages;
  final String tags;
  final String supportedLocales;
  final bool isPremium;
  final String sizeEstimate;
  const ProjectTemplate(
      {required this.id,
      required this.name,
      this.description,
      this.shortDescription,
      required this.type,
      this.categoryId,
      required this.industryTags,
      required this.difficultyLevel,
      this.estimatedHours,
      required this.projectNameTemplate,
      this.projectDescriptionTemplate,
      required this.defaultColor,
      this.projectCategoryId,
      this.deadlineOffsetDays,
      required this.taskTemplates,
      required this.variables,
      required this.wizardSteps,
      required this.taskDependencies,
      required this.milestones,
      required this.resourceTemplates,
      required this.metadata,
      required this.createdAt,
      this.updatedAt,
      this.createdBy,
      required this.isSystemTemplate,
      required this.isPublished,
      required this.version,
      required this.usageStats,
      this.rating,
      required this.previewImages,
      required this.tags,
      required this.supportedLocales,
      required this.isPremium,
      required this.sizeEstimate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || shortDescription != null) {
      map['short_description'] = Variable<String>(shortDescription);
    }
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['industry_tags'] = Variable<String>(industryTags);
    map['difficulty_level'] = Variable<int>(difficultyLevel);
    if (!nullToAbsent || estimatedHours != null) {
      map['estimated_hours'] = Variable<int>(estimatedHours);
    }
    map['project_name_template'] = Variable<String>(projectNameTemplate);
    if (!nullToAbsent || projectDescriptionTemplate != null) {
      map['project_description_template'] =
          Variable<String>(projectDescriptionTemplate);
    }
    map['default_color'] = Variable<String>(defaultColor);
    if (!nullToAbsent || projectCategoryId != null) {
      map['project_category_id'] = Variable<String>(projectCategoryId);
    }
    if (!nullToAbsent || deadlineOffsetDays != null) {
      map['deadline_offset_days'] = Variable<int>(deadlineOffsetDays);
    }
    map['task_templates'] = Variable<String>(taskTemplates);
    map['variables'] = Variable<String>(variables);
    map['wizard_steps'] = Variable<String>(wizardSteps);
    map['task_dependencies'] = Variable<String>(taskDependencies);
    map['milestones'] = Variable<String>(milestones);
    map['resource_templates'] = Variable<String>(resourceTemplates);
    map['metadata'] = Variable<String>(metadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['is_system_template'] = Variable<bool>(isSystemTemplate);
    map['is_published'] = Variable<bool>(isPublished);
    map['version'] = Variable<String>(version);
    map['usage_stats'] = Variable<String>(usageStats);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<String>(rating);
    }
    map['preview_images'] = Variable<String>(previewImages);
    map['tags'] = Variable<String>(tags);
    map['supported_locales'] = Variable<String>(supportedLocales);
    map['is_premium'] = Variable<bool>(isPremium);
    map['size_estimate'] = Variable<String>(sizeEstimate);
    return map;
  }

  ProjectTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ProjectTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      shortDescription: shortDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(shortDescription),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      industryTags: Value(industryTags),
      difficultyLevel: Value(difficultyLevel),
      estimatedHours: estimatedHours == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedHours),
      projectNameTemplate: Value(projectNameTemplate),
      projectDescriptionTemplate:
          projectDescriptionTemplate == null && nullToAbsent
              ? const Value.absent()
              : Value(projectDescriptionTemplate),
      defaultColor: Value(defaultColor),
      projectCategoryId: projectCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectCategoryId),
      deadlineOffsetDays: deadlineOffsetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineOffsetDays),
      taskTemplates: Value(taskTemplates),
      variables: Value(variables),
      wizardSteps: Value(wizardSteps),
      taskDependencies: Value(taskDependencies),
      milestones: Value(milestones),
      resourceTemplates: Value(resourceTemplates),
      metadata: Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      isSystemTemplate: Value(isSystemTemplate),
      isPublished: Value(isPublished),
      version: Value(version),
      usageStats: Value(usageStats),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      previewImages: Value(previewImages),
      tags: Value(tags),
      supportedLocales: Value(supportedLocales),
      isPremium: Value(isPremium),
      sizeEstimate: Value(sizeEstimate),
    );
  }

  factory ProjectTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      shortDescription: serializer.fromJson<String?>(json['shortDescription']),
      type: serializer.fromJson<int>(json['type']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      industryTags: serializer.fromJson<String>(json['industryTags']),
      difficultyLevel: serializer.fromJson<int>(json['difficultyLevel']),
      estimatedHours: serializer.fromJson<int?>(json['estimatedHours']),
      projectNameTemplate:
          serializer.fromJson<String>(json['projectNameTemplate']),
      projectDescriptionTemplate:
          serializer.fromJson<String?>(json['projectDescriptionTemplate']),
      defaultColor: serializer.fromJson<String>(json['defaultColor']),
      projectCategoryId:
          serializer.fromJson<String?>(json['projectCategoryId']),
      deadlineOffsetDays: serializer.fromJson<int?>(json['deadlineOffsetDays']),
      taskTemplates: serializer.fromJson<String>(json['taskTemplates']),
      variables: serializer.fromJson<String>(json['variables']),
      wizardSteps: serializer.fromJson<String>(json['wizardSteps']),
      taskDependencies: serializer.fromJson<String>(json['taskDependencies']),
      milestones: serializer.fromJson<String>(json['milestones']),
      resourceTemplates: serializer.fromJson<String>(json['resourceTemplates']),
      metadata: serializer.fromJson<String>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      isSystemTemplate: serializer.fromJson<bool>(json['isSystemTemplate']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      version: serializer.fromJson<String>(json['version']),
      usageStats: serializer.fromJson<String>(json['usageStats']),
      rating: serializer.fromJson<String?>(json['rating']),
      previewImages: serializer.fromJson<String>(json['previewImages']),
      tags: serializer.fromJson<String>(json['tags']),
      supportedLocales: serializer.fromJson<String>(json['supportedLocales']),
      isPremium: serializer.fromJson<bool>(json['isPremium']),
      sizeEstimate: serializer.fromJson<String>(json['sizeEstimate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'shortDescription': serializer.toJson<String?>(shortDescription),
      'type': serializer.toJson<int>(type),
      'categoryId': serializer.toJson<String?>(categoryId),
      'industryTags': serializer.toJson<String>(industryTags),
      'difficultyLevel': serializer.toJson<int>(difficultyLevel),
      'estimatedHours': serializer.toJson<int?>(estimatedHours),
      'projectNameTemplate': serializer.toJson<String>(projectNameTemplate),
      'projectDescriptionTemplate':
          serializer.toJson<String?>(projectDescriptionTemplate),
      'defaultColor': serializer.toJson<String>(defaultColor),
      'projectCategoryId': serializer.toJson<String?>(projectCategoryId),
      'deadlineOffsetDays': serializer.toJson<int?>(deadlineOffsetDays),
      'taskTemplates': serializer.toJson<String>(taskTemplates),
      'variables': serializer.toJson<String>(variables),
      'wizardSteps': serializer.toJson<String>(wizardSteps),
      'taskDependencies': serializer.toJson<String>(taskDependencies),
      'milestones': serializer.toJson<String>(milestones),
      'resourceTemplates': serializer.toJson<String>(resourceTemplates),
      'metadata': serializer.toJson<String>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'isSystemTemplate': serializer.toJson<bool>(isSystemTemplate),
      'isPublished': serializer.toJson<bool>(isPublished),
      'version': serializer.toJson<String>(version),
      'usageStats': serializer.toJson<String>(usageStats),
      'rating': serializer.toJson<String?>(rating),
      'previewImages': serializer.toJson<String>(previewImages),
      'tags': serializer.toJson<String>(tags),
      'supportedLocales': serializer.toJson<String>(supportedLocales),
      'isPremium': serializer.toJson<bool>(isPremium),
      'sizeEstimate': serializer.toJson<String>(sizeEstimate),
    };
  }

  ProjectTemplate copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> shortDescription = const Value.absent(),
          int? type,
          Value<String?> categoryId = const Value.absent(),
          String? industryTags,
          int? difficultyLevel,
          Value<int?> estimatedHours = const Value.absent(),
          String? projectNameTemplate,
          Value<String?> projectDescriptionTemplate = const Value.absent(),
          String? defaultColor,
          Value<String?> projectCategoryId = const Value.absent(),
          Value<int?> deadlineOffsetDays = const Value.absent(),
          String? taskTemplates,
          String? variables,
          String? wizardSteps,
          String? taskDependencies,
          String? milestones,
          String? resourceTemplates,
          String? metadata,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          bool? isSystemTemplate,
          bool? isPublished,
          String? version,
          String? usageStats,
          Value<String?> rating = const Value.absent(),
          String? previewImages,
          String? tags,
          String? supportedLocales,
          bool? isPremium,
          String? sizeEstimate}) =>
      ProjectTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        shortDescription: shortDescription.present
            ? shortDescription.value
            : this.shortDescription,
        type: type ?? this.type,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        industryTags: industryTags ?? this.industryTags,
        difficultyLevel: difficultyLevel ?? this.difficultyLevel,
        estimatedHours:
            estimatedHours.present ? estimatedHours.value : this.estimatedHours,
        projectNameTemplate: projectNameTemplate ?? this.projectNameTemplate,
        projectDescriptionTemplate: projectDescriptionTemplate.present
            ? projectDescriptionTemplate.value
            : this.projectDescriptionTemplate,
        defaultColor: defaultColor ?? this.defaultColor,
        projectCategoryId: projectCategoryId.present
            ? projectCategoryId.value
            : this.projectCategoryId,
        deadlineOffsetDays: deadlineOffsetDays.present
            ? deadlineOffsetDays.value
            : this.deadlineOffsetDays,
        taskTemplates: taskTemplates ?? this.taskTemplates,
        variables: variables ?? this.variables,
        wizardSteps: wizardSteps ?? this.wizardSteps,
        taskDependencies: taskDependencies ?? this.taskDependencies,
        milestones: milestones ?? this.milestones,
        resourceTemplates: resourceTemplates ?? this.resourceTemplates,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        isSystemTemplate: isSystemTemplate ?? this.isSystemTemplate,
        isPublished: isPublished ?? this.isPublished,
        version: version ?? this.version,
        usageStats: usageStats ?? this.usageStats,
        rating: rating.present ? rating.value : this.rating,
        previewImages: previewImages ?? this.previewImages,
        tags: tags ?? this.tags,
        supportedLocales: supportedLocales ?? this.supportedLocales,
        isPremium: isPremium ?? this.isPremium,
        sizeEstimate: sizeEstimate ?? this.sizeEstimate,
      );
  ProjectTemplate copyWithCompanion(ProjectTemplatesCompanion data) {
    return ProjectTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      shortDescription: data.shortDescription.present
          ? data.shortDescription.value
          : this.shortDescription,
      type: data.type.present ? data.type.value : this.type,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      industryTags: data.industryTags.present
          ? data.industryTags.value
          : this.industryTags,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      estimatedHours: data.estimatedHours.present
          ? data.estimatedHours.value
          : this.estimatedHours,
      projectNameTemplate: data.projectNameTemplate.present
          ? data.projectNameTemplate.value
          : this.projectNameTemplate,
      projectDescriptionTemplate: data.projectDescriptionTemplate.present
          ? data.projectDescriptionTemplate.value
          : this.projectDescriptionTemplate,
      defaultColor: data.defaultColor.present
          ? data.defaultColor.value
          : this.defaultColor,
      projectCategoryId: data.projectCategoryId.present
          ? data.projectCategoryId.value
          : this.projectCategoryId,
      deadlineOffsetDays: data.deadlineOffsetDays.present
          ? data.deadlineOffsetDays.value
          : this.deadlineOffsetDays,
      taskTemplates: data.taskTemplates.present
          ? data.taskTemplates.value
          : this.taskTemplates,
      variables: data.variables.present ? data.variables.value : this.variables,
      wizardSteps:
          data.wizardSteps.present ? data.wizardSteps.value : this.wizardSteps,
      taskDependencies: data.taskDependencies.present
          ? data.taskDependencies.value
          : this.taskDependencies,
      milestones:
          data.milestones.present ? data.milestones.value : this.milestones,
      resourceTemplates: data.resourceTemplates.present
          ? data.resourceTemplates.value
          : this.resourceTemplates,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      isSystemTemplate: data.isSystemTemplate.present
          ? data.isSystemTemplate.value
          : this.isSystemTemplate,
      isPublished:
          data.isPublished.present ? data.isPublished.value : this.isPublished,
      version: data.version.present ? data.version.value : this.version,
      usageStats:
          data.usageStats.present ? data.usageStats.value : this.usageStats,
      rating: data.rating.present ? data.rating.value : this.rating,
      previewImages: data.previewImages.present
          ? data.previewImages.value
          : this.previewImages,
      tags: data.tags.present ? data.tags.value : this.tags,
      supportedLocales: data.supportedLocales.present
          ? data.supportedLocales.value
          : this.supportedLocales,
      isPremium: data.isPremium.present ? data.isPremium.value : this.isPremium,
      sizeEstimate: data.sizeEstimate.present
          ? data.sizeEstimate.value
          : this.sizeEstimate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('industryTags: $industryTags, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('projectNameTemplate: $projectNameTemplate, ')
          ..write('projectDescriptionTemplate: $projectDescriptionTemplate, ')
          ..write('defaultColor: $defaultColor, ')
          ..write('projectCategoryId: $projectCategoryId, ')
          ..write('deadlineOffsetDays: $deadlineOffsetDays, ')
          ..write('taskTemplates: $taskTemplates, ')
          ..write('variables: $variables, ')
          ..write('wizardSteps: $wizardSteps, ')
          ..write('taskDependencies: $taskDependencies, ')
          ..write('milestones: $milestones, ')
          ..write('resourceTemplates: $resourceTemplates, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('isSystemTemplate: $isSystemTemplate, ')
          ..write('isPublished: $isPublished, ')
          ..write('version: $version, ')
          ..write('usageStats: $usageStats, ')
          ..write('rating: $rating, ')
          ..write('previewImages: $previewImages, ')
          ..write('tags: $tags, ')
          ..write('supportedLocales: $supportedLocales, ')
          ..write('isPremium: $isPremium, ')
          ..write('sizeEstimate: $sizeEstimate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        description,
        shortDescription,
        type,
        categoryId,
        industryTags,
        difficultyLevel,
        estimatedHours,
        projectNameTemplate,
        projectDescriptionTemplate,
        defaultColor,
        projectCategoryId,
        deadlineOffsetDays,
        taskTemplates,
        variables,
        wizardSteps,
        taskDependencies,
        milestones,
        resourceTemplates,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        isSystemTemplate,
        isPublished,
        version,
        usageStats,
        rating,
        previewImages,
        tags,
        supportedLocales,
        isPremium,
        sizeEstimate
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.shortDescription == this.shortDescription &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.industryTags == this.industryTags &&
          other.difficultyLevel == this.difficultyLevel &&
          other.estimatedHours == this.estimatedHours &&
          other.projectNameTemplate == this.projectNameTemplate &&
          other.projectDescriptionTemplate == this.projectDescriptionTemplate &&
          other.defaultColor == this.defaultColor &&
          other.projectCategoryId == this.projectCategoryId &&
          other.deadlineOffsetDays == this.deadlineOffsetDays &&
          other.taskTemplates == this.taskTemplates &&
          other.variables == this.variables &&
          other.wizardSteps == this.wizardSteps &&
          other.taskDependencies == this.taskDependencies &&
          other.milestones == this.milestones &&
          other.resourceTemplates == this.resourceTemplates &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.createdBy == this.createdBy &&
          other.isSystemTemplate == this.isSystemTemplate &&
          other.isPublished == this.isPublished &&
          other.version == this.version &&
          other.usageStats == this.usageStats &&
          other.rating == this.rating &&
          other.previewImages == this.previewImages &&
          other.tags == this.tags &&
          other.supportedLocales == this.supportedLocales &&
          other.isPremium == this.isPremium &&
          other.sizeEstimate == this.sizeEstimate);
}

class ProjectTemplatesCompanion extends UpdateCompanion<ProjectTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> shortDescription;
  final Value<int> type;
  final Value<String?> categoryId;
  final Value<String> industryTags;
  final Value<int> difficultyLevel;
  final Value<int?> estimatedHours;
  final Value<String> projectNameTemplate;
  final Value<String?> projectDescriptionTemplate;
  final Value<String> defaultColor;
  final Value<String?> projectCategoryId;
  final Value<int?> deadlineOffsetDays;
  final Value<String> taskTemplates;
  final Value<String> variables;
  final Value<String> wizardSteps;
  final Value<String> taskDependencies;
  final Value<String> milestones;
  final Value<String> resourceTemplates;
  final Value<String> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> createdBy;
  final Value<bool> isSystemTemplate;
  final Value<bool> isPublished;
  final Value<String> version;
  final Value<String> usageStats;
  final Value<String?> rating;
  final Value<String> previewImages;
  final Value<String> tags;
  final Value<String> supportedLocales;
  final Value<bool> isPremium;
  final Value<String> sizeEstimate;
  final Value<int> rowid;
  const ProjectTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.industryTags = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    this.projectNameTemplate = const Value.absent(),
    this.projectDescriptionTemplate = const Value.absent(),
    this.defaultColor = const Value.absent(),
    this.projectCategoryId = const Value.absent(),
    this.deadlineOffsetDays = const Value.absent(),
    this.taskTemplates = const Value.absent(),
    this.variables = const Value.absent(),
    this.wizardSteps = const Value.absent(),
    this.taskDependencies = const Value.absent(),
    this.milestones = const Value.absent(),
    this.resourceTemplates = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.isSystemTemplate = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.version = const Value.absent(),
    this.usageStats = const Value.absent(),
    this.rating = const Value.absent(),
    this.previewImages = const Value.absent(),
    this.tags = const Value.absent(),
    this.supportedLocales = const Value.absent(),
    this.isPremium = const Value.absent(),
    this.sizeEstimate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTemplatesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.shortDescription = const Value.absent(),
    required int type,
    this.categoryId = const Value.absent(),
    required String industryTags,
    this.difficultyLevel = const Value.absent(),
    this.estimatedHours = const Value.absent(),
    required String projectNameTemplate,
    this.projectDescriptionTemplate = const Value.absent(),
    this.defaultColor = const Value.absent(),
    this.projectCategoryId = const Value.absent(),
    this.deadlineOffsetDays = const Value.absent(),
    required String taskTemplates,
    required String variables,
    required String wizardSteps,
    required String taskDependencies,
    required String milestones,
    required String resourceTemplates,
    required String metadata,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.isSystemTemplate = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.version = const Value.absent(),
    required String usageStats,
    this.rating = const Value.absent(),
    required String previewImages,
    required String tags,
    required String supportedLocales,
    this.isPremium = const Value.absent(),
    required String sizeEstimate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        industryTags = Value(industryTags),
        projectNameTemplate = Value(projectNameTemplate),
        taskTemplates = Value(taskTemplates),
        variables = Value(variables),
        wizardSteps = Value(wizardSteps),
        taskDependencies = Value(taskDependencies),
        milestones = Value(milestones),
        resourceTemplates = Value(resourceTemplates),
        metadata = Value(metadata),
        createdAt = Value(createdAt),
        usageStats = Value(usageStats),
        previewImages = Value(previewImages),
        tags = Value(tags),
        supportedLocales = Value(supportedLocales),
        sizeEstimate = Value(sizeEstimate);
  static Insertable<ProjectTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? shortDescription,
    Expression<int>? type,
    Expression<String>? categoryId,
    Expression<String>? industryTags,
    Expression<int>? difficultyLevel,
    Expression<int>? estimatedHours,
    Expression<String>? projectNameTemplate,
    Expression<String>? projectDescriptionTemplate,
    Expression<String>? defaultColor,
    Expression<String>? projectCategoryId,
    Expression<int>? deadlineOffsetDays,
    Expression<String>? taskTemplates,
    Expression<String>? variables,
    Expression<String>? wizardSteps,
    Expression<String>? taskDependencies,
    Expression<String>? milestones,
    Expression<String>? resourceTemplates,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? createdBy,
    Expression<bool>? isSystemTemplate,
    Expression<bool>? isPublished,
    Expression<String>? version,
    Expression<String>? usageStats,
    Expression<String>? rating,
    Expression<String>? previewImages,
    Expression<String>? tags,
    Expression<String>? supportedLocales,
    Expression<bool>? isPremium,
    Expression<String>? sizeEstimate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (shortDescription != null) 'short_description': shortDescription,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (industryTags != null) 'industry_tags': industryTags,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (estimatedHours != null) 'estimated_hours': estimatedHours,
      if (projectNameTemplate != null)
        'project_name_template': projectNameTemplate,
      if (projectDescriptionTemplate != null)
        'project_description_template': projectDescriptionTemplate,
      if (defaultColor != null) 'default_color': defaultColor,
      if (projectCategoryId != null) 'project_category_id': projectCategoryId,
      if (deadlineOffsetDays != null)
        'deadline_offset_days': deadlineOffsetDays,
      if (taskTemplates != null) 'task_templates': taskTemplates,
      if (variables != null) 'variables': variables,
      if (wizardSteps != null) 'wizard_steps': wizardSteps,
      if (taskDependencies != null) 'task_dependencies': taskDependencies,
      if (milestones != null) 'milestones': milestones,
      if (resourceTemplates != null) 'resource_templates': resourceTemplates,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (isSystemTemplate != null) 'is_system_template': isSystemTemplate,
      if (isPublished != null) 'is_published': isPublished,
      if (version != null) 'version': version,
      if (usageStats != null) 'usage_stats': usageStats,
      if (rating != null) 'rating': rating,
      if (previewImages != null) 'preview_images': previewImages,
      if (tags != null) 'tags': tags,
      if (supportedLocales != null) 'supported_locales': supportedLocales,
      if (isPremium != null) 'is_premium': isPremium,
      if (sizeEstimate != null) 'size_estimate': sizeEstimate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? shortDescription,
      Value<int>? type,
      Value<String?>? categoryId,
      Value<String>? industryTags,
      Value<int>? difficultyLevel,
      Value<int?>? estimatedHours,
      Value<String>? projectNameTemplate,
      Value<String?>? projectDescriptionTemplate,
      Value<String>? defaultColor,
      Value<String?>? projectCategoryId,
      Value<int?>? deadlineOffsetDays,
      Value<String>? taskTemplates,
      Value<String>? variables,
      Value<String>? wizardSteps,
      Value<String>? taskDependencies,
      Value<String>? milestones,
      Value<String>? resourceTemplates,
      Value<String>? metadata,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String?>? createdBy,
      Value<bool>? isSystemTemplate,
      Value<bool>? isPublished,
      Value<String>? version,
      Value<String>? usageStats,
      Value<String?>? rating,
      Value<String>? previewImages,
      Value<String>? tags,
      Value<String>? supportedLocales,
      Value<bool>? isPremium,
      Value<String>? sizeEstimate,
      Value<int>? rowid}) {
    return ProjectTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      industryTags: industryTags ?? this.industryTags,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      projectNameTemplate: projectNameTemplate ?? this.projectNameTemplate,
      projectDescriptionTemplate:
          projectDescriptionTemplate ?? this.projectDescriptionTemplate,
      defaultColor: defaultColor ?? this.defaultColor,
      projectCategoryId: projectCategoryId ?? this.projectCategoryId,
      deadlineOffsetDays: deadlineOffsetDays ?? this.deadlineOffsetDays,
      taskTemplates: taskTemplates ?? this.taskTemplates,
      variables: variables ?? this.variables,
      wizardSteps: wizardSteps ?? this.wizardSteps,
      taskDependencies: taskDependencies ?? this.taskDependencies,
      milestones: milestones ?? this.milestones,
      resourceTemplates: resourceTemplates ?? this.resourceTemplates,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isSystemTemplate: isSystemTemplate ?? this.isSystemTemplate,
      isPublished: isPublished ?? this.isPublished,
      version: version ?? this.version,
      usageStats: usageStats ?? this.usageStats,
      rating: rating ?? this.rating,
      previewImages: previewImages ?? this.previewImages,
      tags: tags ?? this.tags,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      isPremium: isPremium ?? this.isPremium,
      sizeEstimate: sizeEstimate ?? this.sizeEstimate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (shortDescription.present) {
      map['short_description'] = Variable<String>(shortDescription.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (industryTags.present) {
      map['industry_tags'] = Variable<String>(industryTags.value);
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<int>(difficultyLevel.value);
    }
    if (estimatedHours.present) {
      map['estimated_hours'] = Variable<int>(estimatedHours.value);
    }
    if (projectNameTemplate.present) {
      map['project_name_template'] =
          Variable<String>(projectNameTemplate.value);
    }
    if (projectDescriptionTemplate.present) {
      map['project_description_template'] =
          Variable<String>(projectDescriptionTemplate.value);
    }
    if (defaultColor.present) {
      map['default_color'] = Variable<String>(defaultColor.value);
    }
    if (projectCategoryId.present) {
      map['project_category_id'] = Variable<String>(projectCategoryId.value);
    }
    if (deadlineOffsetDays.present) {
      map['deadline_offset_days'] = Variable<int>(deadlineOffsetDays.value);
    }
    if (taskTemplates.present) {
      map['task_templates'] = Variable<String>(taskTemplates.value);
    }
    if (variables.present) {
      map['variables'] = Variable<String>(variables.value);
    }
    if (wizardSteps.present) {
      map['wizard_steps'] = Variable<String>(wizardSteps.value);
    }
    if (taskDependencies.present) {
      map['task_dependencies'] = Variable<String>(taskDependencies.value);
    }
    if (milestones.present) {
      map['milestones'] = Variable<String>(milestones.value);
    }
    if (resourceTemplates.present) {
      map['resource_templates'] = Variable<String>(resourceTemplates.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (isSystemTemplate.present) {
      map['is_system_template'] = Variable<bool>(isSystemTemplate.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (usageStats.present) {
      map['usage_stats'] = Variable<String>(usageStats.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (previewImages.present) {
      map['preview_images'] = Variable<String>(previewImages.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (supportedLocales.present) {
      map['supported_locales'] = Variable<String>(supportedLocales.value);
    }
    if (isPremium.present) {
      map['is_premium'] = Variable<bool>(isPremium.value);
    }
    if (sizeEstimate.present) {
      map['size_estimate'] = Variable<String>(sizeEstimate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('industryTags: $industryTags, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('estimatedHours: $estimatedHours, ')
          ..write('projectNameTemplate: $projectNameTemplate, ')
          ..write('projectDescriptionTemplate: $projectDescriptionTemplate, ')
          ..write('defaultColor: $defaultColor, ')
          ..write('projectCategoryId: $projectCategoryId, ')
          ..write('deadlineOffsetDays: $deadlineOffsetDays, ')
          ..write('taskTemplates: $taskTemplates, ')
          ..write('variables: $variables, ')
          ..write('wizardSteps: $wizardSteps, ')
          ..write('taskDependencies: $taskDependencies, ')
          ..write('milestones: $milestones, ')
          ..write('resourceTemplates: $resourceTemplates, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('isSystemTemplate: $isSystemTemplate, ')
          ..write('isPublished: $isPublished, ')
          ..write('version: $version, ')
          ..write('usageStats: $usageStats, ')
          ..write('rating: $rating, ')
          ..write('previewImages: $previewImages, ')
          ..write('tags: $tags, ')
          ..write('supportedLocales: $supportedLocales, ')
          ..write('isPremium: $isPremium, ')
          ..write('sizeEstimate: $sizeEstimate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTemplateVariablesTable extends ProjectTemplateVariables
    with TableInfo<$ProjectTemplateVariablesTable, ProjectTemplateVariable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTemplateVariablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _variableKeyMeta =
      const VerificationMeta('variableKey');
  @override
  late final GeneratedColumn<String> variableKey = GeneratedColumn<String>(
      'variable_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRequiredMeta =
      const VerificationMeta('isRequired');
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
      'is_required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_required" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _defaultValueMeta =
      const VerificationMeta('defaultValue');
  @override
  late final GeneratedColumn<String> defaultValue = GeneratedColumn<String>(
      'default_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _validationPatternMeta =
      const VerificationMeta('validationPattern');
  @override
  late final GeneratedColumn<String> validationPattern =
      GeneratedColumn<String>('validation_pattern', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _validationErrorMeta =
      const VerificationMeta('validationError');
  @override
  late final GeneratedColumn<String> validationError = GeneratedColumn<String>(
      'validation_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _minValueMeta =
      const VerificationMeta('minValue');
  @override
  late final GeneratedColumn<String> minValue = GeneratedColumn<String>(
      'min_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maxValueMeta =
      const VerificationMeta('maxValue');
  @override
  late final GeneratedColumn<String> maxValue = GeneratedColumn<String>(
      'max_value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isConditionalMeta =
      const VerificationMeta('isConditional');
  @override
  late final GeneratedColumn<bool> isConditional = GeneratedColumn<bool>(
      'is_conditional', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_conditional" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _dependentVariablesMeta =
      const VerificationMeta('dependentVariables');
  @override
  late final GeneratedColumn<String> dependentVariables =
      GeneratedColumn<String>('dependent_variables', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateId,
        variableKey,
        displayName,
        type,
        description,
        isRequired,
        defaultValue,
        options,
        validationPattern,
        validationError,
        minValue,
        maxValue,
        isConditional,
        dependentVariables,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_template_variables';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProjectTemplateVariable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('variable_key')) {
      context.handle(
          _variableKeyMeta,
          variableKey.isAcceptableOrUnknown(
              data['variable_key']!, _variableKeyMeta));
    } else if (isInserting) {
      context.missing(_variableKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_required')) {
      context.handle(
          _isRequiredMeta,
          isRequired.isAcceptableOrUnknown(
              data['is_required']!, _isRequiredMeta));
    }
    if (data.containsKey('default_value')) {
      context.handle(
          _defaultValueMeta,
          defaultValue.isAcceptableOrUnknown(
              data['default_value']!, _defaultValueMeta));
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    } else if (isInserting) {
      context.missing(_optionsMeta);
    }
    if (data.containsKey('validation_pattern')) {
      context.handle(
          _validationPatternMeta,
          validationPattern.isAcceptableOrUnknown(
              data['validation_pattern']!, _validationPatternMeta));
    }
    if (data.containsKey('validation_error')) {
      context.handle(
          _validationErrorMeta,
          validationError.isAcceptableOrUnknown(
              data['validation_error']!, _validationErrorMeta));
    }
    if (data.containsKey('min_value')) {
      context.handle(_minValueMeta,
          minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta));
    }
    if (data.containsKey('max_value')) {
      context.handle(_maxValueMeta,
          maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta));
    }
    if (data.containsKey('is_conditional')) {
      context.handle(
          _isConditionalMeta,
          isConditional.isAcceptableOrUnknown(
              data['is_conditional']!, _isConditionalMeta));
    }
    if (data.containsKey('dependent_variables')) {
      context.handle(
          _dependentVariablesMeta,
          dependentVariables.isAcceptableOrUnknown(
              data['dependent_variables']!, _dependentVariablesMeta));
    } else if (isInserting) {
      context.missing(_dependentVariablesMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTemplateVariable map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTemplateVariable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      variableKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variable_key'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isRequired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_required'])!,
      defaultValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_value']),
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options'])!,
      validationPattern: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}validation_pattern']),
      validationError: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}validation_error']),
      minValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}min_value']),
      maxValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}max_value']),
      isConditional: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_conditional'])!,
      dependentVariables: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dependent_variables'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $ProjectTemplateVariablesTable createAlias(String alias) {
    return $ProjectTemplateVariablesTable(attachedDatabase, alias);
  }
}

class ProjectTemplateVariable extends DataClass
    implements Insertable<ProjectTemplateVariable> {
  final String id;
  final String templateId;
  final String variableKey;
  final String displayName;
  final int type;
  final String? description;
  final bool isRequired;
  final String? defaultValue;
  final String options;
  final String? validationPattern;
  final String? validationError;
  final String? minValue;
  final String? maxValue;
  final bool isConditional;
  final String dependentVariables;
  final int sortOrder;
  const ProjectTemplateVariable(
      {required this.id,
      required this.templateId,
      required this.variableKey,
      required this.displayName,
      required this.type,
      this.description,
      required this.isRequired,
      this.defaultValue,
      required this.options,
      this.validationPattern,
      this.validationError,
      this.minValue,
      this.maxValue,
      required this.isConditional,
      required this.dependentVariables,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['variable_key'] = Variable<String>(variableKey);
    map['display_name'] = Variable<String>(displayName);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_required'] = Variable<bool>(isRequired);
    if (!nullToAbsent || defaultValue != null) {
      map['default_value'] = Variable<String>(defaultValue);
    }
    map['options'] = Variable<String>(options);
    if (!nullToAbsent || validationPattern != null) {
      map['validation_pattern'] = Variable<String>(validationPattern);
    }
    if (!nullToAbsent || validationError != null) {
      map['validation_error'] = Variable<String>(validationError);
    }
    if (!nullToAbsent || minValue != null) {
      map['min_value'] = Variable<String>(minValue);
    }
    if (!nullToAbsent || maxValue != null) {
      map['max_value'] = Variable<String>(maxValue);
    }
    map['is_conditional'] = Variable<bool>(isConditional);
    map['dependent_variables'] = Variable<String>(dependentVariables);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProjectTemplateVariablesCompanion toCompanion(bool nullToAbsent) {
    return ProjectTemplateVariablesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      variableKey: Value(variableKey),
      displayName: Value(displayName),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isRequired: Value(isRequired),
      defaultValue: defaultValue == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultValue),
      options: Value(options),
      validationPattern: validationPattern == null && nullToAbsent
          ? const Value.absent()
          : Value(validationPattern),
      validationError: validationError == null && nullToAbsent
          ? const Value.absent()
          : Value(validationError),
      minValue: minValue == null && nullToAbsent
          ? const Value.absent()
          : Value(minValue),
      maxValue: maxValue == null && nullToAbsent
          ? const Value.absent()
          : Value(maxValue),
      isConditional: Value(isConditional),
      dependentVariables: Value(dependentVariables),
      sortOrder: Value(sortOrder),
    );
  }

  factory ProjectTemplateVariable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTemplateVariable(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      variableKey: serializer.fromJson<String>(json['variableKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      type: serializer.fromJson<int>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      defaultValue: serializer.fromJson<String?>(json['defaultValue']),
      options: serializer.fromJson<String>(json['options']),
      validationPattern:
          serializer.fromJson<String?>(json['validationPattern']),
      validationError: serializer.fromJson<String?>(json['validationError']),
      minValue: serializer.fromJson<String?>(json['minValue']),
      maxValue: serializer.fromJson<String?>(json['maxValue']),
      isConditional: serializer.fromJson<bool>(json['isConditional']),
      dependentVariables:
          serializer.fromJson<String>(json['dependentVariables']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'variableKey': serializer.toJson<String>(variableKey),
      'displayName': serializer.toJson<String>(displayName),
      'type': serializer.toJson<int>(type),
      'description': serializer.toJson<String?>(description),
      'isRequired': serializer.toJson<bool>(isRequired),
      'defaultValue': serializer.toJson<String?>(defaultValue),
      'options': serializer.toJson<String>(options),
      'validationPattern': serializer.toJson<String?>(validationPattern),
      'validationError': serializer.toJson<String?>(validationError),
      'minValue': serializer.toJson<String?>(minValue),
      'maxValue': serializer.toJson<String?>(maxValue),
      'isConditional': serializer.toJson<bool>(isConditional),
      'dependentVariables': serializer.toJson<String>(dependentVariables),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ProjectTemplateVariable copyWith(
          {String? id,
          String? templateId,
          String? variableKey,
          String? displayName,
          int? type,
          Value<String?> description = const Value.absent(),
          bool? isRequired,
          Value<String?> defaultValue = const Value.absent(),
          String? options,
          Value<String?> validationPattern = const Value.absent(),
          Value<String?> validationError = const Value.absent(),
          Value<String?> minValue = const Value.absent(),
          Value<String?> maxValue = const Value.absent(),
          bool? isConditional,
          String? dependentVariables,
          int? sortOrder}) =>
      ProjectTemplateVariable(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        variableKey: variableKey ?? this.variableKey,
        displayName: displayName ?? this.displayName,
        type: type ?? this.type,
        description: description.present ? description.value : this.description,
        isRequired: isRequired ?? this.isRequired,
        defaultValue:
            defaultValue.present ? defaultValue.value : this.defaultValue,
        options: options ?? this.options,
        validationPattern: validationPattern.present
            ? validationPattern.value
            : this.validationPattern,
        validationError: validationError.present
            ? validationError.value
            : this.validationError,
        minValue: minValue.present ? minValue.value : this.minValue,
        maxValue: maxValue.present ? maxValue.value : this.maxValue,
        isConditional: isConditional ?? this.isConditional,
        dependentVariables: dependentVariables ?? this.dependentVariables,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  ProjectTemplateVariable copyWithCompanion(
      ProjectTemplateVariablesCompanion data) {
    return ProjectTemplateVariable(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      variableKey:
          data.variableKey.present ? data.variableKey.value : this.variableKey,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      type: data.type.present ? data.type.value : this.type,
      description:
          data.description.present ? data.description.value : this.description,
      isRequired:
          data.isRequired.present ? data.isRequired.value : this.isRequired,
      defaultValue: data.defaultValue.present
          ? data.defaultValue.value
          : this.defaultValue,
      options: data.options.present ? data.options.value : this.options,
      validationPattern: data.validationPattern.present
          ? data.validationPattern.value
          : this.validationPattern,
      validationError: data.validationError.present
          ? data.validationError.value
          : this.validationError,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      isConditional: data.isConditional.present
          ? data.isConditional.value
          : this.isConditional,
      dependentVariables: data.dependentVariables.present
          ? data.dependentVariables.value
          : this.dependentVariables,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateVariable(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('variableKey: $variableKey, ')
          ..write('displayName: $displayName, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('isRequired: $isRequired, ')
          ..write('defaultValue: $defaultValue, ')
          ..write('options: $options, ')
          ..write('validationPattern: $validationPattern, ')
          ..write('validationError: $validationError, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('isConditional: $isConditional, ')
          ..write('dependentVariables: $dependentVariables, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      templateId,
      variableKey,
      displayName,
      type,
      description,
      isRequired,
      defaultValue,
      options,
      validationPattern,
      validationError,
      minValue,
      maxValue,
      isConditional,
      dependentVariables,
      sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTemplateVariable &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.variableKey == this.variableKey &&
          other.displayName == this.displayName &&
          other.type == this.type &&
          other.description == this.description &&
          other.isRequired == this.isRequired &&
          other.defaultValue == this.defaultValue &&
          other.options == this.options &&
          other.validationPattern == this.validationPattern &&
          other.validationError == this.validationError &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.isConditional == this.isConditional &&
          other.dependentVariables == this.dependentVariables &&
          other.sortOrder == this.sortOrder);
}

class ProjectTemplateVariablesCompanion
    extends UpdateCompanion<ProjectTemplateVariable> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> variableKey;
  final Value<String> displayName;
  final Value<int> type;
  final Value<String?> description;
  final Value<bool> isRequired;
  final Value<String?> defaultValue;
  final Value<String> options;
  final Value<String?> validationPattern;
  final Value<String?> validationError;
  final Value<String?> minValue;
  final Value<String?> maxValue;
  final Value<bool> isConditional;
  final Value<String> dependentVariables;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ProjectTemplateVariablesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.variableKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.defaultValue = const Value.absent(),
    this.options = const Value.absent(),
    this.validationPattern = const Value.absent(),
    this.validationError = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.isConditional = const Value.absent(),
    this.dependentVariables = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTemplateVariablesCompanion.insert({
    required String id,
    required String templateId,
    required String variableKey,
    required String displayName,
    required int type,
    this.description = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.defaultValue = const Value.absent(),
    required String options,
    this.validationPattern = const Value.absent(),
    this.validationError = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.isConditional = const Value.absent(),
    required String dependentVariables,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        variableKey = Value(variableKey),
        displayName = Value(displayName),
        type = Value(type),
        options = Value(options),
        dependentVariables = Value(dependentVariables);
  static Insertable<ProjectTemplateVariable> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? variableKey,
    Expression<String>? displayName,
    Expression<int>? type,
    Expression<String>? description,
    Expression<bool>? isRequired,
    Expression<String>? defaultValue,
    Expression<String>? options,
    Expression<String>? validationPattern,
    Expression<String>? validationError,
    Expression<String>? minValue,
    Expression<String>? maxValue,
    Expression<bool>? isConditional,
    Expression<String>? dependentVariables,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (variableKey != null) 'variable_key': variableKey,
      if (displayName != null) 'display_name': displayName,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (isRequired != null) 'is_required': isRequired,
      if (defaultValue != null) 'default_value': defaultValue,
      if (options != null) 'options': options,
      if (validationPattern != null) 'validation_pattern': validationPattern,
      if (validationError != null) 'validation_error': validationError,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (isConditional != null) 'is_conditional': isConditional,
      if (dependentVariables != null) 'dependent_variables': dependentVariables,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTemplateVariablesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<String>? variableKey,
      Value<String>? displayName,
      Value<int>? type,
      Value<String?>? description,
      Value<bool>? isRequired,
      Value<String?>? defaultValue,
      Value<String>? options,
      Value<String?>? validationPattern,
      Value<String?>? validationError,
      Value<String?>? minValue,
      Value<String?>? maxValue,
      Value<bool>? isConditional,
      Value<String>? dependentVariables,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return ProjectTemplateVariablesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      variableKey: variableKey ?? this.variableKey,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      validationPattern: validationPattern ?? this.validationPattern,
      validationError: validationError ?? this.validationError,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      isConditional: isConditional ?? this.isConditional,
      dependentVariables: dependentVariables ?? this.dependentVariables,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (variableKey.present) {
      map['variable_key'] = Variable<String>(variableKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (defaultValue.present) {
      map['default_value'] = Variable<String>(defaultValue.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (validationPattern.present) {
      map['validation_pattern'] = Variable<String>(validationPattern.value);
    }
    if (validationError.present) {
      map['validation_error'] = Variable<String>(validationError.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<String>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<String>(maxValue.value);
    }
    if (isConditional.present) {
      map['is_conditional'] = Variable<bool>(isConditional.value);
    }
    if (dependentVariables.present) {
      map['dependent_variables'] = Variable<String>(dependentVariables.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateVariablesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('variableKey: $variableKey, ')
          ..write('displayName: $displayName, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('isRequired: $isRequired, ')
          ..write('defaultValue: $defaultValue, ')
          ..write('options: $options, ')
          ..write('validationPattern: $validationPattern, ')
          ..write('validationError: $validationError, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('isConditional: $isConditional, ')
          ..write('dependentVariables: $dependentVariables, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTemplateWizardStepsTable extends ProjectTemplateWizardSteps
    with
        TableInfo<$ProjectTemplateWizardStepsTable, ProjectTemplateWizardStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTemplateWizardStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _variableKeysMeta =
      const VerificationMeta('variableKeys');
  @override
  late final GeneratedColumn<String> variableKeys = GeneratedColumn<String>(
      'variable_keys', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _showConditionMeta =
      const VerificationMeta('showCondition');
  @override
  late final GeneratedColumn<String> showCondition = GeneratedColumn<String>(
      'show_condition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stepOrderMeta =
      const VerificationMeta('stepOrder');
  @override
  late final GeneratedColumn<int> stepOrder = GeneratedColumn<int>(
      'step_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isOptionalMeta =
      const VerificationMeta('isOptional');
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
      'is_optional', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_optional" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateId,
        title,
        description,
        variableKeys,
        showCondition,
        stepOrder,
        isOptional,
        iconName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_template_wizard_steps';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProjectTemplateWizardStep> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('variable_keys')) {
      context.handle(
          _variableKeysMeta,
          variableKeys.isAcceptableOrUnknown(
              data['variable_keys']!, _variableKeysMeta));
    } else if (isInserting) {
      context.missing(_variableKeysMeta);
    }
    if (data.containsKey('show_condition')) {
      context.handle(
          _showConditionMeta,
          showCondition.isAcceptableOrUnknown(
              data['show_condition']!, _showConditionMeta));
    }
    if (data.containsKey('step_order')) {
      context.handle(_stepOrderMeta,
          stepOrder.isAcceptableOrUnknown(data['step_order']!, _stepOrderMeta));
    } else if (isInserting) {
      context.missing(_stepOrderMeta);
    }
    if (data.containsKey('is_optional')) {
      context.handle(
          _isOptionalMeta,
          isOptional.isAcceptableOrUnknown(
              data['is_optional']!, _isOptionalMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTemplateWizardStep map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTemplateWizardStep(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      variableKeys: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variable_keys'])!,
      showCondition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}show_condition']),
      stepOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_order'])!,
      isOptional: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_optional'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
    );
  }

  @override
  $ProjectTemplateWizardStepsTable createAlias(String alias) {
    return $ProjectTemplateWizardStepsTable(attachedDatabase, alias);
  }
}

class ProjectTemplateWizardStep extends DataClass
    implements Insertable<ProjectTemplateWizardStep> {
  final String id;
  final String templateId;
  final String title;
  final String? description;
  final String variableKeys;
  final String? showCondition;
  final int stepOrder;
  final bool isOptional;
  final String? iconName;
  const ProjectTemplateWizardStep(
      {required this.id,
      required this.templateId,
      required this.title,
      this.description,
      required this.variableKeys,
      this.showCondition,
      required this.stepOrder,
      required this.isOptional,
      this.iconName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['variable_keys'] = Variable<String>(variableKeys);
    if (!nullToAbsent || showCondition != null) {
      map['show_condition'] = Variable<String>(showCondition);
    }
    map['step_order'] = Variable<int>(stepOrder);
    map['is_optional'] = Variable<bool>(isOptional);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    return map;
  }

  ProjectTemplateWizardStepsCompanion toCompanion(bool nullToAbsent) {
    return ProjectTemplateWizardStepsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      variableKeys: Value(variableKeys),
      showCondition: showCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(showCondition),
      stepOrder: Value(stepOrder),
      isOptional: Value(isOptional),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
    );
  }

  factory ProjectTemplateWizardStep.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTemplateWizardStep(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      variableKeys: serializer.fromJson<String>(json['variableKeys']),
      showCondition: serializer.fromJson<String?>(json['showCondition']),
      stepOrder: serializer.fromJson<int>(json['stepOrder']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
      iconName: serializer.fromJson<String?>(json['iconName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'variableKeys': serializer.toJson<String>(variableKeys),
      'showCondition': serializer.toJson<String?>(showCondition),
      'stepOrder': serializer.toJson<int>(stepOrder),
      'isOptional': serializer.toJson<bool>(isOptional),
      'iconName': serializer.toJson<String?>(iconName),
    };
  }

  ProjectTemplateWizardStep copyWith(
          {String? id,
          String? templateId,
          String? title,
          Value<String?> description = const Value.absent(),
          String? variableKeys,
          Value<String?> showCondition = const Value.absent(),
          int? stepOrder,
          bool? isOptional,
          Value<String?> iconName = const Value.absent()}) =>
      ProjectTemplateWizardStep(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        variableKeys: variableKeys ?? this.variableKeys,
        showCondition:
            showCondition.present ? showCondition.value : this.showCondition,
        stepOrder: stepOrder ?? this.stepOrder,
        isOptional: isOptional ?? this.isOptional,
        iconName: iconName.present ? iconName.value : this.iconName,
      );
  ProjectTemplateWizardStep copyWithCompanion(
      ProjectTemplateWizardStepsCompanion data) {
    return ProjectTemplateWizardStep(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      variableKeys: data.variableKeys.present
          ? data.variableKeys.value
          : this.variableKeys,
      showCondition: data.showCondition.present
          ? data.showCondition.value
          : this.showCondition,
      stepOrder: data.stepOrder.present ? data.stepOrder.value : this.stepOrder,
      isOptional:
          data.isOptional.present ? data.isOptional.value : this.isOptional,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateWizardStep(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('variableKeys: $variableKeys, ')
          ..write('showCondition: $showCondition, ')
          ..write('stepOrder: $stepOrder, ')
          ..write('isOptional: $isOptional, ')
          ..write('iconName: $iconName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, title, description,
      variableKeys, showCondition, stepOrder, isOptional, iconName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTemplateWizardStep &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.title == this.title &&
          other.description == this.description &&
          other.variableKeys == this.variableKeys &&
          other.showCondition == this.showCondition &&
          other.stepOrder == this.stepOrder &&
          other.isOptional == this.isOptional &&
          other.iconName == this.iconName);
}

class ProjectTemplateWizardStepsCompanion
    extends UpdateCompanion<ProjectTemplateWizardStep> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> variableKeys;
  final Value<String?> showCondition;
  final Value<int> stepOrder;
  final Value<bool> isOptional;
  final Value<String?> iconName;
  final Value<int> rowid;
  const ProjectTemplateWizardStepsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.variableKeys = const Value.absent(),
    this.showCondition = const Value.absent(),
    this.stepOrder = const Value.absent(),
    this.isOptional = const Value.absent(),
    this.iconName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTemplateWizardStepsCompanion.insert({
    required String id,
    required String templateId,
    required String title,
    this.description = const Value.absent(),
    required String variableKeys,
    this.showCondition = const Value.absent(),
    required int stepOrder,
    this.isOptional = const Value.absent(),
    this.iconName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        title = Value(title),
        variableKeys = Value(variableKeys),
        stepOrder = Value(stepOrder);
  static Insertable<ProjectTemplateWizardStep> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? variableKeys,
    Expression<String>? showCondition,
    Expression<int>? stepOrder,
    Expression<bool>? isOptional,
    Expression<String>? iconName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (variableKeys != null) 'variable_keys': variableKeys,
      if (showCondition != null) 'show_condition': showCondition,
      if (stepOrder != null) 'step_order': stepOrder,
      if (isOptional != null) 'is_optional': isOptional,
      if (iconName != null) 'icon_name': iconName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTemplateWizardStepsCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? variableKeys,
      Value<String?>? showCondition,
      Value<int>? stepOrder,
      Value<bool>? isOptional,
      Value<String?>? iconName,
      Value<int>? rowid}) {
    return ProjectTemplateWizardStepsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      description: description ?? this.description,
      variableKeys: variableKeys ?? this.variableKeys,
      showCondition: showCondition ?? this.showCondition,
      stepOrder: stepOrder ?? this.stepOrder,
      isOptional: isOptional ?? this.isOptional,
      iconName: iconName ?? this.iconName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (variableKeys.present) {
      map['variable_keys'] = Variable<String>(variableKeys.value);
    }
    if (showCondition.present) {
      map['show_condition'] = Variable<String>(showCondition.value);
    }
    if (stepOrder.present) {
      map['step_order'] = Variable<int>(stepOrder.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateWizardStepsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('variableKeys: $variableKeys, ')
          ..write('showCondition: $showCondition, ')
          ..write('stepOrder: $stepOrder, ')
          ..write('isOptional: $isOptional, ')
          ..write('iconName: $iconName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTemplateMilestonesTable extends ProjectTemplateMilestones
    with TableInfo<$ProjectTemplateMilestonesTable, ProjectTemplateMilestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTemplateMilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dayOffsetMeta =
      const VerificationMeta('dayOffset');
  @override
  late final GeneratedColumn<int> dayOffset = GeneratedColumn<int>(
      'day_offset', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _requiredTaskIdsMeta =
      const VerificationMeta('requiredTaskIds');
  @override
  late final GeneratedColumn<String> requiredTaskIds = GeneratedColumn<String>(
      'required_task_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateId,
        name,
        description,
        dayOffset,
        requiredTaskIds,
        iconName,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_template_milestones';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProjectTemplateMilestone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('day_offset')) {
      context.handle(_dayOffsetMeta,
          dayOffset.isAcceptableOrUnknown(data['day_offset']!, _dayOffsetMeta));
    } else if (isInserting) {
      context.missing(_dayOffsetMeta);
    }
    if (data.containsKey('required_task_ids')) {
      context.handle(
          _requiredTaskIdsMeta,
          requiredTaskIds.isAcceptableOrUnknown(
              data['required_task_ids']!, _requiredTaskIdsMeta));
    } else if (isInserting) {
      context.missing(_requiredTaskIdsMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTemplateMilestone map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTemplateMilestone(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dayOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_offset'])!,
      requiredTaskIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}required_task_ids'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $ProjectTemplateMilestonesTable createAlias(String alias) {
    return $ProjectTemplateMilestonesTable(attachedDatabase, alias);
  }
}

class ProjectTemplateMilestone extends DataClass
    implements Insertable<ProjectTemplateMilestone> {
  final String id;
  final String templateId;
  final String name;
  final String? description;
  final int dayOffset;
  final String requiredTaskIds;
  final String? iconName;
  final int sortOrder;
  const ProjectTemplateMilestone(
      {required this.id,
      required this.templateId,
      required this.name,
      this.description,
      required this.dayOffset,
      required this.requiredTaskIds,
      this.iconName,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['day_offset'] = Variable<int>(dayOffset);
    map['required_task_ids'] = Variable<String>(requiredTaskIds);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProjectTemplateMilestonesCompanion toCompanion(bool nullToAbsent) {
    return ProjectTemplateMilestonesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dayOffset: Value(dayOffset),
      requiredTaskIds: Value(requiredTaskIds),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
    );
  }

  factory ProjectTemplateMilestone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTemplateMilestone(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      dayOffset: serializer.fromJson<int>(json['dayOffset']),
      requiredTaskIds: serializer.fromJson<String>(json['requiredTaskIds']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'dayOffset': serializer.toJson<int>(dayOffset),
      'requiredTaskIds': serializer.toJson<String>(requiredTaskIds),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ProjectTemplateMilestone copyWith(
          {String? id,
          String? templateId,
          String? name,
          Value<String?> description = const Value.absent(),
          int? dayOffset,
          String? requiredTaskIds,
          Value<String?> iconName = const Value.absent(),
          int? sortOrder}) =>
      ProjectTemplateMilestone(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        dayOffset: dayOffset ?? this.dayOffset,
        requiredTaskIds: requiredTaskIds ?? this.requiredTaskIds,
        iconName: iconName.present ? iconName.value : this.iconName,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  ProjectTemplateMilestone copyWithCompanion(
      ProjectTemplateMilestonesCompanion data) {
    return ProjectTemplateMilestone(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      dayOffset: data.dayOffset.present ? data.dayOffset.value : this.dayOffset,
      requiredTaskIds: data.requiredTaskIds.present
          ? data.requiredTaskIds.value
          : this.requiredTaskIds,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateMilestone(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('dayOffset: $dayOffset, ')
          ..write('requiredTaskIds: $requiredTaskIds, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, name, description, dayOffset,
      requiredTaskIds, iconName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTemplateMilestone &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.name == this.name &&
          other.description == this.description &&
          other.dayOffset == this.dayOffset &&
          other.requiredTaskIds == this.requiredTaskIds &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder);
}

class ProjectTemplateMilestonesCompanion
    extends UpdateCompanion<ProjectTemplateMilestone> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> dayOffset;
  final Value<String> requiredTaskIds;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ProjectTemplateMilestonesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.dayOffset = const Value.absent(),
    this.requiredTaskIds = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTemplateMilestonesCompanion.insert({
    required String id,
    required String templateId,
    required String name,
    this.description = const Value.absent(),
    required int dayOffset,
    required String requiredTaskIds,
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        name = Value(name),
        dayOffset = Value(dayOffset),
        requiredTaskIds = Value(requiredTaskIds);
  static Insertable<ProjectTemplateMilestone> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? dayOffset,
    Expression<String>? requiredTaskIds,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (dayOffset != null) 'day_offset': dayOffset,
      if (requiredTaskIds != null) 'required_task_ids': requiredTaskIds,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTemplateMilestonesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? dayOffset,
      Value<String>? requiredTaskIds,
      Value<String?>? iconName,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return ProjectTemplateMilestonesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      description: description ?? this.description,
      dayOffset: dayOffset ?? this.dayOffset,
      requiredTaskIds: requiredTaskIds ?? this.requiredTaskIds,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dayOffset.present) {
      map['day_offset'] = Variable<int>(dayOffset.value);
    }
    if (requiredTaskIds.present) {
      map['required_task_ids'] = Variable<String>(requiredTaskIds.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateMilestonesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('dayOffset: $dayOffset, ')
          ..write('requiredTaskIds: $requiredTaskIds, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectTemplateTaskTemplatesTable extends ProjectTemplateTaskTemplates
    with
        TableInfo<$ProjectTemplateTaskTemplatesTable,
            ProjectTemplateTaskTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTemplateTaskTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectTemplateIdMeta =
      const VerificationMeta('projectTemplateId');
  @override
  late final GeneratedColumn<String> projectTemplateId =
      GeneratedColumn<String>('project_template_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskTemplateIdMeta =
      const VerificationMeta('taskTemplateId');
  @override
  late final GeneratedColumn<String> taskTemplateId = GeneratedColumn<String>(
      'task_template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taskDependenciesMeta =
      const VerificationMeta('taskDependencies');
  @override
  late final GeneratedColumn<String> taskDependencies = GeneratedColumn<String>(
      'task_dependencies', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [projectTemplateId, taskTemplateId, sortOrder, taskDependencies];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_template_task_templates';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProjectTemplateTaskTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_template_id')) {
      context.handle(
          _projectTemplateIdMeta,
          projectTemplateId.isAcceptableOrUnknown(
              data['project_template_id']!, _projectTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_projectTemplateIdMeta);
    }
    if (data.containsKey('task_template_id')) {
      context.handle(
          _taskTemplateIdMeta,
          taskTemplateId.isAcceptableOrUnknown(
              data['task_template_id']!, _taskTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_taskTemplateIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('task_dependencies')) {
      context.handle(
          _taskDependenciesMeta,
          taskDependencies.isAcceptableOrUnknown(
              data['task_dependencies']!, _taskDependenciesMeta));
    } else if (isInserting) {
      context.missing(_taskDependenciesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectTemplateId, taskTemplateId};
  @override
  ProjectTemplateTaskTemplate map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTemplateTaskTemplate(
      projectTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}project_template_id'])!,
      taskTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}task_template_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      taskDependencies: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}task_dependencies'])!,
    );
  }

  @override
  $ProjectTemplateTaskTemplatesTable createAlias(String alias) {
    return $ProjectTemplateTaskTemplatesTable(attachedDatabase, alias);
  }
}

class ProjectTemplateTaskTemplate extends DataClass
    implements Insertable<ProjectTemplateTaskTemplate> {
  final String projectTemplateId;
  final String taskTemplateId;
  final int sortOrder;
  final String taskDependencies;
  const ProjectTemplateTaskTemplate(
      {required this.projectTemplateId,
      required this.taskTemplateId,
      required this.sortOrder,
      required this.taskDependencies});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_template_id'] = Variable<String>(projectTemplateId);
    map['task_template_id'] = Variable<String>(taskTemplateId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['task_dependencies'] = Variable<String>(taskDependencies);
    return map;
  }

  ProjectTemplateTaskTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ProjectTemplateTaskTemplatesCompanion(
      projectTemplateId: Value(projectTemplateId),
      taskTemplateId: Value(taskTemplateId),
      sortOrder: Value(sortOrder),
      taskDependencies: Value(taskDependencies),
    );
  }

  factory ProjectTemplateTaskTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTemplateTaskTemplate(
      projectTemplateId: serializer.fromJson<String>(json['projectTemplateId']),
      taskTemplateId: serializer.fromJson<String>(json['taskTemplateId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      taskDependencies: serializer.fromJson<String>(json['taskDependencies']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectTemplateId': serializer.toJson<String>(projectTemplateId),
      'taskTemplateId': serializer.toJson<String>(taskTemplateId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'taskDependencies': serializer.toJson<String>(taskDependencies),
    };
  }

  ProjectTemplateTaskTemplate copyWith(
          {String? projectTemplateId,
          String? taskTemplateId,
          int? sortOrder,
          String? taskDependencies}) =>
      ProjectTemplateTaskTemplate(
        projectTemplateId: projectTemplateId ?? this.projectTemplateId,
        taskTemplateId: taskTemplateId ?? this.taskTemplateId,
        sortOrder: sortOrder ?? this.sortOrder,
        taskDependencies: taskDependencies ?? this.taskDependencies,
      );
  ProjectTemplateTaskTemplate copyWithCompanion(
      ProjectTemplateTaskTemplatesCompanion data) {
    return ProjectTemplateTaskTemplate(
      projectTemplateId: data.projectTemplateId.present
          ? data.projectTemplateId.value
          : this.projectTemplateId,
      taskTemplateId: data.taskTemplateId.present
          ? data.taskTemplateId.value
          : this.taskTemplateId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      taskDependencies: data.taskDependencies.present
          ? data.taskDependencies.value
          : this.taskDependencies,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateTaskTemplate(')
          ..write('projectTemplateId: $projectTemplateId, ')
          ..write('taskTemplateId: $taskTemplateId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('taskDependencies: $taskDependencies')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      projectTemplateId, taskTemplateId, sortOrder, taskDependencies);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTemplateTaskTemplate &&
          other.projectTemplateId == this.projectTemplateId &&
          other.taskTemplateId == this.taskTemplateId &&
          other.sortOrder == this.sortOrder &&
          other.taskDependencies == this.taskDependencies);
}

class ProjectTemplateTaskTemplatesCompanion
    extends UpdateCompanion<ProjectTemplateTaskTemplate> {
  final Value<String> projectTemplateId;
  final Value<String> taskTemplateId;
  final Value<int> sortOrder;
  final Value<String> taskDependencies;
  final Value<int> rowid;
  const ProjectTemplateTaskTemplatesCompanion({
    this.projectTemplateId = const Value.absent(),
    this.taskTemplateId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.taskDependencies = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectTemplateTaskTemplatesCompanion.insert({
    required String projectTemplateId,
    required String taskTemplateId,
    this.sortOrder = const Value.absent(),
    required String taskDependencies,
    this.rowid = const Value.absent(),
  })  : projectTemplateId = Value(projectTemplateId),
        taskTemplateId = Value(taskTemplateId),
        taskDependencies = Value(taskDependencies);
  static Insertable<ProjectTemplateTaskTemplate> custom({
    Expression<String>? projectTemplateId,
    Expression<String>? taskTemplateId,
    Expression<int>? sortOrder,
    Expression<String>? taskDependencies,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectTemplateId != null) 'project_template_id': projectTemplateId,
      if (taskTemplateId != null) 'task_template_id': taskTemplateId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (taskDependencies != null) 'task_dependencies': taskDependencies,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectTemplateTaskTemplatesCompanion copyWith(
      {Value<String>? projectTemplateId,
      Value<String>? taskTemplateId,
      Value<int>? sortOrder,
      Value<String>? taskDependencies,
      Value<int>? rowid}) {
    return ProjectTemplateTaskTemplatesCompanion(
      projectTemplateId: projectTemplateId ?? this.projectTemplateId,
      taskTemplateId: taskTemplateId ?? this.taskTemplateId,
      sortOrder: sortOrder ?? this.sortOrder,
      taskDependencies: taskDependencies ?? this.taskDependencies,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectTemplateId.present) {
      map['project_template_id'] = Variable<String>(projectTemplateId.value);
    }
    if (taskTemplateId.present) {
      map['task_template_id'] = Variable<String>(taskTemplateId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (taskDependencies.present) {
      map['task_dependencies'] = Variable<String>(taskDependencies.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTemplateTaskTemplatesCompanion(')
          ..write('projectTemplateId: $projectTemplateId, ')
          ..write('taskTemplateId: $taskTemplateId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('taskDependencies: $taskDependencies, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profilePicturePathMeta =
      const VerificationMeta('profilePicturePath');
  @override
  late final GeneratedColumn<String> profilePicturePath =
      GeneratedColumn<String>('profile_picture_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        firstName,
        lastName,
        profilePicturePath,
        location,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('profile_picture_path')) {
      context.handle(
          _profilePicturePathMeta,
          profilePicturePath.isAcceptableOrUnknown(
              data['profile_picture_path']!, _profilePicturePathMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      profilePicturePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}profile_picture_path']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String firstName;
  final String? lastName;
  final String? profilePicturePath;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserProfile(
      {required this.id,
      required this.firstName,
      this.lastName,
      this.profilePicturePath,
      this.location,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || profilePicturePath != null) {
      map['profile_picture_path'] = Variable<String>(profilePicturePath);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      profilePicturePath: profilePicturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicturePath),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      profilePicturePath:
          serializer.fromJson<String?>(json['profilePicturePath']),
      location: serializer.fromJson<String?>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'profilePicturePath': serializer.toJson<String?>(profilePicturePath),
      'location': serializer.toJson<String?>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith(
          {String? id,
          String? firstName,
          Value<String?> lastName = const Value.absent(),
          Value<String?> profilePicturePath = const Value.absent(),
          Value<String?> location = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserProfile(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName.present ? lastName.value : this.lastName,
        profilePicturePath: profilePicturePath.present
            ? profilePicturePath.value
            : this.profilePicturePath,
        location: location.present ? location.value : this.location,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      profilePicturePath: data.profilePicturePath.present
          ? data.profilePicturePath.value
          : this.profilePicturePath,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('profilePicturePath: $profilePicturePath, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, firstName, lastName, profilePicturePath,
      location, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.profilePicturePath == this.profilePicturePath &&
          other.location == this.location &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String?> lastName;
  final Value<String?> profilePicturePath;
  final Value<String?> location;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.profilePicturePath = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String firstName,
    this.lastName = const Value.absent(),
    this.profilePicturePath = const Value.absent(),
    this.location = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        firstName = Value(firstName),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? profilePicturePath,
    Expression<String>? location,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (profilePicturePath != null)
        'profile_picture_path': profilePicturePath,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? firstName,
      Value<String?>? lastName,
      Value<String?>? profilePicturePath,
      Value<String?>? location,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (profilePicturePath.present) {
      map['profile_picture_path'] = Variable<String>(profilePicturePath.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('profilePicturePath: $profilePicturePath, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubTasksTable subTasks = $SubTasksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TaskTagsTable taskTags = $TaskTagsTable(this);
  late final $ProjectTagsTable projectTags = $ProjectTagsTable(this);
  late final $ProjectCategoriesTable projectCategories =
      $ProjectCategoriesTable(this);
  late final $TaskDependenciesTable taskDependencies =
      $TaskDependenciesTable(this);
  late final $TaskTemplatesTable taskTemplates = $TaskTemplatesTable(this);
  late final $ProjectTemplatesTable projectTemplates =
      $ProjectTemplatesTable(this);
  late final $ProjectTemplateVariablesTable projectTemplateVariables =
      $ProjectTemplateVariablesTable(this);
  late final $ProjectTemplateWizardStepsTable projectTemplateWizardSteps =
      $ProjectTemplateWizardStepsTable(this);
  late final $ProjectTemplateMilestonesTable projectTemplateMilestones =
      $ProjectTemplateMilestonesTable(this);
  late final $ProjectTemplateTaskTemplatesTable projectTemplateTaskTemplates =
      $ProjectTemplateTaskTemplatesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final SubtaskDao subtaskDao = SubtaskDao(this as AppDatabase);
  late final ProjectDao projectDao = ProjectDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final TaskTemplateDao taskTemplateDao =
      TaskTemplateDao(this as AppDatabase);
  late final ProjectTemplateDao projectTemplateDao =
      ProjectTemplateDao(this as AppDatabase);
  late final UserProfileDao userProfileDao =
      UserProfileDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        projects,
        tasks,
        subTasks,
        tags,
        taskTags,
        projectTags,
        projectCategories,
        taskDependencies,
        taskTemplates,
        projectTemplates,
        projectTemplateVariables,
        projectTemplateWizardSteps,
        projectTemplateMilestones,
        projectTemplateTaskTemplates,
        userProfiles
      ];
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String color,
  Value<String?> categoryId,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isArchived,
  Value<DateTime?> deadline,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> color,
  Value<String?> categoryId,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<bool> isArchived,
  Value<DateTime?> deadline,
  Value<int> rowid,
});

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
    Project,
    PrefetchHooks Function()> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            description: description,
            color: color,
            categoryId: categoryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
            deadline: deadline,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String color,
            Value<String?> categoryId = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            description: description,
            color: color,
            categoryId: categoryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
            deadline: deadline,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
    Project,
    PrefetchHooks Function()>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime?> dueDate,
  Value<DateTime?> completedAt,
  required int priority,
  required int status,
  Value<String?> locationTrigger,
  Value<String?> projectId,
  required String metadata,
  Value<bool> isPinned,
  Value<int?> estimatedDuration,
  Value<int?> actualDuration,
  Value<int?> recurrenceType,
  Value<int?> recurrenceInterval,
  Value<String?> recurrenceDaysOfWeek,
  Value<DateTime?> recurrenceEndDate,
  Value<int?> recurrenceMaxOccurrences,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<DateTime?> dueDate,
  Value<DateTime?> completedAt,
  Value<int> priority,
  Value<int> status,
  Value<String?> locationTrigger,
  Value<String?> projectId,
  Value<String> metadata,
  Value<bool> isPinned,
  Value<int?> estimatedDuration,
  Value<int?> actualDuration,
  Value<int?> recurrenceType,
  Value<int?> recurrenceInterval,
  Value<String?> recurrenceDaysOfWeek,
  Value<DateTime?> recurrenceEndDate,
  Value<int?> recurrenceMaxOccurrences,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationTrigger => $composableBuilder(
      column: $table.locationTrigger,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualDuration => $composableBuilder(
      column: $table.actualDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
      column: $table.recurrenceInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceDaysOfWeek => $composableBuilder(
      column: $table.recurrenceDaysOfWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceMaxOccurrences => $composableBuilder(
      column: $table.recurrenceMaxOccurrences,
      builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationTrigger => $composableBuilder(
      column: $table.locationTrigger,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualDuration => $composableBuilder(
      column: $table.actualDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
      column: $table.recurrenceInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceDaysOfWeek => $composableBuilder(
      column: $table.recurrenceDaysOfWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceMaxOccurrences => $composableBuilder(
      column: $table.recurrenceMaxOccurrences,
      builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get locationTrigger => $composableBuilder(
      column: $table.locationTrigger, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration, builder: (column) => column);

  GeneratedColumn<int> get actualDuration => $composableBuilder(
      column: $table.actualDuration, builder: (column) => column);

  GeneratedColumn<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType, builder: (column) => column);

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
      column: $table.recurrenceInterval, builder: (column) => column);

  GeneratedColumn<String> get recurrenceDaysOfWeek => $composableBuilder(
      column: $table.recurrenceDaysOfWeek, builder: (column) => column);

  GeneratedColumn<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate, builder: (column) => column);

  GeneratedColumn<int> get recurrenceMaxOccurrences => $composableBuilder(
      column: $table.recurrenceMaxOccurrences, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String?> locationTrigger = const Value.absent(),
            Value<String?> projectId = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int?> estimatedDuration = const Value.absent(),
            Value<int?> actualDuration = const Value.absent(),
            Value<int?> recurrenceType = const Value.absent(),
            Value<int?> recurrenceInterval = const Value.absent(),
            Value<String?> recurrenceDaysOfWeek = const Value.absent(),
            Value<DateTime?> recurrenceEndDate = const Value.absent(),
            Value<int?> recurrenceMaxOccurrences = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dueDate: dueDate,
            completedAt: completedAt,
            priority: priority,
            status: status,
            locationTrigger: locationTrigger,
            projectId: projectId,
            metadata: metadata,
            isPinned: isPinned,
            estimatedDuration: estimatedDuration,
            actualDuration: actualDuration,
            recurrenceType: recurrenceType,
            recurrenceInterval: recurrenceInterval,
            recurrenceDaysOfWeek: recurrenceDaysOfWeek,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceMaxOccurrences: recurrenceMaxOccurrences,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required int priority,
            required int status,
            Value<String?> locationTrigger = const Value.absent(),
            Value<String?> projectId = const Value.absent(),
            required String metadata,
            Value<bool> isPinned = const Value.absent(),
            Value<int?> estimatedDuration = const Value.absent(),
            Value<int?> actualDuration = const Value.absent(),
            Value<int?> recurrenceType = const Value.absent(),
            Value<int?> recurrenceInterval = const Value.absent(),
            Value<String?> recurrenceDaysOfWeek = const Value.absent(),
            Value<DateTime?> recurrenceEndDate = const Value.absent(),
            Value<int?> recurrenceMaxOccurrences = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dueDate: dueDate,
            completedAt: completedAt,
            priority: priority,
            status: status,
            locationTrigger: locationTrigger,
            projectId: projectId,
            metadata: metadata,
            isPinned: isPinned,
            estimatedDuration: estimatedDuration,
            actualDuration: actualDuration,
            recurrenceType: recurrenceType,
            recurrenceInterval: recurrenceInterval,
            recurrenceDaysOfWeek: recurrenceDaysOfWeek,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceMaxOccurrences: recurrenceMaxOccurrences,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()>;
typedef $$SubTasksTableCreateCompanionBuilder = SubTasksCompanion Function({
  required String id,
  required String taskId,
  required String title,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SubTasksTableUpdateCompanionBuilder = SubTasksCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> title,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SubTasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubTasksTable> {
  $$SubTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SubTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubTasksTable> {
  $$SubTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SubTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubTasksTable> {
  $$SubTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SubTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubTasksTable,
    SubTask,
    $$SubTasksTableFilterComposer,
    $$SubTasksTableOrderingComposer,
    $$SubTasksTableAnnotationComposer,
    $$SubTasksTableCreateCompanionBuilder,
    $$SubTasksTableUpdateCompanionBuilder,
    (SubTask, BaseReferences<_$AppDatabase, $SubTasksTable, SubTask>),
    SubTask,
    PrefetchHooks Function()> {
  $$SubTasksTableTableManager(_$AppDatabase db, $SubTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubTasksCompanion(
            id: id,
            taskId: taskId,
            title: title,
            isCompleted: isCompleted,
            completedAt: completedAt,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required String title,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubTasksCompanion.insert(
            id: id,
            taskId: taskId,
            title: title,
            isCompleted: isCompleted,
            completedAt: completedAt,
            sortOrder: sortOrder,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubTasksTable,
    SubTask,
    $$SubTasksTableFilterComposer,
    $$SubTasksTableOrderingComposer,
    $$SubTasksTableAnnotationComposer,
    $$SubTasksTableCreateCompanionBuilder,
    $$SubTasksTableUpdateCompanionBuilder,
    (SubTask, BaseReferences<_$AppDatabase, $SubTasksTable, SubTask>),
    SubTask,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<String?> color,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> color,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> color = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$TaskTagsTableCreateCompanionBuilder = TaskTagsCompanion Function({
  required String taskId,
  required String tagId,
  Value<int> rowid,
});
typedef $$TaskTagsTableUpdateCompanionBuilder = TaskTagsCompanion Function({
  Value<String> taskId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$TaskTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$TaskTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$TaskTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$TaskTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskTagsTable,
    TaskTag,
    $$TaskTagsTableFilterComposer,
    $$TaskTagsTableOrderingComposer,
    $$TaskTagsTableAnnotationComposer,
    $$TaskTagsTableCreateCompanionBuilder,
    $$TaskTagsTableUpdateCompanionBuilder,
    (TaskTag, BaseReferences<_$AppDatabase, $TaskTagsTable, TaskTag>),
    TaskTag,
    PrefetchHooks Function()> {
  $$TaskTagsTableTableManager(_$AppDatabase db, $TaskTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTagsCompanion(
            taskId: taskId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTagsCompanion.insert(
            taskId: taskId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaskTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskTagsTable,
    TaskTag,
    $$TaskTagsTableFilterComposer,
    $$TaskTagsTableOrderingComposer,
    $$TaskTagsTableAnnotationComposer,
    $$TaskTagsTableCreateCompanionBuilder,
    $$TaskTagsTableUpdateCompanionBuilder,
    (TaskTag, BaseReferences<_$AppDatabase, $TaskTagsTable, TaskTag>),
    TaskTag,
    PrefetchHooks Function()>;
typedef $$ProjectTagsTableCreateCompanionBuilder = ProjectTagsCompanion
    Function({
  required String projectId,
  required String tagId,
  Value<int> rowid,
});
typedef $$ProjectTagsTableUpdateCompanionBuilder = ProjectTagsCompanion
    Function({
  Value<String> projectId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$ProjectTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTagsTable> {
  $$ProjectTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$ProjectTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTagsTable> {
  $$ProjectTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$ProjectTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTagsTable> {
  $$ProjectTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$ProjectTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTagsTable,
    ProjectTag,
    $$ProjectTagsTableFilterComposer,
    $$ProjectTagsTableOrderingComposer,
    $$ProjectTagsTableAnnotationComposer,
    $$ProjectTagsTableCreateCompanionBuilder,
    $$ProjectTagsTableUpdateCompanionBuilder,
    (ProjectTag, BaseReferences<_$AppDatabase, $ProjectTagsTable, ProjectTag>),
    ProjectTag,
    PrefetchHooks Function()> {
  $$ProjectTagsTableTableManager(_$AppDatabase db, $ProjectTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> projectId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTagsCompanion(
            projectId: projectId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String projectId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTagsCompanion.insert(
            projectId: projectId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectTagsTable,
    ProjectTag,
    $$ProjectTagsTableFilterComposer,
    $$ProjectTagsTableOrderingComposer,
    $$ProjectTagsTableAnnotationComposer,
    $$ProjectTagsTableCreateCompanionBuilder,
    $$ProjectTagsTableUpdateCompanionBuilder,
    (ProjectTag, BaseReferences<_$AppDatabase, $ProjectTagsTable, ProjectTag>),
    ProjectTag,
    PrefetchHooks Function()>;
typedef $$ProjectCategoriesTableCreateCompanionBuilder
    = ProjectCategoriesCompanion Function({
  required String id,
  required String name,
  required String iconName,
  required String color,
  Value<String?> parentId,
  Value<bool> isSystemDefined,
  Value<bool> isActive,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<String> metadata,
  Value<int> rowid,
});
typedef $$ProjectCategoriesTableUpdateCompanionBuilder
    = ProjectCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> iconName,
  Value<String> color,
  Value<String?> parentId,
  Value<bool> isSystemDefined,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String> metadata,
  Value<int> rowid,
});

class $$ProjectCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectCategoriesTable> {
  $$ProjectCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystemDefined => $composableBuilder(
      column: $table.isSystemDefined,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));
}

class $$ProjectCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectCategoriesTable> {
  $$ProjectCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystemDefined => $composableBuilder(
      column: $table.isSystemDefined,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
}

class $$ProjectCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectCategoriesTable> {
  $$ProjectCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isSystemDefined => $composableBuilder(
      column: $table.isSystemDefined, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$ProjectCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectCategoriesTable,
    ProjectCategory,
    $$ProjectCategoriesTableFilterComposer,
    $$ProjectCategoriesTableOrderingComposer,
    $$ProjectCategoriesTableAnnotationComposer,
    $$ProjectCategoriesTableCreateCompanionBuilder,
    $$ProjectCategoriesTableUpdateCompanionBuilder,
    (
      ProjectCategory,
      BaseReferences<_$AppDatabase, $ProjectCategoriesTable, ProjectCategory>
    ),
    ProjectCategory,
    PrefetchHooks Function()> {
  $$ProjectCategoriesTableTableManager(
      _$AppDatabase db, $ProjectCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> iconName = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<bool> isSystemDefined = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectCategoriesCompanion(
            id: id,
            name: name,
            iconName: iconName,
            color: color,
            parentId: parentId,
            isSystemDefined: isSystemDefined,
            isActive: isActive,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String iconName,
            required String color,
            Value<String?> parentId = const Value.absent(),
            Value<bool> isSystemDefined = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectCategoriesCompanion.insert(
            id: id,
            name: name,
            iconName: iconName,
            color: color,
            parentId: parentId,
            isSystemDefined: isSystemDefined,
            isActive: isActive,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectCategoriesTable,
    ProjectCategory,
    $$ProjectCategoriesTableFilterComposer,
    $$ProjectCategoriesTableOrderingComposer,
    $$ProjectCategoriesTableAnnotationComposer,
    $$ProjectCategoriesTableCreateCompanionBuilder,
    $$ProjectCategoriesTableUpdateCompanionBuilder,
    (
      ProjectCategory,
      BaseReferences<_$AppDatabase, $ProjectCategoriesTable, ProjectCategory>
    ),
    ProjectCategory,
    PrefetchHooks Function()>;
typedef $$TaskDependenciesTableCreateCompanionBuilder
    = TaskDependenciesCompanion Function({
  required String dependentTaskId,
  required String prerequisiteTaskId,
  Value<int> rowid,
});
typedef $$TaskDependenciesTableUpdateCompanionBuilder
    = TaskDependenciesCompanion Function({
  Value<String> dependentTaskId,
  Value<String> prerequisiteTaskId,
  Value<int> rowid,
});

class $$TaskDependenciesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dependentTaskId => $composableBuilder(
      column: $table.dependentTaskId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prerequisiteTaskId => $composableBuilder(
      column: $table.prerequisiteTaskId,
      builder: (column) => ColumnFilters(column));
}

class $$TaskDependenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dependentTaskId => $composableBuilder(
      column: $table.dependentTaskId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prerequisiteTaskId => $composableBuilder(
      column: $table.prerequisiteTaskId,
      builder: (column) => ColumnOrderings(column));
}

class $$TaskDependenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dependentTaskId => $composableBuilder(
      column: $table.dependentTaskId, builder: (column) => column);

  GeneratedColumn<String> get prerequisiteTaskId => $composableBuilder(
      column: $table.prerequisiteTaskId, builder: (column) => column);
}

class $$TaskDependenciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskDependenciesTable,
    TaskDependency,
    $$TaskDependenciesTableFilterComposer,
    $$TaskDependenciesTableOrderingComposer,
    $$TaskDependenciesTableAnnotationComposer,
    $$TaskDependenciesTableCreateCompanionBuilder,
    $$TaskDependenciesTableUpdateCompanionBuilder,
    (
      TaskDependency,
      BaseReferences<_$AppDatabase, $TaskDependenciesTable, TaskDependency>
    ),
    TaskDependency,
    PrefetchHooks Function()> {
  $$TaskDependenciesTableTableManager(
      _$AppDatabase db, $TaskDependenciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskDependenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskDependenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskDependenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dependentTaskId = const Value.absent(),
            Value<String> prerequisiteTaskId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskDependenciesCompanion(
            dependentTaskId: dependentTaskId,
            prerequisiteTaskId: prerequisiteTaskId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dependentTaskId,
            required String prerequisiteTaskId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskDependenciesCompanion.insert(
            dependentTaskId: dependentTaskId,
            prerequisiteTaskId: prerequisiteTaskId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaskDependenciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskDependenciesTable,
    TaskDependency,
    $$TaskDependenciesTableFilterComposer,
    $$TaskDependenciesTableOrderingComposer,
    $$TaskDependenciesTableAnnotationComposer,
    $$TaskDependenciesTableCreateCompanionBuilder,
    $$TaskDependenciesTableUpdateCompanionBuilder,
    (
      TaskDependency,
      BaseReferences<_$AppDatabase, $TaskDependenciesTable, TaskDependency>
    ),
    TaskDependency,
    PrefetchHooks Function()>;
typedef $$TaskTemplatesTableCreateCompanionBuilder = TaskTemplatesCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String titleTemplate,
  Value<String?> descriptionTemplate,
  required int priority,
  required String tags,
  required String subTaskTemplates,
  Value<String?> locationTrigger,
  Value<String?> projectId,
  Value<int?> estimatedDuration,
  required String metadata,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> usageCount,
  Value<bool> isFavorite,
  Value<String?> category,
  Value<int?> recurrenceType,
  Value<int?> recurrenceInterval,
  Value<String?> recurrenceDaysOfWeek,
  Value<DateTime?> recurrenceEndDate,
  Value<int?> recurrenceMaxOccurrences,
  Value<int> rowid,
});
typedef $$TaskTemplatesTableUpdateCompanionBuilder = TaskTemplatesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> titleTemplate,
  Value<String?> descriptionTemplate,
  Value<int> priority,
  Value<String> tags,
  Value<String> subTaskTemplates,
  Value<String?> locationTrigger,
  Value<String?> projectId,
  Value<int?> estimatedDuration,
  Value<String> metadata,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> usageCount,
  Value<bool> isFavorite,
  Value<String?> category,
  Value<int?> recurrenceType,
  Value<int?> recurrenceInterval,
  Value<String?> recurrenceDaysOfWeek,
  Value<DateTime?> recurrenceEndDate,
  Value<int?> recurrenceMaxOccurrences,
  Value<int> rowid,
});

class $$TaskTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskTemplatesTable> {
  $$TaskTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleTemplate => $composableBuilder(
      column: $table.titleTemplate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionTemplate => $composableBuilder(
      column: $table.descriptionTemplate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subTaskTemplates => $composableBuilder(
      column: $table.subTaskTemplates,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationTrigger => $composableBuilder(
      column: $table.locationTrigger,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
      column: $table.recurrenceInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceDaysOfWeek => $composableBuilder(
      column: $table.recurrenceDaysOfWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recurrenceMaxOccurrences => $composableBuilder(
      column: $table.recurrenceMaxOccurrences,
      builder: (column) => ColumnFilters(column));
}

class $$TaskTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskTemplatesTable> {
  $$TaskTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleTemplate => $composableBuilder(
      column: $table.titleTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionTemplate => $composableBuilder(
      column: $table.descriptionTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subTaskTemplates => $composableBuilder(
      column: $table.subTaskTemplates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationTrigger => $composableBuilder(
      column: $table.locationTrigger,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
      column: $table.recurrenceInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceDaysOfWeek => $composableBuilder(
      column: $table.recurrenceDaysOfWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recurrenceMaxOccurrences => $composableBuilder(
      column: $table.recurrenceMaxOccurrences,
      builder: (column) => ColumnOrderings(column));
}

class $$TaskTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTemplatesTable> {
  $$TaskTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get titleTemplate => $composableBuilder(
      column: $table.titleTemplate, builder: (column) => column);

  GeneratedColumn<String> get descriptionTemplate => $composableBuilder(
      column: $table.descriptionTemplate, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get subTaskTemplates => $composableBuilder(
      column: $table.subTaskTemplates, builder: (column) => column);

  GeneratedColumn<String> get locationTrigger => $composableBuilder(
      column: $table.locationTrigger, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get estimatedDuration => $composableBuilder(
      column: $table.estimatedDuration, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get recurrenceType => $composableBuilder(
      column: $table.recurrenceType, builder: (column) => column);

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
      column: $table.recurrenceInterval, builder: (column) => column);

  GeneratedColumn<String> get recurrenceDaysOfWeek => $composableBuilder(
      column: $table.recurrenceDaysOfWeek, builder: (column) => column);

  GeneratedColumn<DateTime> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate, builder: (column) => column);

  GeneratedColumn<int> get recurrenceMaxOccurrences => $composableBuilder(
      column: $table.recurrenceMaxOccurrences, builder: (column) => column);
}

class $$TaskTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskTemplatesTable,
    TaskTemplate,
    $$TaskTemplatesTableFilterComposer,
    $$TaskTemplatesTableOrderingComposer,
    $$TaskTemplatesTableAnnotationComposer,
    $$TaskTemplatesTableCreateCompanionBuilder,
    $$TaskTemplatesTableUpdateCompanionBuilder,
    (
      TaskTemplate,
      BaseReferences<_$AppDatabase, $TaskTemplatesTable, TaskTemplate>
    ),
    TaskTemplate,
    PrefetchHooks Function()> {
  $$TaskTemplatesTableTableManager(_$AppDatabase db, $TaskTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> titleTemplate = const Value.absent(),
            Value<String?> descriptionTemplate = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> subTaskTemplates = const Value.absent(),
            Value<String?> locationTrigger = const Value.absent(),
            Value<String?> projectId = const Value.absent(),
            Value<int?> estimatedDuration = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int?> recurrenceType = const Value.absent(),
            Value<int?> recurrenceInterval = const Value.absent(),
            Value<String?> recurrenceDaysOfWeek = const Value.absent(),
            Value<DateTime?> recurrenceEndDate = const Value.absent(),
            Value<int?> recurrenceMaxOccurrences = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplatesCompanion(
            id: id,
            name: name,
            description: description,
            titleTemplate: titleTemplate,
            descriptionTemplate: descriptionTemplate,
            priority: priority,
            tags: tags,
            subTaskTemplates: subTaskTemplates,
            locationTrigger: locationTrigger,
            projectId: projectId,
            estimatedDuration: estimatedDuration,
            metadata: metadata,
            createdAt: createdAt,
            updatedAt: updatedAt,
            usageCount: usageCount,
            isFavorite: isFavorite,
            category: category,
            recurrenceType: recurrenceType,
            recurrenceInterval: recurrenceInterval,
            recurrenceDaysOfWeek: recurrenceDaysOfWeek,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceMaxOccurrences: recurrenceMaxOccurrences,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String titleTemplate,
            Value<String?> descriptionTemplate = const Value.absent(),
            required int priority,
            required String tags,
            required String subTaskTemplates,
            Value<String?> locationTrigger = const Value.absent(),
            Value<String?> projectId = const Value.absent(),
            Value<int?> estimatedDuration = const Value.absent(),
            required String metadata,
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int?> recurrenceType = const Value.absent(),
            Value<int?> recurrenceInterval = const Value.absent(),
            Value<String?> recurrenceDaysOfWeek = const Value.absent(),
            Value<DateTime?> recurrenceEndDate = const Value.absent(),
            Value<int?> recurrenceMaxOccurrences = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTemplatesCompanion.insert(
            id: id,
            name: name,
            description: description,
            titleTemplate: titleTemplate,
            descriptionTemplate: descriptionTemplate,
            priority: priority,
            tags: tags,
            subTaskTemplates: subTaskTemplates,
            locationTrigger: locationTrigger,
            projectId: projectId,
            estimatedDuration: estimatedDuration,
            metadata: metadata,
            createdAt: createdAt,
            updatedAt: updatedAt,
            usageCount: usageCount,
            isFavorite: isFavorite,
            category: category,
            recurrenceType: recurrenceType,
            recurrenceInterval: recurrenceInterval,
            recurrenceDaysOfWeek: recurrenceDaysOfWeek,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceMaxOccurrences: recurrenceMaxOccurrences,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaskTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskTemplatesTable,
    TaskTemplate,
    $$TaskTemplatesTableFilterComposer,
    $$TaskTemplatesTableOrderingComposer,
    $$TaskTemplatesTableAnnotationComposer,
    $$TaskTemplatesTableCreateCompanionBuilder,
    $$TaskTemplatesTableUpdateCompanionBuilder,
    (
      TaskTemplate,
      BaseReferences<_$AppDatabase, $TaskTemplatesTable, TaskTemplate>
    ),
    TaskTemplate,
    PrefetchHooks Function()>;
typedef $$ProjectTemplatesTableCreateCompanionBuilder
    = ProjectTemplatesCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> shortDescription,
  required int type,
  Value<String?> categoryId,
  required String industryTags,
  Value<int> difficultyLevel,
  Value<int?> estimatedHours,
  required String projectNameTemplate,
  Value<String?> projectDescriptionTemplate,
  Value<String> defaultColor,
  Value<String?> projectCategoryId,
  Value<int?> deadlineOffsetDays,
  required String taskTemplates,
  required String variables,
  required String wizardSteps,
  required String taskDependencies,
  required String milestones,
  required String resourceTemplates,
  required String metadata,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> createdBy,
  Value<bool> isSystemTemplate,
  Value<bool> isPublished,
  Value<String> version,
  required String usageStats,
  Value<String?> rating,
  required String previewImages,
  required String tags,
  required String supportedLocales,
  Value<bool> isPremium,
  required String sizeEstimate,
  Value<int> rowid,
});
typedef $$ProjectTemplatesTableUpdateCompanionBuilder
    = ProjectTemplatesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> shortDescription,
  Value<int> type,
  Value<String?> categoryId,
  Value<String> industryTags,
  Value<int> difficultyLevel,
  Value<int?> estimatedHours,
  Value<String> projectNameTemplate,
  Value<String?> projectDescriptionTemplate,
  Value<String> defaultColor,
  Value<String?> projectCategoryId,
  Value<int?> deadlineOffsetDays,
  Value<String> taskTemplates,
  Value<String> variables,
  Value<String> wizardSteps,
  Value<String> taskDependencies,
  Value<String> milestones,
  Value<String> resourceTemplates,
  Value<String> metadata,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> createdBy,
  Value<bool> isSystemTemplate,
  Value<bool> isPublished,
  Value<String> version,
  Value<String> usageStats,
  Value<String?> rating,
  Value<String> previewImages,
  Value<String> tags,
  Value<String> supportedLocales,
  Value<bool> isPremium,
  Value<String> sizeEstimate,
  Value<int> rowid,
});

class $$ProjectTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTemplatesTable> {
  $$ProjectTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get industryTags => $composableBuilder(
      column: $table.industryTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectNameTemplate => $composableBuilder(
      column: $table.projectNameTemplate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectDescriptionTemplate => $composableBuilder(
      column: $table.projectDescriptionTemplate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultColor => $composableBuilder(
      column: $table.defaultColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectCategoryId => $composableBuilder(
      column: $table.projectCategoryId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deadlineOffsetDays => $composableBuilder(
      column: $table.deadlineOffsetDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskTemplates => $composableBuilder(
      column: $table.taskTemplates, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variables => $composableBuilder(
      column: $table.variables, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wizardSteps => $composableBuilder(
      column: $table.wizardSteps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskDependencies => $composableBuilder(
      column: $table.taskDependencies,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get milestones => $composableBuilder(
      column: $table.milestones, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resourceTemplates => $composableBuilder(
      column: $table.resourceTemplates,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystemTemplate => $composableBuilder(
      column: $table.isSystemTemplate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usageStats => $composableBuilder(
      column: $table.usageStats, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewImages => $composableBuilder(
      column: $table.previewImages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supportedLocales => $composableBuilder(
      column: $table.supportedLocales,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPremium => $composableBuilder(
      column: $table.isPremium, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sizeEstimate => $composableBuilder(
      column: $table.sizeEstimate, builder: (column) => ColumnFilters(column));
}

class $$ProjectTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTemplatesTable> {
  $$ProjectTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get industryTags => $composableBuilder(
      column: $table.industryTags,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectNameTemplate => $composableBuilder(
      column: $table.projectNameTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectDescriptionTemplate => $composableBuilder(
      column: $table.projectDescriptionTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultColor => $composableBuilder(
      column: $table.defaultColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectCategoryId => $composableBuilder(
      column: $table.projectCategoryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deadlineOffsetDays => $composableBuilder(
      column: $table.deadlineOffsetDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskTemplates => $composableBuilder(
      column: $table.taskTemplates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variables => $composableBuilder(
      column: $table.variables, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wizardSteps => $composableBuilder(
      column: $table.wizardSteps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskDependencies => $composableBuilder(
      column: $table.taskDependencies,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get milestones => $composableBuilder(
      column: $table.milestones, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resourceTemplates => $composableBuilder(
      column: $table.resourceTemplates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystemTemplate => $composableBuilder(
      column: $table.isSystemTemplate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usageStats => $composableBuilder(
      column: $table.usageStats, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewImages => $composableBuilder(
      column: $table.previewImages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supportedLocales => $composableBuilder(
      column: $table.supportedLocales,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPremium => $composableBuilder(
      column: $table.isPremium, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sizeEstimate => $composableBuilder(
      column: $table.sizeEstimate,
      builder: (column) => ColumnOrderings(column));
}

class $$ProjectTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTemplatesTable> {
  $$ProjectTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get industryTags => $composableBuilder(
      column: $table.industryTags, builder: (column) => column);

  GeneratedColumn<int> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel, builder: (column) => column);

  GeneratedColumn<int> get estimatedHours => $composableBuilder(
      column: $table.estimatedHours, builder: (column) => column);

  GeneratedColumn<String> get projectNameTemplate => $composableBuilder(
      column: $table.projectNameTemplate, builder: (column) => column);

  GeneratedColumn<String> get projectDescriptionTemplate => $composableBuilder(
      column: $table.projectDescriptionTemplate, builder: (column) => column);

  GeneratedColumn<String> get defaultColor => $composableBuilder(
      column: $table.defaultColor, builder: (column) => column);

  GeneratedColumn<String> get projectCategoryId => $composableBuilder(
      column: $table.projectCategoryId, builder: (column) => column);

  GeneratedColumn<int> get deadlineOffsetDays => $composableBuilder(
      column: $table.deadlineOffsetDays, builder: (column) => column);

  GeneratedColumn<String> get taskTemplates => $composableBuilder(
      column: $table.taskTemplates, builder: (column) => column);

  GeneratedColumn<String> get variables =>
      $composableBuilder(column: $table.variables, builder: (column) => column);

  GeneratedColumn<String> get wizardSteps => $composableBuilder(
      column: $table.wizardSteps, builder: (column) => column);

  GeneratedColumn<String> get taskDependencies => $composableBuilder(
      column: $table.taskDependencies, builder: (column) => column);

  GeneratedColumn<String> get milestones => $composableBuilder(
      column: $table.milestones, builder: (column) => column);

  GeneratedColumn<String> get resourceTemplates => $composableBuilder(
      column: $table.resourceTemplates, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<bool> get isSystemTemplate => $composableBuilder(
      column: $table.isSystemTemplate, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get usageStats => $composableBuilder(
      column: $table.usageStats, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get previewImages => $composableBuilder(
      column: $table.previewImages, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get supportedLocales => $composableBuilder(
      column: $table.supportedLocales, builder: (column) => column);

  GeneratedColumn<bool> get isPremium =>
      $composableBuilder(column: $table.isPremium, builder: (column) => column);

  GeneratedColumn<String> get sizeEstimate => $composableBuilder(
      column: $table.sizeEstimate, builder: (column) => column);
}

class $$ProjectTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTemplatesTable,
    ProjectTemplate,
    $$ProjectTemplatesTableFilterComposer,
    $$ProjectTemplatesTableOrderingComposer,
    $$ProjectTemplatesTableAnnotationComposer,
    $$ProjectTemplatesTableCreateCompanionBuilder,
    $$ProjectTemplatesTableUpdateCompanionBuilder,
    (
      ProjectTemplate,
      BaseReferences<_$AppDatabase, $ProjectTemplatesTable, ProjectTemplate>
    ),
    ProjectTemplate,
    PrefetchHooks Function()> {
  $$ProjectTemplatesTableTableManager(
      _$AppDatabase db, $ProjectTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> shortDescription = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> industryTags = const Value.absent(),
            Value<int> difficultyLevel = const Value.absent(),
            Value<int?> estimatedHours = const Value.absent(),
            Value<String> projectNameTemplate = const Value.absent(),
            Value<String?> projectDescriptionTemplate = const Value.absent(),
            Value<String> defaultColor = const Value.absent(),
            Value<String?> projectCategoryId = const Value.absent(),
            Value<int?> deadlineOffsetDays = const Value.absent(),
            Value<String> taskTemplates = const Value.absent(),
            Value<String> variables = const Value.absent(),
            Value<String> wizardSteps = const Value.absent(),
            Value<String> taskDependencies = const Value.absent(),
            Value<String> milestones = const Value.absent(),
            Value<String> resourceTemplates = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<bool> isSystemTemplate = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<String> version = const Value.absent(),
            Value<String> usageStats = const Value.absent(),
            Value<String?> rating = const Value.absent(),
            Value<String> previewImages = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> supportedLocales = const Value.absent(),
            Value<bool> isPremium = const Value.absent(),
            Value<String> sizeEstimate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplatesCompanion(
            id: id,
            name: name,
            description: description,
            shortDescription: shortDescription,
            type: type,
            categoryId: categoryId,
            industryTags: industryTags,
            difficultyLevel: difficultyLevel,
            estimatedHours: estimatedHours,
            projectNameTemplate: projectNameTemplate,
            projectDescriptionTemplate: projectDescriptionTemplate,
            defaultColor: defaultColor,
            projectCategoryId: projectCategoryId,
            deadlineOffsetDays: deadlineOffsetDays,
            taskTemplates: taskTemplates,
            variables: variables,
            wizardSteps: wizardSteps,
            taskDependencies: taskDependencies,
            milestones: milestones,
            resourceTemplates: resourceTemplates,
            metadata: metadata,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdBy: createdBy,
            isSystemTemplate: isSystemTemplate,
            isPublished: isPublished,
            version: version,
            usageStats: usageStats,
            rating: rating,
            previewImages: previewImages,
            tags: tags,
            supportedLocales: supportedLocales,
            isPremium: isPremium,
            sizeEstimate: sizeEstimate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> shortDescription = const Value.absent(),
            required int type,
            Value<String?> categoryId = const Value.absent(),
            required String industryTags,
            Value<int> difficultyLevel = const Value.absent(),
            Value<int?> estimatedHours = const Value.absent(),
            required String projectNameTemplate,
            Value<String?> projectDescriptionTemplate = const Value.absent(),
            Value<String> defaultColor = const Value.absent(),
            Value<String?> projectCategoryId = const Value.absent(),
            Value<int?> deadlineOffsetDays = const Value.absent(),
            required String taskTemplates,
            required String variables,
            required String wizardSteps,
            required String taskDependencies,
            required String milestones,
            required String resourceTemplates,
            required String metadata,
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<bool> isSystemTemplate = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<String> version = const Value.absent(),
            required String usageStats,
            Value<String?> rating = const Value.absent(),
            required String previewImages,
            required String tags,
            required String supportedLocales,
            Value<bool> isPremium = const Value.absent(),
            required String sizeEstimate,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplatesCompanion.insert(
            id: id,
            name: name,
            description: description,
            shortDescription: shortDescription,
            type: type,
            categoryId: categoryId,
            industryTags: industryTags,
            difficultyLevel: difficultyLevel,
            estimatedHours: estimatedHours,
            projectNameTemplate: projectNameTemplate,
            projectDescriptionTemplate: projectDescriptionTemplate,
            defaultColor: defaultColor,
            projectCategoryId: projectCategoryId,
            deadlineOffsetDays: deadlineOffsetDays,
            taskTemplates: taskTemplates,
            variables: variables,
            wizardSteps: wizardSteps,
            taskDependencies: taskDependencies,
            milestones: milestones,
            resourceTemplates: resourceTemplates,
            metadata: metadata,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdBy: createdBy,
            isSystemTemplate: isSystemTemplate,
            isPublished: isPublished,
            version: version,
            usageStats: usageStats,
            rating: rating,
            previewImages: previewImages,
            tags: tags,
            supportedLocales: supportedLocales,
            isPremium: isPremium,
            sizeEstimate: sizeEstimate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectTemplatesTable,
    ProjectTemplate,
    $$ProjectTemplatesTableFilterComposer,
    $$ProjectTemplatesTableOrderingComposer,
    $$ProjectTemplatesTableAnnotationComposer,
    $$ProjectTemplatesTableCreateCompanionBuilder,
    $$ProjectTemplatesTableUpdateCompanionBuilder,
    (
      ProjectTemplate,
      BaseReferences<_$AppDatabase, $ProjectTemplatesTable, ProjectTemplate>
    ),
    ProjectTemplate,
    PrefetchHooks Function()>;
typedef $$ProjectTemplateVariablesTableCreateCompanionBuilder
    = ProjectTemplateVariablesCompanion Function({
  required String id,
  required String templateId,
  required String variableKey,
  required String displayName,
  required int type,
  Value<String?> description,
  Value<bool> isRequired,
  Value<String?> defaultValue,
  required String options,
  Value<String?> validationPattern,
  Value<String?> validationError,
  Value<String?> minValue,
  Value<String?> maxValue,
  Value<bool> isConditional,
  required String dependentVariables,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$ProjectTemplateVariablesTableUpdateCompanionBuilder
    = ProjectTemplateVariablesCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<String> variableKey,
  Value<String> displayName,
  Value<int> type,
  Value<String?> description,
  Value<bool> isRequired,
  Value<String?> defaultValue,
  Value<String> options,
  Value<String?> validationPattern,
  Value<String?> validationError,
  Value<String?> minValue,
  Value<String?> maxValue,
  Value<bool> isConditional,
  Value<String> dependentVariables,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$ProjectTemplateVariablesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTemplateVariablesTable> {
  $$ProjectTemplateVariablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variableKey => $composableBuilder(
      column: $table.variableKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultValue => $composableBuilder(
      column: $table.defaultValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validationPattern => $composableBuilder(
      column: $table.validationPattern,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validationError => $composableBuilder(
      column: $table.validationError,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get minValue => $composableBuilder(
      column: $table.minValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get maxValue => $composableBuilder(
      column: $table.maxValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isConditional => $composableBuilder(
      column: $table.isConditional, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependentVariables => $composableBuilder(
      column: $table.dependentVariables,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$ProjectTemplateVariablesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTemplateVariablesTable> {
  $$ProjectTemplateVariablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variableKey => $composableBuilder(
      column: $table.variableKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultValue => $composableBuilder(
      column: $table.defaultValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validationPattern => $composableBuilder(
      column: $table.validationPattern,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validationError => $composableBuilder(
      column: $table.validationError,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get minValue => $composableBuilder(
      column: $table.minValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get maxValue => $composableBuilder(
      column: $table.maxValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isConditional => $composableBuilder(
      column: $table.isConditional,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependentVariables => $composableBuilder(
      column: $table.dependentVariables,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$ProjectTemplateVariablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTemplateVariablesTable> {
  $$ProjectTemplateVariablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get variableKey => $composableBuilder(
      column: $table.variableKey, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => column);

  GeneratedColumn<String> get defaultValue => $composableBuilder(
      column: $table.defaultValue, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<String> get validationPattern => $composableBuilder(
      column: $table.validationPattern, builder: (column) => column);

  GeneratedColumn<String> get validationError => $composableBuilder(
      column: $table.validationError, builder: (column) => column);

  GeneratedColumn<String> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<String> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<bool> get isConditional => $composableBuilder(
      column: $table.isConditional, builder: (column) => column);

  GeneratedColumn<String> get dependentVariables => $composableBuilder(
      column: $table.dependentVariables, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ProjectTemplateVariablesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTemplateVariablesTable,
    ProjectTemplateVariable,
    $$ProjectTemplateVariablesTableFilterComposer,
    $$ProjectTemplateVariablesTableOrderingComposer,
    $$ProjectTemplateVariablesTableAnnotationComposer,
    $$ProjectTemplateVariablesTableCreateCompanionBuilder,
    $$ProjectTemplateVariablesTableUpdateCompanionBuilder,
    (
      ProjectTemplateVariable,
      BaseReferences<_$AppDatabase, $ProjectTemplateVariablesTable,
          ProjectTemplateVariable>
    ),
    ProjectTemplateVariable,
    PrefetchHooks Function()> {
  $$ProjectTemplateVariablesTableTableManager(
      _$AppDatabase db, $ProjectTemplateVariablesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTemplateVariablesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTemplateVariablesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTemplateVariablesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> variableKey = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<String?> defaultValue = const Value.absent(),
            Value<String> options = const Value.absent(),
            Value<String?> validationPattern = const Value.absent(),
            Value<String?> validationError = const Value.absent(),
            Value<String?> minValue = const Value.absent(),
            Value<String?> maxValue = const Value.absent(),
            Value<bool> isConditional = const Value.absent(),
            Value<String> dependentVariables = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateVariablesCompanion(
            id: id,
            templateId: templateId,
            variableKey: variableKey,
            displayName: displayName,
            type: type,
            description: description,
            isRequired: isRequired,
            defaultValue: defaultValue,
            options: options,
            validationPattern: validationPattern,
            validationError: validationError,
            minValue: minValue,
            maxValue: maxValue,
            isConditional: isConditional,
            dependentVariables: dependentVariables,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required String variableKey,
            required String displayName,
            required int type,
            Value<String?> description = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<String?> defaultValue = const Value.absent(),
            required String options,
            Value<String?> validationPattern = const Value.absent(),
            Value<String?> validationError = const Value.absent(),
            Value<String?> minValue = const Value.absent(),
            Value<String?> maxValue = const Value.absent(),
            Value<bool> isConditional = const Value.absent(),
            required String dependentVariables,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateVariablesCompanion.insert(
            id: id,
            templateId: templateId,
            variableKey: variableKey,
            displayName: displayName,
            type: type,
            description: description,
            isRequired: isRequired,
            defaultValue: defaultValue,
            options: options,
            validationPattern: validationPattern,
            validationError: validationError,
            minValue: minValue,
            maxValue: maxValue,
            isConditional: isConditional,
            dependentVariables: dependentVariables,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectTemplateVariablesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ProjectTemplateVariablesTable,
        ProjectTemplateVariable,
        $$ProjectTemplateVariablesTableFilterComposer,
        $$ProjectTemplateVariablesTableOrderingComposer,
        $$ProjectTemplateVariablesTableAnnotationComposer,
        $$ProjectTemplateVariablesTableCreateCompanionBuilder,
        $$ProjectTemplateVariablesTableUpdateCompanionBuilder,
        (
          ProjectTemplateVariable,
          BaseReferences<_$AppDatabase, $ProjectTemplateVariablesTable,
              ProjectTemplateVariable>
        ),
        ProjectTemplateVariable,
        PrefetchHooks Function()>;
typedef $$ProjectTemplateWizardStepsTableCreateCompanionBuilder
    = ProjectTemplateWizardStepsCompanion Function({
  required String id,
  required String templateId,
  required String title,
  Value<String?> description,
  required String variableKeys,
  Value<String?> showCondition,
  required int stepOrder,
  Value<bool> isOptional,
  Value<String?> iconName,
  Value<int> rowid,
});
typedef $$ProjectTemplateWizardStepsTableUpdateCompanionBuilder
    = ProjectTemplateWizardStepsCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<String> title,
  Value<String?> description,
  Value<String> variableKeys,
  Value<String?> showCondition,
  Value<int> stepOrder,
  Value<bool> isOptional,
  Value<String?> iconName,
  Value<int> rowid,
});

class $$ProjectTemplateWizardStepsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTemplateWizardStepsTable> {
  $$ProjectTemplateWizardStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variableKeys => $composableBuilder(
      column: $table.variableKeys, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get showCondition => $composableBuilder(
      column: $table.showCondition, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepOrder => $composableBuilder(
      column: $table.stepOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOptional => $composableBuilder(
      column: $table.isOptional, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));
}

class $$ProjectTemplateWizardStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTemplateWizardStepsTable> {
  $$ProjectTemplateWizardStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variableKeys => $composableBuilder(
      column: $table.variableKeys,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get showCondition => $composableBuilder(
      column: $table.showCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepOrder => $composableBuilder(
      column: $table.stepOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOptional => $composableBuilder(
      column: $table.isOptional, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));
}

class $$ProjectTemplateWizardStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTemplateWizardStepsTable> {
  $$ProjectTemplateWizardStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get variableKeys => $composableBuilder(
      column: $table.variableKeys, builder: (column) => column);

  GeneratedColumn<String> get showCondition => $composableBuilder(
      column: $table.showCondition, builder: (column) => column);

  GeneratedColumn<int> get stepOrder =>
      $composableBuilder(column: $table.stepOrder, builder: (column) => column);

  GeneratedColumn<bool> get isOptional => $composableBuilder(
      column: $table.isOptional, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);
}

class $$ProjectTemplateWizardStepsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTemplateWizardStepsTable,
    ProjectTemplateWizardStep,
    $$ProjectTemplateWizardStepsTableFilterComposer,
    $$ProjectTemplateWizardStepsTableOrderingComposer,
    $$ProjectTemplateWizardStepsTableAnnotationComposer,
    $$ProjectTemplateWizardStepsTableCreateCompanionBuilder,
    $$ProjectTemplateWizardStepsTableUpdateCompanionBuilder,
    (
      ProjectTemplateWizardStep,
      BaseReferences<_$AppDatabase, $ProjectTemplateWizardStepsTable,
          ProjectTemplateWizardStep>
    ),
    ProjectTemplateWizardStep,
    PrefetchHooks Function()> {
  $$ProjectTemplateWizardStepsTableTableManager(
      _$AppDatabase db, $ProjectTemplateWizardStepsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTemplateWizardStepsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTemplateWizardStepsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTemplateWizardStepsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> variableKeys = const Value.absent(),
            Value<String?> showCondition = const Value.absent(),
            Value<int> stepOrder = const Value.absent(),
            Value<bool> isOptional = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateWizardStepsCompanion(
            id: id,
            templateId: templateId,
            title: title,
            description: description,
            variableKeys: variableKeys,
            showCondition: showCondition,
            stepOrder: stepOrder,
            isOptional: isOptional,
            iconName: iconName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required String title,
            Value<String?> description = const Value.absent(),
            required String variableKeys,
            Value<String?> showCondition = const Value.absent(),
            required int stepOrder,
            Value<bool> isOptional = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateWizardStepsCompanion.insert(
            id: id,
            templateId: templateId,
            title: title,
            description: description,
            variableKeys: variableKeys,
            showCondition: showCondition,
            stepOrder: stepOrder,
            isOptional: isOptional,
            iconName: iconName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectTemplateWizardStepsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ProjectTemplateWizardStepsTable,
        ProjectTemplateWizardStep,
        $$ProjectTemplateWizardStepsTableFilterComposer,
        $$ProjectTemplateWizardStepsTableOrderingComposer,
        $$ProjectTemplateWizardStepsTableAnnotationComposer,
        $$ProjectTemplateWizardStepsTableCreateCompanionBuilder,
        $$ProjectTemplateWizardStepsTableUpdateCompanionBuilder,
        (
          ProjectTemplateWizardStep,
          BaseReferences<_$AppDatabase, $ProjectTemplateWizardStepsTable,
              ProjectTemplateWizardStep>
        ),
        ProjectTemplateWizardStep,
        PrefetchHooks Function()>;
typedef $$ProjectTemplateMilestonesTableCreateCompanionBuilder
    = ProjectTemplateMilestonesCompanion Function({
  required String id,
  required String templateId,
  required String name,
  Value<String?> description,
  required int dayOffset,
  required String requiredTaskIds,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$ProjectTemplateMilestonesTableUpdateCompanionBuilder
    = ProjectTemplateMilestonesCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<String> name,
  Value<String?> description,
  Value<int> dayOffset,
  Value<String> requiredTaskIds,
  Value<String?> iconName,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$ProjectTemplateMilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTemplateMilestonesTable> {
  $$ProjectTemplateMilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOffset => $composableBuilder(
      column: $table.dayOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requiredTaskIds => $composableBuilder(
      column: $table.requiredTaskIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$ProjectTemplateMilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTemplateMilestonesTable> {
  $$ProjectTemplateMilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOffset => $composableBuilder(
      column: $table.dayOffset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requiredTaskIds => $composableBuilder(
      column: $table.requiredTaskIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$ProjectTemplateMilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTemplateMilestonesTable> {
  $$ProjectTemplateMilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get dayOffset =>
      $composableBuilder(column: $table.dayOffset, builder: (column) => column);

  GeneratedColumn<String> get requiredTaskIds => $composableBuilder(
      column: $table.requiredTaskIds, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ProjectTemplateMilestonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTemplateMilestonesTable,
    ProjectTemplateMilestone,
    $$ProjectTemplateMilestonesTableFilterComposer,
    $$ProjectTemplateMilestonesTableOrderingComposer,
    $$ProjectTemplateMilestonesTableAnnotationComposer,
    $$ProjectTemplateMilestonesTableCreateCompanionBuilder,
    $$ProjectTemplateMilestonesTableUpdateCompanionBuilder,
    (
      ProjectTemplateMilestone,
      BaseReferences<_$AppDatabase, $ProjectTemplateMilestonesTable,
          ProjectTemplateMilestone>
    ),
    ProjectTemplateMilestone,
    PrefetchHooks Function()> {
  $$ProjectTemplateMilestonesTableTableManager(
      _$AppDatabase db, $ProjectTemplateMilestonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTemplateMilestonesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTemplateMilestonesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTemplateMilestonesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> dayOffset = const Value.absent(),
            Value<String> requiredTaskIds = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateMilestonesCompanion(
            id: id,
            templateId: templateId,
            name: name,
            description: description,
            dayOffset: dayOffset,
            requiredTaskIds: requiredTaskIds,
            iconName: iconName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required String name,
            Value<String?> description = const Value.absent(),
            required int dayOffset,
            required String requiredTaskIds,
            Value<String?> iconName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateMilestonesCompanion.insert(
            id: id,
            templateId: templateId,
            name: name,
            description: description,
            dayOffset: dayOffset,
            requiredTaskIds: requiredTaskIds,
            iconName: iconName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectTemplateMilestonesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ProjectTemplateMilestonesTable,
        ProjectTemplateMilestone,
        $$ProjectTemplateMilestonesTableFilterComposer,
        $$ProjectTemplateMilestonesTableOrderingComposer,
        $$ProjectTemplateMilestonesTableAnnotationComposer,
        $$ProjectTemplateMilestonesTableCreateCompanionBuilder,
        $$ProjectTemplateMilestonesTableUpdateCompanionBuilder,
        (
          ProjectTemplateMilestone,
          BaseReferences<_$AppDatabase, $ProjectTemplateMilestonesTable,
              ProjectTemplateMilestone>
        ),
        ProjectTemplateMilestone,
        PrefetchHooks Function()>;
typedef $$ProjectTemplateTaskTemplatesTableCreateCompanionBuilder
    = ProjectTemplateTaskTemplatesCompanion Function({
  required String projectTemplateId,
  required String taskTemplateId,
  Value<int> sortOrder,
  required String taskDependencies,
  Value<int> rowid,
});
typedef $$ProjectTemplateTaskTemplatesTableUpdateCompanionBuilder
    = ProjectTemplateTaskTemplatesCompanion Function({
  Value<String> projectTemplateId,
  Value<String> taskTemplateId,
  Value<int> sortOrder,
  Value<String> taskDependencies,
  Value<int> rowid,
});

class $$ProjectTemplateTaskTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectTemplateTaskTemplatesTable> {
  $$ProjectTemplateTaskTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectTemplateId => $composableBuilder(
      column: $table.projectTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskTemplateId => $composableBuilder(
      column: $table.taskTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskDependencies => $composableBuilder(
      column: $table.taskDependencies,
      builder: (column) => ColumnFilters(column));
}

class $$ProjectTemplateTaskTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectTemplateTaskTemplatesTable> {
  $$ProjectTemplateTaskTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectTemplateId => $composableBuilder(
      column: $table.projectTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskTemplateId => $composableBuilder(
      column: $table.taskTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskDependencies => $composableBuilder(
      column: $table.taskDependencies,
      builder: (column) => ColumnOrderings(column));
}

class $$ProjectTemplateTaskTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectTemplateTaskTemplatesTable> {
  $$ProjectTemplateTaskTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectTemplateId => $composableBuilder(
      column: $table.projectTemplateId, builder: (column) => column);

  GeneratedColumn<String> get taskTemplateId => $composableBuilder(
      column: $table.taskTemplateId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get taskDependencies => $composableBuilder(
      column: $table.taskDependencies, builder: (column) => column);
}

class $$ProjectTemplateTaskTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectTemplateTaskTemplatesTable,
    ProjectTemplateTaskTemplate,
    $$ProjectTemplateTaskTemplatesTableFilterComposer,
    $$ProjectTemplateTaskTemplatesTableOrderingComposer,
    $$ProjectTemplateTaskTemplatesTableAnnotationComposer,
    $$ProjectTemplateTaskTemplatesTableCreateCompanionBuilder,
    $$ProjectTemplateTaskTemplatesTableUpdateCompanionBuilder,
    (
      ProjectTemplateTaskTemplate,
      BaseReferences<_$AppDatabase, $ProjectTemplateTaskTemplatesTable,
          ProjectTemplateTaskTemplate>
    ),
    ProjectTemplateTaskTemplate,
    PrefetchHooks Function()> {
  $$ProjectTemplateTaskTemplatesTableTableManager(
      _$AppDatabase db, $ProjectTemplateTaskTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectTemplateTaskTemplatesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectTemplateTaskTemplatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectTemplateTaskTemplatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> projectTemplateId = const Value.absent(),
            Value<String> taskTemplateId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> taskDependencies = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateTaskTemplatesCompanion(
            projectTemplateId: projectTemplateId,
            taskTemplateId: taskTemplateId,
            sortOrder: sortOrder,
            taskDependencies: taskDependencies,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String projectTemplateId,
            required String taskTemplateId,
            Value<int> sortOrder = const Value.absent(),
            required String taskDependencies,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectTemplateTaskTemplatesCompanion.insert(
            projectTemplateId: projectTemplateId,
            taskTemplateId: taskTemplateId,
            sortOrder: sortOrder,
            taskDependencies: taskDependencies,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectTemplateTaskTemplatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ProjectTemplateTaskTemplatesTable,
        ProjectTemplateTaskTemplate,
        $$ProjectTemplateTaskTemplatesTableFilterComposer,
        $$ProjectTemplateTaskTemplatesTableOrderingComposer,
        $$ProjectTemplateTaskTemplatesTableAnnotationComposer,
        $$ProjectTemplateTaskTemplatesTableCreateCompanionBuilder,
        $$ProjectTemplateTaskTemplatesTableUpdateCompanionBuilder,
        (
          ProjectTemplateTaskTemplate,
          BaseReferences<_$AppDatabase, $ProjectTemplateTaskTemplatesTable,
              ProjectTemplateTaskTemplate>
        ),
        ProjectTemplateTaskTemplate,
        PrefetchHooks Function()>;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  required String id,
  required String firstName,
  Value<String?> lastName,
  Value<String?> profilePicturePath,
  Value<String?> location,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<String> id,
  Value<String> firstName,
  Value<String?> lastName,
  Value<String?> profilePicturePath,
  Value<String?> location,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePicturePath => $composableBuilder(
      column: $table.profilePicturePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePicturePath => $composableBuilder(
      column: $table.profilePicturePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get profilePicturePath => $composableBuilder(
      column: $table.profilePicturePath, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> profilePicturePath = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            firstName: firstName,
            lastName: lastName,
            profilePicturePath: profilePicturePath,
            location: location,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String firstName,
            Value<String?> lastName = const Value.absent(),
            Value<String?> profilePicturePath = const Value.absent(),
            Value<String?> location = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            firstName: firstName,
            lastName: lastName,
            profilePicturePath: profilePicturePath,
            location: location,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubTasksTableTableManager get subTasks =>
      $$SubTasksTableTableManager(_db, _db.subTasks);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db, _db.taskTags);
  $$ProjectTagsTableTableManager get projectTags =>
      $$ProjectTagsTableTableManager(_db, _db.projectTags);
  $$ProjectCategoriesTableTableManager get projectCategories =>
      $$ProjectCategoriesTableTableManager(_db, _db.projectCategories);
  $$TaskDependenciesTableTableManager get taskDependencies =>
      $$TaskDependenciesTableTableManager(_db, _db.taskDependencies);
  $$TaskTemplatesTableTableManager get taskTemplates =>
      $$TaskTemplatesTableTableManager(_db, _db.taskTemplates);
  $$ProjectTemplatesTableTableManager get projectTemplates =>
      $$ProjectTemplatesTableTableManager(_db, _db.projectTemplates);
  $$ProjectTemplateVariablesTableTableManager get projectTemplateVariables =>
      $$ProjectTemplateVariablesTableTableManager(
          _db, _db.projectTemplateVariables);
  $$ProjectTemplateWizardStepsTableTableManager
      get projectTemplateWizardSteps =>
          $$ProjectTemplateWizardStepsTableTableManager(
              _db, _db.projectTemplateWizardSteps);
  $$ProjectTemplateMilestonesTableTableManager get projectTemplateMilestones =>
      $$ProjectTemplateMilestonesTableTableManager(
          _db, _db.projectTemplateMilestones);
  $$ProjectTemplateTaskTemplatesTableTableManager
      get projectTemplateTaskTemplates =>
          $$ProjectTemplateTaskTemplatesTableTableManager(
              _db, _db.projectTemplateTaskTemplates);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
