import 'package:offline_task_manager/features/tasks/data/repositories/task_repository.dart';

import '../entities/task_entity.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) async {
    return await repository.addTask(task);
  }
}