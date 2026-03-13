import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sunu_task/models/user.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';


/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========
  /// Instance Unique (privee)
  static StorageService? _instance; //static: l'attribut appartient à la class elle meme et non a l'objet

  /// Getter pour acceder a l'instance
  static StorageService get instance {
    _instance ??= StorageService._();//si _instance est null on l'initialise
    return _instance!;
  }

  /// Constructeur prive
  StorageService._();

  //===== SharedPreferences ==========
  /**
   * SharedPreferences utilise des opérations asynchrones
   * car il lit/ecrtit sur le disque
   *
   * Le mot-cle await attend que l'operation se termine
   * La fonction doit etre marque async et retourner un Future
   * Les variables doivent être marqué par late
   */
  late SharedPreferences _prefs;//late attend une valeur non nulle

  /// Indicateur d'initialisation
  bool _initialized = false;

  Future<void> init() async {
    if(_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Cles de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUsers = 'users_list';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyProjects = 'projects_list';
  static const String _keyTasks = 'tasks_list';

  // ======== Gestion Onboarding =========
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ======== Gestion Authentification (Users) =========
  /// Récupérer la liste de tous les utilisateurs
  List<User> getUsers() {
    List<String>? usersJson = _prefs.getStringList(_keyUsers);
    if (usersJson == null) return [];
    return usersJson.map((u) => User.fromMap(jsonDecode(u))).toList();
    //map parcours la liste un par un et cree une nouvelle sequence de donnee
    //jsonEncode transforme en u.toMap un string au format JSON "clé-valeur"
  }

  /// Sauvegarder tous les utilisateurs inscrits
  Future<void> saveUsers(List<User> users) async {
    List<String> usersJson = users.map((u) => jsonEncode(u.toMap())).toList();
    //map parcours la liste un par un et cree une nouvelle sequence de donnee
    //jsonEncode transforme en u.toMap un string au format JSON "clé-valeur"
    await _prefs.setStringList(_keyUsers, usersJson);
  }

  /// Ajouter ou mettre à jour un utilisateur
  Future<void> saveUser(User newUser) async {
    List<User> allUsers = await getUsers();
    int index = allUsers.indexWhere((u) => u.id == newUser.id);

    if (index != -1) {
      allUsers[index] = newUser;
    } else {
      allUsers.add(newUser);
    }
    await saveUsers(allUsers);
  }

  /// Gérer l'utilisateur actuellement connecté
  Future<void> setCurrentUser(User? user) async {
    if (user == null) {
      await _prefs.remove(_keyCurrentUser);
    } else {
      await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
    }
  }

  User? getCurrentUser() {
    String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson));
  }

  // ======== Gestion des Projets =========

  /// Récupérer tous les projets
  List<Project> getProjects() {
    List<String>? projectsJson = _prefs.getStringList(_keyProjects);
    if (projectsJson == null) return [];
    return projectsJson.map((p) => Project.fromMap(jsonDecode(p))).toList();
  }

  /// Sauvegarder la liste complète des projets
  Future<void> saveProjects(List<Project> projects) async {
    List<String> projectsJson = projects.map((p) => jsonEncode(p.toMap())).toList();
    await _prefs.setStringList(_keyProjects, projectsJson);
  }

  /// Ajouter ou mettre à jour un projet
  Future<void> saveProject(Project project) async {
    List<Project> allProjects = getProjects();
    int index = allProjects.indexWhere((p) => p.id == project.id);

    if (index != -1) {
      allProjects[index] = project; // Mise à jour
    } else {
      allProjects.add(project); // Création
    }
    await saveProjects(allProjects);
  }

  /// Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    List<Project> allProjects = getProjects();
    allProjects.removeWhere((p) => p.id == projectId);
    await saveProjects(allProjects);
  }

  // ======== Gestion des Tasks (Tâches) =========

  /// Récupérer toutes les tâches
  List<Task> getTasks() {
    List<String>? tasksJson = _prefs.getStringList(_keyTasks);
    if (tasksJson == null) return [];
    return tasksJson.map((t) => Task.fromMap(jsonDecode(t))).toList();
  }

  /// Sauvegarder la liste complète des tâches
  Future<void> saveTasks(List<Task> tasks) async {
    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  /// Ajouter ou mettre à jour une tâche
  Future<void> saveTask(Task task) async {
    List<Task> allTasks = getTasks();
    int index = allTasks.indexWhere((t) => t.id == task.id);

    if (index != -1) {
      allTasks[index] = task; // Mise à jour
    } else {
      allTasks.add(task); // Création
    }
    await saveTasks(allTasks);
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    List<Task> allTasks = getTasks();
    allTasks.removeWhere((t) => t.id == taskId);
    await saveTasks(allTasks);
  }

  /// Récupère les tâches liées à un projet spécifique
  Future<List<Task>> getTasksByProject(String projectId) async {
    // 1. Récupérer TOUTES les tâches stockées sur le téléphone
    List<Task> allTasks = getTasks();
    // 2. Filtrer pour ne garder que celles qui ont le bon projectId
    return allTasks.where((task) => task.projectId == projectId).toList();
  }
}