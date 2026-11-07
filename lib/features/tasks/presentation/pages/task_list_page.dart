import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/native/native_bridge.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_item_card.dart';
import 'add_edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasksEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTaskStatus(TaskEntity task) async {
    final isNowCompleted = task.isCompleted == 0;

    final updatedTask = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt,
      isCompleted: isNowCompleted ? 1 : 0,
      priority: task.priority,
      reminderDateTime: task.reminderDateTime,
    );

    context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));

    if (isNowCompleted) {
      await NativeBridge.triggerNativeHaptic();

      if (task.id != null) {
        await NotificationService.instance.cancelReminder(task.id!);
      }

      final battery = await NativeBridge.getBatteryLevel();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.deepPurple.shade700,
            duration: const Duration(seconds: 4),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    battery != -1
                        ? 'Task Completed! Battery: $battery%'
                        : 'Task Completed Successfully!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.amberAccent,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } else {
      if (task.id != null &&
          task.reminderDateTime != null &&
          task.reminderDateTime!.isNotEmpty) {
        final scheduled = DateTime.tryParse(task.reminderDateTime!);
        if (scheduled != null && scheduled.isAfter(DateTime.now())) {
          await NotificationService.instance.scheduleTaskReminder(
            id: task.id!,
            title: task.title,
            body: task.description,
            scheduledDate: scheduled,
          );
        }
      }
    }
  }

  void _deleteTask(TaskEntity task) async {
    if (task.id != null) {
      await NotificationService.instance.cancelReminder(task.id!);
      if (mounted) {
        context.read<TaskBloc>().add(DeleteTaskEvent(task.id!));
      }
    }
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, TaskEntity task) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PlanIt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isCurrentDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isCurrentDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Main task list view wrapped with BlocBuilder
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskErrorState) {
                  return Center(child: Text(state.message));
                } else if (state is TaskLoadedState) {
                  final query = _searchController.text.toLowerCase().trim();

                  final filteredTasks = state.tasks.where((task) {
                    final matchesQuery = task.title.toLowerCase().contains(query) ||
                        task.description.toLowerCase().contains(query);

                    if (!matchesQuery) return false;

                    if (_selectedFilter == 'Pending') {
                      return task.isCompleted == 0;
                    } else if (_selectedFilter == 'Completed') {
                      return task.isCompleted == 1;
                    }
                    return true;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks found',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return Dismissible(
                        key: ValueKey(task.id ?? index),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) =>
                            _showDeleteConfirmDialog(context, task),
                        onDismissed: (_) => _deleteTask(task),
                        child: TaskItemCard(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTaskPage(task: task),
                              ),
                            );
                          },
                          onStatusChanged: (_) => _toggleTaskStatus(task),
                          onDelete: () async {
                            final confirm =
                                await _showDeleteConfirmDialog(context, task);
                            if (confirm == true) {
                              _deleteTask(task);
                            }
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTaskPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:offline_task_manager/core/theme/theme_cubit.dart';
// import '../../../../core/native/native_bridge.dart';
// import '../../../../core/services/notification_service.dart';
// import '../../domain/entities/task_entity.dart';
// import '../bloc/task_bloc.dart';
// import '../bloc/task_event.dart';
// import '../bloc/task_state.dart';
// import '../widgets/task_item_card.dart';
// import 'add_edit_task_page.dart';

// class TaskListPage extends StatefulWidget {
//   const TaskListPage({super.key});

//   @override
//   State<TaskListPage> createState() => _TaskListPageState();
// }

// class _TaskListPageState extends State<TaskListPage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedFilter = 'All'; // Values: 'All', 'Pending', 'Completed'

//   @override
//   void initState() {
//     super.initState();
//     // Load tasks from SQLite via BLoC on initial build
//     context.read<TaskBloc>().add(LoadTasksEvent());
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // Toggle completion status with native haptic vibration, reminder management, and battery snackbar popup
//   void _toggleTaskStatus(TaskEntity task) async {
//     final isNowCompleted = task.isCompleted == 0;

//     final updatedTask = TaskEntity(
//       id: task.id,
//       title: task.title,
//       description: task.description,
//       createdAt: task.createdAt,
//       isCompleted: isNowCompleted ? 1 : 0,
//       priority: task.priority,
//       reminderDateTime: task.reminderDateTime,
//     );

//     // Update state in BLoC
//     context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));

//     if (isNowCompleted) {
//       // 1. Trigger native vibration via platform channel
//       await NativeBridge.triggerNativeHaptic();

//       // 2. Cancel pending reminder notification
//       if (task.id != null) {
//         await NotificationService.instance.cancelReminder(task.id!);
//       }

//       // 3. Fetch device battery percentage using native Kotlin/Swift
//       final battery = await NativeBridge.getBatteryLevel();

//       // 4. Show celebratory floating popup with battery details and dismiss button
//       if (mounted) {
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             backgroundColor: Colors.deepPurple.shade700,
//             duration: const Duration(seconds: 4),
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.greenAccent),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     battery != -1
//                         ? 'Task Completed! Battery: $battery%'
//                         : 'Task Completed Successfully!',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             action: SnackBarAction(
//               label: 'OK',
//               textColor: Colors.amberAccent,
//               onPressed: () {
//                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
//               },
//             ),
//           ),
//         );
//       }
//     } else {
//       // Reschedule notification if marked pending and reminder time is still in the future
//       if (task.id != null &&
//           task.reminderDateTime != null &&
//           task.reminderDateTime!.isNotEmpty) {
//         final scheduled = DateTime.tryParse(task.reminderDateTime!);
//         if (scheduled != null && scheduled.isAfter(DateTime.now())) {
//           await NotificationService.instance.scheduleTaskReminder(
//             id: task.id!,
//             title: task.title,
//             body: task.description,
//             scheduledDate: scheduled,
//           );
//         }
//       }
//     }
//   }

//   // Delete task and cancel its scheduled notification
//   void _deleteTask(TaskEntity task) async {
//     if (task.id != null) {
//       await NotificationService.instance.cancelReminder(task.id!);
//       if (mounted) {
//         context.read<TaskBloc>().add(DeleteTaskEvent(task.id!));
//       }
//     }
//   }

//   // Confirm delete dialog
//   Future<bool?> _showDeleteConfirmDialog(BuildContext context, TaskEntity task) {
//     return showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete Task'),
//         content: Text('Are you sure you want to delete "${task.title}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         title: const Text(
//           'PlanIt',
//           style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
//         ),
//         actions: [
//     BlocBuilder<ThemeCubit, ThemeMode>(
//       builder: (context, themeMode) {
//         final isDark = themeMode == ThemeMode.dark;
//         return IconButton(
//           icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
//           onPressed: () {
//             context.read<ThemeCubit>().toggleTheme();
//           },
//         );
//       },
//     ),
//   ],
//       ),
//       body: Column(
//         children: [
//           // Search input field
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search tasks...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() {});
//                         },
//                       )
//                     : null,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               onChanged: (_) => setState(() {}),
//             ),
//           ),

//           // Filter chips: All, Pending, Completed
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Row(
//               children: ['All', 'Pending', 'Completed'].map((filter) {
//                 final isSelected = _selectedFilter == filter;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8.0),
//                   child: FilterChip(
//                     label: Text(filter),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       if (selected) {
//                         setState(() {
//                           _selectedFilter = filter;
//                         });
//                       }
//                     },
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 6),

//           // Main task list view wrapped with BlocBuilder
//           Expanded(
//             child: BlocBuilder<TaskBloc, TaskState>(
//               builder: (context, state) {
//                 if (state is TaskLoadingState) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state is TaskErrorState) {
//                   return Center(child: Text(state.message));
//                 } else if (state is TaskLoadedState) {
//                   final query = _searchController.text.toLowerCase().trim();

//                   // Filter tasks based on query and filter chip
//                   final filteredTasks = state.tasks.where((task) {
//                     final matchesQuery = task.title.toLowerCase().contains(query) ||
//                         task.description.toLowerCase().contains(query);

//                     if (!matchesQuery) return false;

//                     if (_selectedFilter == 'Pending') {
//                       return task.isCompleted == 0;
//                     } else if (_selectedFilter == 'Completed') {
//                       return task.isCompleted == 1;
//                     }
//                     return true;
//                   }).toList();

//                   if (filteredTasks.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         'No tasks found',
//                         style: TextStyle(color: Colors.grey, fontSize: 16),
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     itemCount: filteredTasks.length,
//                     itemBuilder: (context, index) {
//                       final task = filteredTasks[index];

//                       return Dismissible(
//                         key: ValueKey(task.id ?? index),
//                         direction: DismissDirection.endToStart,
//                         background: Container(
//                           alignment: Alignment.centerRight,
//                           padding: const EdgeInsets.only(right: 20),
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 7,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.redAccent,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: const Icon(Icons.delete, color: Colors.white),
//                         ),
//                         confirmDismiss: (direction) =>
//                             _showDeleteConfirmDialog(context, task),
//                         onDismissed: (_) => _deleteTask(task),
//                         child: TaskItemCard(
//                           task: task,
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => AddEditTaskPage(task: task),
//                               ),
//                             );
//                           },
//                           onStatusChanged: (_) => _toggleTaskStatus(task),
//                           onDelete: () async {
//                             final confirm =
//                                 await _showDeleteConfirmDialog(context, task);
//                             if (confirm == true) {
//                               _deleteTask(task);
//                             }
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const AddEditTaskPage(),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }