// lib/features/tasks/data/models/task_model.dart
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.isCompleted,
    required super.priority,
    super.reminderDateTime,
  });
factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      createdAt: map['createdAt'] as String,
      isCompleted: map['isCompleted'] as int,
      priority: map['priority'] as String,
      reminderDateTime: map['reminderDateTime'] as String?,
    );
  }
  // factory TaskModel.fromMap(Map<String, dynamic> map) {
  //   return TaskModel(
  //     id: map['id'] as int?,
  //     title: map['title'] as String,
  //     description: map['description'] as String? ?? '',
  //     createdAt: map['createdAt'] as String,
  //     isCompleted: map['isCompleted'] as int,
  //     priority: map['priority'] as String,
  //     reminderDateTime: map['reminderDateTime'] as String?,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'isCompleted': isCompleted,
      'priority': priority,
      'reminderDateTime': reminderDateTime,
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      reminderDateTime: entity.reminderDateTime,
    );
  }
}