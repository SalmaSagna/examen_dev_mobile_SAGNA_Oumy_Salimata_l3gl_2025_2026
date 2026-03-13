import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;
  // Propriétés privées
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  // Getters publics
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length; // Utile pour le Dashboard
  bool get isLoading => _isLoading;

  /// Charger les projets d'un utilisateur spécifique
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // On récupère tous les projets du stockage
      final allProjects = await _storageService.getProjects();

      // On filtre pour ne garder que ceux de l'utilisateur connecté
      _projects = allProjects.where((p) => p.userId == userId).toList();
    } catch (e) {
      debugPrint("Erreur chargement projets: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un nouveau projet
  Future<void> createProject(Project project) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Sauvegarde permanente
      await _storageService.saveProject(project);

      // 2. Mise à jour de la liste en mémoire
      _projects.add(project);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur création: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Modifier un projet existant
  Future<void> updateProject(Project project) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.saveProject(project);

      // On cherche l'index du projet pour le remplacer dans la liste locale
      int index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur modification: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.deleteProject(projectId);

      // On retire de la liste locale
      _projects.removeWhere((p) => p.id == projectId);

      // Si le projet supprimé était celui sélectionné, on remet à null
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Erreur suppression: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sélectionner un projet pour voir ses détails
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}