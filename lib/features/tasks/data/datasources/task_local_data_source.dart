import 'package:offline_task_manager/features/tasks/data/datasources/database_helper.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<int> insertTask(TaskModel task);
  Future<int> updateTask(TaskModel task);
  Future<void> deleteTask(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final DatabaseHelper databaseHelper;

  TaskLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TaskModel>> getTasks() async {
    return await databaseHelper.getTasks();
  }

  @override
  Future<int> insertTask(TaskModel task) async {
    return await databaseHelper.insertTask(task);
  }

  @override
  Future<int> updateTask(TaskModel task) async {
    return await databaseHelper.updateTask(task);
  }

  @override
  Future<void> deleteTask(int id) async {
    await databaseHelper.deleteTask(id);
  }
}
// import 'package:offline_task_manager/features/tasks/data/datasources/database_helper.dart';
// import 'package:offline_task_manager/features/tasks/domain/entities/task_entity.dart';

// import '../models/task_model.dart';

// abstract class TaskLocalDataSource {
//   Future<List<TaskModel>> getTasks();
//   Future<void> insertTask(TaskModel task);
//   Future<void> updateTask(TaskModel task);
//   Future<void> deleteTask(int id);
// }

// class TaskLocalDataSourceImpl implements TaskLocalDataSource {
//   final DatabaseHelper databaseHelper;

//   TaskLocalDataSourceImpl({required this.databaseHelper});

//   @override
//   Future<List<TaskModel>> getTasks() async {
//     return await databaseHelper.getTasks();
//   }
//   @override
//   Future<int> insertTask(TaskEntity task) async {
//     final model = TaskModel.fromEntity(task);
//     return await databaseHelper.insertTask(model);
// }
 
//   // @override
//   // Future<void> insertTask(TaskModel task) async {
//   //   await databaseHelper.insertTask(task);
//   // }
//   @override
//  Future<int> updateTask(TaskEntity task) async {
//   final model = TaskModel.fromEntity(task);
//   return await databaseHelper.updateTask(model);
// }
//   // @override
//   // Future<void> updateTask(TaskModel task) async {
//   //   await databaseHelper.updateTask(task);
//   // }

//   @override
//   Future<void> deleteTask(int id) async {
//     await databaseHelper.deleteTask(id);
//   }
// }