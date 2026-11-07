import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// Initial state before any action is triggered
class TaskInitialState extends TaskState {}

// State while loading tasks or processing an operation
class TaskLoadingState extends TaskState {}

// State when tasks are successfully retrieved
class TaskLoadedState extends TaskState {
  final List<TaskEntity> tasks;

  const TaskLoadedState(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

// State when an error occurs during an operation
class TaskErrorState extends TaskState {
  final String message;

  const TaskErrorState(this.message);

  @override
  List<Object?> get props => [message];
}