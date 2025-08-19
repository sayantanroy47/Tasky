import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_localizations_delegate.dart';

/// App localization strings and formatting utilities
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  // Common strings
  String get appName => _getLocalizedString('app_name');
  String get cancel => _getLocalizedString('cancel');
  String get confirm => _getLocalizedString('confirm');
  String get save => _getLocalizedString('save');
  String get delete => _getLocalizedString('delete');
  String get edit => _getLocalizedString('edit');
  String get add => _getLocalizedString('add');
  String get close => _getLocalizedString('close');
  String get ok => _getLocalizedString('ok');
  String get yes => _getLocalizedString('yes');
  String get no => _getLocalizedString('no');
  String get retry => _getLocalizedString('retry');
  String get loading => _getLocalizedString('loading');
  String get error => _getLocalizedString('error');
  String get success => _getLocalizedString('success');
  String get warning => _getLocalizedString('warning');
  String get info => _getLocalizedString('info');

  // Navigation
  String get home => _getLocalizedString('navigation_home');
  String get calendar => _getLocalizedString('navigation_calendar');
  String get analytics => _getLocalizedString('navigation_analytics');
  String get settings => _getLocalizedString('navigation_settings');
  String get tasks => _getLocalizedString('navigation_tasks');
  String get projects => _getLocalizedString('navigation_projects');

  // Task related
  String get task => _getLocalizedString('task');
  String get tasksPlural => _getLocalizedString('tasks_plural');
  String get createTask => _getLocalizedString('create_task');
  String get editTask => _getLocalizedString('edit_task');
  String get deleteTask => _getLocalizedString('delete_task');
  String get completeTask => _getLocalizedString('complete_task');
  String get taskTitle => _getLocalizedString('task_title');
  String get taskDescription => _getLocalizedString('task_description');
  String get taskDueDate => _getLocalizedString('task_due_date');
  String get taskPriority => _getLocalizedString('task_priority');
  String get taskStatus => _getLocalizedString('task_status');
  String get taskCompleted => _getLocalizedString('task_completed');
  String get taskPending => _getLocalizedString('task_pending');
  String get taskOverdue => _getLocalizedString('task_overdue');

  // Priority levels
  String get priorityLow => _getLocalizedString('priority_low');
  String get priorityMedium => _getLocalizedString('priority_medium');
  String get priorityHigh => _getLocalizedString('priority_high');
  String get priorityUrgent => _getLocalizedString('priority_urgent');

  // Time and dates
  String get today => _getLocalizedString('today');
  String get tomorrow => _getLocalizedString('tomorrow');
  String get yesterday => _getLocalizedString('yesterday');
  String get thisWeek => _getLocalizedString('this_week');
  String get nextWeek => _getLocalizedString('next_week');
  String get thisMonth => _getLocalizedString('this_month');
  String get nextMonth => _getLocalizedString('next_month');

  // Onboarding
  String get onboardingWelcome => _getLocalizedString('onboarding_welcome');
  String get onboardingTitle => _getLocalizedString('onboarding_title');
  String get onboardingSubtitle => _getLocalizedString('onboarding_subtitle');
  String get onboardingNext => _getLocalizedString('onboarding_next');
  String get onboardingSkip => _getLocalizedString('onboarding_skip');
  String get onboardingFinish => _getLocalizedString('onboarding_finish');
  String get onboardingGettingStarted => _getLocalizedString('onboarding_getting_started');

  // Voice and AI
  String get voiceRecording => _getLocalizedString('voice_recording');
  String get voiceToText => _getLocalizedString('voice_to_text');
  String get aiProcessing => _getLocalizedString('ai_processing');
  String get speakNow => _getLocalizedString('speak_now');
  String get recordingInProgress => _getLocalizedString('recording_in_progress');
  String get processingAudio => _getLocalizedString('processing_audio');

  // Settings
  String get settingsGeneral => _getLocalizedString('settings_general');
  String get settingsTheme => _getLocalizedString('settings_theme');
  String get settingsLanguage => _getLocalizedString('settings_language');
  String get settingsNotifications => _getLocalizedString('settings_notifications');
  String get settingsPrivacy => _getLocalizedString('settings_privacy');
  String get settingsAccount => _getLocalizedString('settings_account');
  String get settingsSync => _getLocalizedString('settings_sync');
  String get settingsBackup => _getLocalizedString('settings_backup');

  // Themes
  String get themeSystem => _getLocalizedString('theme_system');
  String get themeLight => _getLocalizedString('theme_light');
  String get themeDark => _getLocalizedString('theme_dark');
  String get themeMatrix => _getLocalizedString('theme_matrix');
  String get themeDracula => _getLocalizedString('theme_dracula');
  String get themeVegeta => _getLocalizedString('theme_vegeta');

  // Error messages
  String get errorGeneric => _getLocalizedString('error_generic');
  String get errorNetwork => _getLocalizedString('error_network');
  String get errorPermission => _getLocalizedString('error_permission');
  String get errorNotFound => _getLocalizedString('error_not_found');
  String get errorInvalidInput => _getLocalizedString('error_invalid_input');
  String get errorTaskNotFound => _getLocalizedString('error_task_not_found');
  String get errorFailedToSave => _getLocalizedString('error_failed_to_save');
  String get errorFailedToDelete => _getLocalizedString('error_failed_to_delete');
  String get errorTimeout => _getLocalizedString('error_timeout');
  String get errorServer => _getLocalizedString('error_server');
  String get errorAuth => _getLocalizedString('error_auth');
  String get errorValidation => _getLocalizedString('error_validation');
  String get errorStorage => _getLocalizedString('error_storage');
  String get errorMemory => _getLocalizedString('error_memory');
  String get errorRateLimit => _getLocalizedString('error_rate_limit');

  // Success messages
  String get successTaskCreated => _getLocalizedString('success_task_created');
  String get successTaskUpdated => _getLocalizedString('success_task_updated');
  String get successTaskDeleted => _getLocalizedString('success_task_deleted');
  String get successTaskCompleted => _getLocalizedString('success_task_completed');
  String get successDataSaved => _getLocalizedString('success_data_saved');
  String get successDataSynced => _getLocalizedString('success_data_synced');

  // Accessibility
  String get accessibilityTaskCard => _getLocalizedString('accessibility_task_card');
  String get accessibilityCompleteTask => _getLocalizedString('accessibility_complete_task');
  String get accessibilityEditTask => _getLocalizedString('accessibility_edit_task');
  String get accessibilityDeleteTask => _getLocalizedString('accessibility_delete_task');
  String get accessibilityNavigateHome => _getLocalizedString('accessibility_navigate_home');
  String get accessibilityNavigateCalendar => _getLocalizedString('accessibility_navigate_calendar');
  String get accessibilityCreateTaskFAB => _getLocalizedString('accessibility_create_task_fab');

  // Pluralization helpers
  String taskCount(int count) {
    if (count == 0) {
      return _getLocalizedString('no_tasks');
    } else if (count == 1) {
      return _getLocalizedString('one_task');
    } else {
      return _getLocalizedString('tasks_count').replaceAll('{count}', count.toString());
    }
  }

  String pendingTasksCount(int count) {
    if (count == 0) {
      return _getLocalizedString('no_pending_tasks');
    } else if (count == 1) {
      return _getLocalizedString('one_pending_task');
    } else {
      return _getLocalizedString('pending_tasks_count').replaceAll('{count}', count.toString());
    }
  }

  String completedTasksCount(int count) {
    if (count == 0) {
      return _getLocalizedString('no_completed_tasks');
    } else if (count == 1) {
      return _getLocalizedString('one_completed_task');
    } else {
      return _getLocalizedString('completed_tasks_count').replaceAll('{count}', count.toString());
    }
  }

  // Date formatting
  String formatDate(DateTime date) {
    return DateFormat.yMd(locale.languageCode).format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat.jm(locale.languageCode).format(time);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMd(locale.languageCode).add_jm().format(dateTime);
  }

  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return tomorrow;
      } else if (difference.inDays <= 7) {
        return _getLocalizedString('in_days').replaceAll('{days}', difference.inDays.toString());
      } else {
        return formatDate(dateTime);
      }
    } else if (difference.inDays < 0) {
      if (difference.inDays == -1) {
        return yesterday;
      } else if (difference.inDays >= -7) {
        return _getLocalizedString('days_ago').replaceAll('{days}', (-difference.inDays).toString());
      } else {
        return formatDate(dateTime);
      }
    } else {
      return today;
    }
  }

  // Duration formatting
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return _getLocalizedString('duration_hours').replaceAll('{hours}', duration.inHours.toString());
    } else if (duration.inMinutes > 0) {
      return _getLocalizedString('duration_minutes').replaceAll('{minutes}', duration.inMinutes.toString());
    } else {
      return _getLocalizedString('duration_seconds').replaceAll('{seconds}', duration.inSeconds.toString());
    }
  }

  // Context-sensitive strings
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return _getLocalizedString('greeting_morning');
    } else if (hour < 17) {
      return _getLocalizedString('greeting_afternoon');
    } else {
      return _getLocalizedString('greeting_evening');
    }
  }

  String getTaskStatusMessage(int pendingTasks, int completedTasks) {
    if (pendingTasks == 0 && completedTasks == 0) {
      return _getLocalizedString('status_no_tasks');
    } else if (pendingTasks == 0) {
      return _getLocalizedString('status_all_done');
    } else if (completedTasks == 0) {
      return _getLocalizedString('status_lets_start');
    } else {
      return _getLocalizedString('status_keep_going');
    }
  }

  // Private helper method to get localized strings
  String _getLocalizedString(String key) {
    return _kLocalizedStrings[locale.languageCode]?[key] ?? 
           _kLocalizedStrings['en']![key] ?? 
           key;
  }

  // Localized strings map - in a real app, this would come from JSON files
  static const Map<String, Map<String, String>> _kLocalizedStrings = {
    'en': {
      'app_name': 'Task Tracker',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'retry': 'Retry',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      
      // Navigation
      'navigation_home': 'Home',
      'navigation_calendar': 'Calendar',
      'navigation_analytics': 'Analytics',
      'navigation_settings': 'Settings',
      'navigation_tasks': 'Tasks',
      'navigation_projects': 'Projects',
      
      // Tasks
      'task': 'Task',
      'tasks_plural': 'Tasks',
      'create_task': 'Create Task',
      'edit_task': 'Edit Task',
      'delete_task': 'Delete Task',
      'complete_task': 'Complete Task',
      'task_title': 'Task Title',
      'task_description': 'Task Description',
      'task_due_date': 'Due Date',
      'task_priority': 'Priority',
      'task_status': 'Status',
      'task_completed': 'Completed',
      'task_pending': 'Pending',
      'task_overdue': 'Overdue',
      
      // Priority
      'priority_low': 'Low',
      'priority_medium': 'Medium',
      'priority_high': 'High',
      'priority_urgent': 'Urgent',
      
      // Time
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'yesterday': 'Yesterday',
      'this_week': 'This Week',
      'next_week': 'Next Week',
      'this_month': 'This Month',
      'next_month': 'Next Month',
      
      // Pluralization
      'no_tasks': 'No tasks',
      'one_task': '1 task',
      'tasks_count': '{count} tasks',
      'no_pending_tasks': 'No pending tasks',
      'one_pending_task': '1 pending task',
      'pending_tasks_count': '{count} pending tasks',
      'no_completed_tasks': 'No completed tasks',
      'one_completed_task': '1 completed task',
      'completed_tasks_count': '{count} completed tasks',
      
      // Relative time
      'in_days': 'In {days} days',
      'days_ago': '{days} days ago',
      
      // Duration
      'duration_hours': '{hours}h',
      'duration_minutes': '{minutes}m',
      'duration_seconds': '{seconds}s',
      
      // Greetings
      'greeting_morning': 'Good morning',
      'greeting_afternoon': 'Good afternoon',
      'greeting_evening': 'Good evening',
      
      // Status messages
      'status_no_tasks': 'Ready to start fresh!',
      'status_all_done': 'All tasks completed!',
      'status_lets_start': 'Let\'s get started!',
      'status_keep_going': 'Great progress!',
      
      // Onboarding
      'onboarding_welcome': 'Welcome to Task Tracker',
      'onboarding_title': 'Stay Organized',
      'onboarding_subtitle': 'Manage your tasks efficiently',
      'onboarding_next': 'Next',
      'onboarding_skip': 'Skip',
      'onboarding_finish': 'Get Started',
      'onboarding_getting_started': 'Getting Started',
      
      // Voice
      'voice_recording': 'Voice Recording',
      'voice_to_text': 'Voice to Text',
      'ai_processing': 'AI Processing',
      'speak_now': 'Speak now',
      'recording_in_progress': 'Recording in progress',
      'processing_audio': 'Processing audio',
      
      // Settings
      'settings_general': 'General',
      'settings_theme': 'Theme',
      'settings_language': 'Language',
      'settings_notifications': 'Notifications',
      'settings_privacy': 'Privacy',
      'settings_account': 'Account',
      'settings_sync': 'Sync',
      'settings_backup': 'Backup',
      
      // Themes
      'theme_system': 'System',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_matrix': 'Matrix',
      'theme_dracula': 'Dracula',
      'theme_vegeta': 'Vegeta',
      
      // Errors - User-friendly messages
      'error_generic': 'Something unexpected happened. Please try again, and if the problem continues, restart the app.',
      'error_network': 'Unable to connect to the internet. Please check your connection and try again.',
      'error_permission': 'You don\'t have permission to perform this action. Please check your access rights.',
      'error_not_found': 'The item you\'re looking for couldn\'t be found. It may have been moved or deleted.',
      'error_invalid_input': 'Please check your input and make sure all required fields are filled correctly.',
      'error_task_not_found': 'This task couldn\'t be found. It may have been deleted or moved.',
      'error_failed_to_save': 'There was a problem saving your changes. Please try again.',
      'error_failed_to_delete': 'There was a problem deleting this item. Please try again.',
      'error_timeout': 'The request is taking longer than expected. Please check your connection and try again.',
      'error_server': 'Our servers are experiencing issues. Please try again in a few minutes.',
      'error_auth': 'Your session has expired. Please log in again to continue.',
      'error_validation': 'Please check your input and make sure all required fields are filled correctly.',
      'error_storage': 'There was a problem accessing files. Please check your device storage.',
      'error_memory': 'Your device is running low on resources. Please close some apps and try again.',
      'error_rate_limit': 'You\'ve made too many requests. Please wait a moment and try again.',
      
      // Success messages
      'success_task_created': 'Task created successfully',
      'success_task_updated': 'Task updated successfully',
      'success_task_deleted': 'Task deleted successfully',
      'success_task_completed': 'Task completed successfully',
      'success_data_saved': 'Data saved successfully',
      'success_data_synced': 'Data synced successfully',
      
      // Accessibility
      'accessibility_task_card': 'Task card',
      'accessibility_complete_task': 'Mark task as complete',
      'accessibility_edit_task': 'Edit task',
      'accessibility_delete_task': 'Delete task',
      'accessibility_navigate_home': 'Navigate to home',
      'accessibility_navigate_calendar': 'Navigate to calendar',
      'accessibility_create_task_fab': 'Create new task',
    },
    
    // Spanish translations
    'es': {
      'app_name': 'Rastreador de Tareas',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'add': 'Agregar',
      'close': 'Cerrar',
      'ok': 'OK',
      'yes': 'Sí',
      'no': 'No',
      'retry': 'Reintentar',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'warning': 'Advertencia',
      'info': 'Información',
      
      // Navigation
      'navigation_home': 'Inicio',
      'navigation_calendar': 'Calendario',
      'navigation_analytics': 'Analíticas',
      'navigation_settings': 'Configuración',
      'navigation_tasks': 'Tareas',
      'navigation_projects': 'Proyectos',
      
      // Tasks
      'task': 'Tarea',
      'tasks_plural': 'Tareas',
      'create_task': 'Crear Tarea',
      'edit_task': 'Editar Tarea',
      'delete_task': 'Eliminar Tarea',
      'complete_task': 'Completar Tarea',
      'task_title': 'Título de la Tarea',
      'task_description': 'Descripción de la Tarea',
      'task_due_date': 'Fecha de Vencimiento',
      'task_priority': 'Prioridad',
      'task_status': 'Estado',
      'task_completed': 'Completada',
      'task_pending': 'Pendiente',
      'task_overdue': 'Vencida',
      
      // Priority
      'priority_low': 'Baja',
      'priority_medium': 'Media',
      'priority_high': 'Alta',
      'priority_urgent': 'Urgente',
      
      // Time
      'today': 'Hoy',
      'tomorrow': 'Mañana',
      'yesterday': 'Ayer',
      'this_week': 'Esta Semana',
      'next_week': 'Próxima Semana',
      'this_month': 'Este Mes',
      'next_month': 'Próximo Mes',
      
      // Greetings
      'greeting_morning': 'Buenos días',
      'greeting_afternoon': 'Buenas tardes',
      'greeting_evening': 'Buenas noches',
      
      // Status messages
      'status_no_tasks': '¡Listo para comenzar de nuevo!',
      'status_all_done': '¡Todas las tareas completadas!',
      'status_lets_start': '¡Empecemos!',
      'status_keep_going': '¡Excelente progreso!',
      
      // Onboarding
      'onboarding_welcome': 'Bienvenido a Task Tracker',
      'onboarding_title': 'Mantente Organizado',
      'onboarding_subtitle': 'Gestiona tus tareas de manera eficiente',
      'onboarding_next': 'Siguiente',
      'onboarding_skip': 'Omitir',
      'onboarding_finish': 'Comenzar',
      'onboarding_getting_started': 'Comenzando',
    },
    
    // French translations
    'fr': {
      'app_name': 'Gestionnaire de Tâches',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'close': 'Fermer',
      'ok': 'OK',
      'yes': 'Oui',
      'no': 'Non',
      'retry': 'Réessayer',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'warning': 'Avertissement',
      'info': 'Information',
      
      // Navigation
      'navigation_home': 'Accueil',
      'navigation_calendar': 'Calendrier',
      'navigation_analytics': 'Analyses',
      'navigation_settings': 'Paramètres',
      'navigation_tasks': 'Tâches',
      'navigation_projects': 'Projets',
      
      // Tasks
      'task': 'Tâche',
      'tasks_plural': 'Tâches',
      'create_task': 'Créer une Tâche',
      'edit_task': 'Modifier la Tâche',
      'delete_task': 'Supprimer la Tâche',
      'complete_task': 'Terminer la Tâche',
      'task_title': 'Titre de la Tâche',
      'task_description': 'Description de la Tâche',
      'task_due_date': 'Date d\'échéance',
      'task_priority': 'Priorité',
      'task_status': 'Statut',
      'task_completed': 'Terminée',
      'task_pending': 'En attente',
      'task_overdue': 'En retard',
      
      // Priority
      'priority_low': 'Faible',
      'priority_medium': 'Moyenne',
      'priority_high': 'Élevée',
      'priority_urgent': 'Urgente',
      
      // Time
      'today': 'Aujourd\'hui',
      'tomorrow': 'Demain',
      'yesterday': 'Hier',
      'this_week': 'Cette Semaine',
      'next_week': 'Semaine Prochaine',
      'this_month': 'Ce Mois',
      'next_month': 'Mois Prochain',
      
      // Greetings
      'greeting_morning': 'Bonjour',
      'greeting_afternoon': 'Bon après-midi',
      'greeting_evening': 'Bonsoir',
      
      // Status messages
      'status_no_tasks': 'Prêt à repartir à zéro !',
      'status_all_done': 'Toutes les tâches terminées !',
      'status_lets_start': 'Commençons !',
      'status_keep_going': 'Excellent progrès !',
      
      // Onboarding
      'onboarding_welcome': 'Bienvenue dans Task Tracker',
      'onboarding_title': 'Restez Organisé',
      'onboarding_subtitle': 'Gérez vos tâches efficacement',
      'onboarding_next': 'Suivant',
      'onboarding_skip': 'Passer',
      'onboarding_finish': 'Commencer',
      'onboarding_getting_started': 'Pour Commencer',
    },
    
    // German translations
    'de': {
      'app_name': 'Aufgaben-Tracker',
      'cancel': 'Abbrechen',
      'confirm': 'Bestätigen',
      'save': 'Speichern',
      'delete': 'Löschen',
      'edit': 'Bearbeiten',
      'add': 'Hinzufügen',
      'close': 'Schließen',
      'ok': 'OK',
      'yes': 'Ja',
      'no': 'Nein',
      'retry': 'Wiederholen',
      'loading': 'Wird geladen...',
      'error': 'Fehler',
      'success': 'Erfolg',
      'warning': 'Warnung',
      'info': 'Information',
      
      // Navigation
      'navigation_home': 'Startseite',
      'navigation_calendar': 'Kalender',
      'navigation_analytics': 'Analytik',
      'navigation_settings': 'Einstellungen',
      'navigation_tasks': 'Aufgaben',
      'navigation_projects': 'Projekte',
      
      // Tasks
      'task': 'Aufgabe',
      'tasks_plural': 'Aufgaben',
      'create_task': 'Aufgabe Erstellen',
      'edit_task': 'Aufgabe Bearbeiten',
      'delete_task': 'Aufgabe Löschen',
      'complete_task': 'Aufgabe Abschließen',
      'task_title': 'Aufgabentitel',
      'task_description': 'Aufgabenbeschreibung',
      'task_due_date': 'Fälligkeitsdatum',
      'task_priority': 'Priorität',
      'task_status': 'Status',
      'task_completed': 'Abgeschlossen',
      'task_pending': 'Ausstehend',
      'task_overdue': 'Überfällig',
      
      // Priority
      'priority_low': 'Niedrig',
      'priority_medium': 'Mittel',
      'priority_high': 'Hoch',
      'priority_urgent': 'Dringend',
      
      // Time
      'today': 'Heute',
      'tomorrow': 'Morgen',
      'yesterday': 'Gestern',
      'this_week': 'Diese Woche',
      'next_week': 'Nächste Woche',
      'this_month': 'Diesen Monat',
      'next_month': 'Nächsten Monat',
      
      // Greetings
      'greeting_morning': 'Guten Morgen',
      'greeting_afternoon': 'Guten Tag',
      'greeting_evening': 'Guten Abend',
      
      // Status messages
      'status_no_tasks': 'Bereit für einen Neuanfang!',
      'status_all_done': 'Alle Aufgaben erledigt!',
      'status_lets_start': 'Lass uns anfangen!',
      'status_keep_going': 'Großartiger Fortschritt!',
      
      // Onboarding
      'onboarding_welcome': 'Willkommen bei Task Tracker',
      'onboarding_title': 'Bleiben Sie Organisiert',
      'onboarding_subtitle': 'Verwalten Sie Ihre Aufgaben effizient',
      'onboarding_next': 'Weiter',
      'onboarding_skip': 'Überspringen',
      'onboarding_finish': 'Loslegen',
      'onboarding_getting_started': 'Erste Schritte',
    },
  };
}