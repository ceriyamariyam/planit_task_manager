import 'package:offline_task_manager/features/tasks/data/repositories/task_repository.dart';
import '../../domain/entities/task_entity.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TaskEntity>> getTasks() async {
    return await localDataSource.getTasks();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    // Map full entity to model including reminderDateTime
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.insertTask(taskModel);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    // Map full entity to model including reminderDateTime
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(int id) async {
    await localDataSource.deleteTask(id);
  }
}
// import 'package:offline_task_manager/features/tasks/data/repositories/task_repository.dart';

// import '../../domain/entities/task_entity.dart';
// import '../datasources/task_local_data_source.dart';
// import '../models/task_model.dart';

// class TaskRepositoryImpl implements TaskRepository {
//   final TaskLocalDataSource localDataSource;

//   TaskRepositoryImpl({required this.localDataSource});

//   @override
//   Future<List<TaskEntity>> getTasks() async {
//     return await localDataSource.getTasks();
//   }

//   @override
//   Future<void> addTask(TaskEntity task) async {
//     final taskModel = TaskModel(
//       id: task.id,
//       title: task.title,
//       description: task.description,
//       createdAt: task.createdAt,
//       isCompleted: task.isCompleted,
//       priority: task.priority,
//     );
//     await localDataSource.insertTask(taskModel);
//   }

//   @override
//   Future<void> updateTask(TaskEntity task) async {
//     final taskModel = TaskModel(
//       id: task.id,
//       title: task.title,
//       description: task.description,
//       createdAt: task.createdAt,
//       isCompleted: task.isCompleted,
//       priority: task.priority,
//     );
//     await localDataSource.updateTask(taskModel);
//   }

//   @override
//   Future<void> deleteTask(int id) async {
//     await localDataSource.deleteTask(id);
//   }
// }