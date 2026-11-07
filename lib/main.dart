import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_task_manager/core/services/notification_service.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/database_helper.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/task_repository_impl.dart';

import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/domain/usecases/add_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/pages/task_list_page.dart';

void main() async {
  // Ensure native bindings are initialized before database setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service permissions and channels
  await NotificationService.instance.init();

  // Core database singleton
  final databaseHelper = DatabaseHelper.instance;

  // Data layer dependencies
  final localDataSource = TaskLocalDataSourceImpl(databaseHelper: databaseHelper);
  final taskRepository = TaskRepositoryImpl(localDataSource: localDataSource);

  // Domain layer callable use cases
  final getTasksUseCase = GetTasksUseCase(taskRepository);
  final addTaskUseCase = AddTaskUseCase(taskRepository);
  final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);

  runApp(
    MyApp(
      getTasksUseCase: getTasksUseCase,
      addTaskUseCase: addTaskUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  const MyApp({
    super.key,
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc(
        getTasksUseCase: getTasksUseCase,
        addTaskUseCase: addTaskUseCase,
        updateTaskUseCase: updateTaskUseCase,
        deleteTaskUseCase: deleteTaskUseCase,
      ),
      child: MaterialApp(
        title: 'Offline Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TaskListPage(),
      ),
    );
  }
}