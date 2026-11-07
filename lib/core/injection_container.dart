import 'package:get_it/get_it.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/database_helper.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/task_repository_impl.dart';
import 'package:offline_task_manager/features/tasks/data/repositories/task_repository.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:offline_task_manager/features/tasks/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Presentation Layer - BLoC
  sl.registerFactory(
    () => TaskBloc(
      getTasksUseCase: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
    ),
  );

  // Domain Layer - Use Cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  // Data Layer - Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl()),
  );

  // Data Layer - Data Source
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Core - Database Helper
  sl.registerLazySingleton(() => DatabaseHelper.instance);
}