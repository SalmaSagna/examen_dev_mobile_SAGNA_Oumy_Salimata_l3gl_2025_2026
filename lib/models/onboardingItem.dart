import 'package:flutter/material.dart';

class OnboardingItem {
  /// Icone affichee
  final IconData icon;

  /// Titre de la page
  final String title;

  /// Description de la page
  final String description;

  /// Couleur de l'icone
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}