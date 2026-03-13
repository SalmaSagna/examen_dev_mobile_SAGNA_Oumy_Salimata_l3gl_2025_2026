import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {/// Pour pouvoir notifier les widgets quand quelque chose change
  // Propriétés privées
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;//Si l'application a fini de charger les donnees
  bool _isLoading = false;//Si l'application est en cours de chargement

  // Getters publics
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Initialise l'état de l'application au démarrage
  /// Charge l'état depuis StorageService
  Future<void> init() async { //On utilise ça car le chargement des données n'est pas instantané
    _isLoading = true;
    // quand on appelle notifyListeners(), le provider envoie un signal à tous les widgets qui sont
    // abonnés à lui. Ces widgets comprennent qu'il y a eu un changement, ils se reconstruisent et
    // affichent les nouvelles données
    notifyListeners();

    try {
      // Simulation de la récupération depuis StorageService
      // _isOnboardingComplete = await StorageService.getOnboardingStatus();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Erreur d\'initialisation: $e');//pour afficher les erreurs dans la console
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marque l'onboarding comme terminé
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    // await StorageService.saveOnboardingStatus(true);
    notifyListeners(); // Notifie pour rediriger vers le LoginScreen
  }

  /// Réinitialise l'état de l'onboarding pour les tests
  Future<void> resetOnboarding() async {
    _isOnboardingComplete = false;
    // await StorageService.saveOnboardingStatus(false);
    notifyListeners();
  }
}