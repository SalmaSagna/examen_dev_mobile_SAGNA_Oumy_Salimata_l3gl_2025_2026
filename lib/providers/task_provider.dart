import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;

  /// Retourne les tâches filtrées et triées
  List<Task> get tasks {
    List<Task> filtered = [..._tasks];//copie grace a l'operateur spread (...)

    // 1. Filtrage par statut
    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList(); // recupere les taches qui ont comme statut statusFilter
    }

    // 2. Filtrage par priorité
    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    // 3. Tri : Status (inProgress > todo > done) puis Priorité (high > medium > low)
    filtered.sort((a, b) {
      // Comparaison par statut
      int statusComp = _statusValue(a.status).compareTo(_statusValue(b.status));//statusComp = a.status-b.status
      if (statusComp != 0) return statusComp;

      // Si même statut, comparaison par priorité
      return _priorityValue(b.priority).compareTo(_priorityValue(a.priority));
    });

    return filtered;
  }

  /// Compteur par statut pour le Dashboard
  Map<TaskStatus, int> get taskCountByStatus {
    return {
      TaskStatus.todo: _tasks.where((t) => t.status == TaskStatus.todo).length,
      TaskStatus.inProgress: _tasks.where((t) => t.status == TaskStatus.inProgress).length,
      TaskStatus.done: _tasks.where((t) => t.status == TaskStatus.done).length,
    };
  }

  // --- Méthodes CRUD ---

  /// Charge les tâches depuis le StorageService
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners(); //
    try {
      // Récupération réelle via le service de stockage
      _tasks = await _storageService.getTasksByProject(projectId);
    } catch (e) {
      debugPrint("Erreur lors du chargement des tâches : $e");
    } finally {
      _isLoading = false;
      notifyListeners(); //
    }
  }

  /// Crée et sauvegarde une nouvelle tâche
  Future<void> createTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _storageService.saveTask(task); // Persistance
      _tasks.add(task);
    } catch (e) {
      debugPrint("Erreur lors de la création : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour une tâche existante
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _storageService.saveTask(task); // Écrase l'ancienne version
      int index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprime une tâche
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _storageService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change uniquement le statut
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    int index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      Task updatedTask = _tasks[index].copyWith(status: status);
      await updateTask(updatedTask); // Réutilise la logique de mise à jour avec persistance
    }
  }

  // --- Gestion des Filtres ---

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners(); //
  }

  // --- Helpers de tri ---

  int _statusValue(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress: return 1;
      case TaskStatus.todo: return 2;
      case TaskStatus.done: return 3;
    }
  }

  int _priorityValue(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return 3;
      case TaskPriority.medium: return 2;
      case TaskPriority.low: return 1;
    }
  }
}