// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dao.dart';

// ignore_for_file: type=lint
mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProjectsTable get projects => attachedDatabase.projects;
  $TasksTable get tasks => attachedDatabase.tasks;
  $SubTasksTable get subTasks => attachedDatabase.subTasks;
  $TagsTable get tags => attachedDatabase.tags;
  $TaskTagsTable get taskTags => attachedDatabase.taskTags;
  $TaskDependenciesTable get taskDependencies =>
      attachedDatabase.taskDependencies;
}
