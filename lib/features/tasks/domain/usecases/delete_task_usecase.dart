
import 'package:offline_task_manager/features/tasks/data/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteTask(id);
  }
}