import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_task_manager/core/injection_container.dart' as di;
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/bloc/task_event.dart';
import 'features/tasks/presentation/bloc/task_state.dart';
import 'features/tasks/presentation/pages/add_edit_task_page.dart';
import 'features/tasks/presentation/pages/task_list_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  await NotificationService().init(
    onNotificationTapCallback: (String? payload) {
      if (payload != null && payload.isNotEmpty) {
        final int? taskId = int.tryParse(payload);
        if (taskId != null) {
          _handleNotificationDeepLink(taskId);
        }
      }
    },
  );

  runApp(const PlanItApp());
}

// Deep link routing: locates task from TaskBloc and opens AddEditTaskPage
void _handleNotificationDeepLink(int taskId) {
  final BuildContext? currentContext = navigatorKey.currentContext;
  if (currentContext == null) return;

  final taskBloc = BlocProvider.of<TaskBloc>(currentContext);
  final state = taskBloc.state;

  if (state is TaskLoadedState) {
    try {
      final matchedTask = state.tasks.firstWhere((t) => t.id == taskId);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AddEditTaskPage(task: matchedTask),
        ),
      );
    } catch (_) {
      taskBloc.add(LoadTasksEvent());
    }
  }
}

class PlanItApp extends StatelessWidget {
  const PlanItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<TaskBloc>(
          create: (_) => di.sl<TaskBloc>()..add(LoadTasksEvent()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'PlanIt',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const TaskListPage(),
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:offline_task_manager/core/services/notification_service.dart';
// import 'package:offline_task_manager/features/tasks/data/datasources/database_helper.dart';
// import 'package:offline_task_manager/features/tasks/data/datasources/task_repository_impl.dart';

// import 'features/tasks/data/datasources/task_local_data_source.dart';
// import 'features/tasks/domain/usecases/add_task_usecase.dart';
// import 'features/tasks/domain/usecases/delete_task_usecase.dart';
// import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
// import 'features/tasks/domain/usecases/update_task_usecase.dart';
// import 'features/tasks/presentation/bloc/task_bloc.dart';
// import 'features/tasks/presentation/pages/task_list_page.dart';

// void main() async {
//   // Ensure native bindings are initialized before database setup
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize notification service permissions and channels
//   await NotificationService.instance.init();

//   // Core database singleton
//   final databaseHelper = DatabaseHelper.instance;

//   // Data layer dependencies
//   final localDataSource = TaskLocalDataSourceImpl(databaseHelper: databaseHelper);
//   final taskRepository = TaskRepositoryImpl(localDataSource: localDataSource);

//   // Domain layer callable use cases
//   final getTasksUseCase = GetTasksUseCase(taskRepository);
//   final addTaskUseCase = AddTaskUseCase(taskRepository);
//   final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
//   final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);

//   runApp(
//     MyApp(
//       getTasksUseCase: getTasksUseCase,
//       addTaskUseCase: addTaskUseCase,
//       updateTaskUseCase: updateTaskUseCase,
//       deleteTaskUseCase: deleteTaskUseCase,
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final GetTasksUseCase getTasksUseCase;
//   final AddTaskUseCase addTaskUseCase;
//   final UpdateTaskUseCase updateTaskUseCase;
//   final DeleteTaskUseCase deleteTaskUseCase;

//   const MyApp({
//     super.key,
//     required this.getTasksUseCase,
//     required this.addTaskUseCase,
//     required this.updateTaskUseCase,
//     required this.deleteTaskUseCase,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => TaskBloc(
//         getTasksUseCase: getTasksUseCase,
//         addTaskUseCase: addTaskUseCase,
//         updateTaskUseCase: updateTaskUseCase,
//         deleteTaskUseCase: deleteTaskUseCase,
//       ),
//       child: MaterialApp(
//         title: 'Offline Task Manager',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: const TaskListPage(),
//       ),
//     );
//   }
// }