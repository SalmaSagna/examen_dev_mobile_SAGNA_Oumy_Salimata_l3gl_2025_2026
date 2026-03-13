import 'package:flutter/material.dart';
import 'package:sunu_task/models/user.dart';
import 'package:uuid/uuid.dart';
import 'package:sunu_task/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {//gere la connexion et l'inscription
  // Instance du service de stockage (Singleton)
  final StorageService _storageService = StorageService.instance;

  // Propriétés privées
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters publics
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge l'utilisateur depuis le stockage au démarrage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // On récupère la session stockée
      _currentUser = _storageService.getCurrentUser();
    } catch (e) {
      _error = "Erreur d'initialisation";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logique de connexion
  Future<bool> login(String email, String password) async {
    // 1. Activer le chargement et effacer l'erreur
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 2. Récupérer tous les utilisateurs depuis StorageService
      List<User> users = await _storageService.getUsers();

      // 3. Chercher l'utilisateur avec l'email et le mot de passe correspondants
      // On utilise firstWhere. Si rien n'est trouvé, cela lance une exception.
      final user = users.firstWhere(
            (u) => u.email == email && u.password == password,
        orElse: () => throw Exception("Email ou mot de passe incorrect"),
      );

      // 4. Si trouvé : sauvegarder la session et mettre à jour l'utilisateur courant
      await _storageService.setCurrentUser(user);
      _currentUser = user;
      return true;
    } catch (e) {
      // 5. Si non trouvé (ou erreur) : message d'erreur
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      // 6. Dans tous les cas : arrêter le chargement
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logique d'inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Vérifier qu'aucun utilisateur n'existe déjà avec cet email
      List<User> allUsers = await _storageService.getUsers();
      bool emailExists = allUsers.any((u) => u.email == email);

      if (emailExists) {
        throw Exception("Cet email est déjà utilisé");
      }

      // 2. Créer un nouvel objet User avec un ID généré (UUID)
      var uuid = const Uuid();
      User newUser = User(
          id: uuid.v4(),
          name: name,
          email: email,
          password: password
      );

      // 3. Sauvegarder dans la liste globale via StorageService
      await _storageService.saveUser(newUser);

      // 4. Définir comme utilisateur courant (Session)
      await _storageService.setCurrentUser(newUser);
      _currentUser = newUser;

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mise à jour du profil
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Création de la copie modifiée (Immuabilité)
      // La méthode .copyWith est idéale pour ne changer que ce qui est nécessaire
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
      );

      // Sauvegarde de la mise à jour (Liste globale + Session)
      await _storageService.saveUser(updatedUser);
      await _storageService.setCurrentUser(updatedUser);

      _currentUser = updatedUser;
    } catch (e) {
      _error = "Erreur lors de la mise à jour";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _storageService.setCurrentUser(null);
    _currentUser = null;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}