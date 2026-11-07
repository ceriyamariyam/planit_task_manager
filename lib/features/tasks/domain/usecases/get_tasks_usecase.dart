import 'package:offline_task_manager/features/tasks/data/repositories/task_repository.dart';

import '../entities/task_entity.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<List<TaskEntity>> call() async {
    return await repository.getTasks();
  }
}