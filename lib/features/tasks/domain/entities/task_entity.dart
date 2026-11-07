import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String description;
  final String createdAt;
  final int isCompleted;
  final String priority;
  final String? reminderDateTime; // Format: yyyy-MM-dd HH:mm

  const TaskEntity({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isCompleted,
    required this.priority,
    this.reminderDateTime,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        isCompleted,
        priority,
        reminderDateTime,
      ];
}