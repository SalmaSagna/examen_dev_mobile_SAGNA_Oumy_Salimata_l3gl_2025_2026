import 'package:flutter/material.dart';

/// Définition des types en dehors de la classe pour un accès direct
enum TaskStatus { todo, inProgress, done }
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;    // Utilise le type TaskStatus
  final TaskPriority priority; // Utilise le type TaskPriority
  final DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Crée une copie de la tâche avec des modifications
  /// Très utile pour changer le statut ou la priorité dans le Provider
  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Conversion pour le stockage (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.name, // .name transforme l'enum en String ("todo", etc.)
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Création depuis les données de stockage
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'],
      description: map['description'],
      status: TaskStatus.values.byName(map['status']),
      priority: TaskPriority.values.byName(map['priority']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}