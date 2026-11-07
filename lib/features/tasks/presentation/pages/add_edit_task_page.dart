import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class AddEditTaskPage extends StatefulWidget {
  final TaskEntity? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String _priority = 'Medium';
  DateTime? _selectedReminderDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 'Medium';

    // Parse reminder date time from existing entity
    final reminder = widget.task?.reminderDateTime;
    if (reminder != null && reminder.trim().isNotEmpty) {
      final trimmed = reminder.trim();
      _selectedReminderDateTime = DateTime.tryParse(trimmed);
      if (_selectedReminderDateTime == null) {
        try {
          _selectedReminderDateTime =
              DateFormat('yyyy-MM-dd HH:mm').parse(trimmed);
        } catch (_) {
          _selectedReminderDateTime = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Pick date and time sequentially and update state
  Future<void> _pickReminderDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedReminderDateTime != null
          ? TimeOfDay.fromDateTime(_selectedReminderDateTime!)
          : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedReminderDateTime = combinedDateTime;
    });

    debugPrint('Selected Reminder Time: $_selectedReminderDateTime');
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Convert to ISO 8601 string representation
    final String? reminderString =
        _selectedReminderDateTime?.toIso8601String();

    debugPrint('Saving Task: Title = ${_titleController.text}, Reminder = $reminderString');

    final nowString = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final isEditing = widget.task != null;

    final int taskId = isEditing
        ? widget.task!.id!
        : (DateTime.now().millisecondsSinceEpoch % 1000000);

    final task = TaskEntity(
      id: taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: widget.task?.createdAt ?? nowString,
      isCompleted: widget.task?.isCompleted ?? 0,
      priority: _priority,
      reminderDateTime: reminderString,
    );

    if (isEditing) {
      context.read<TaskBloc>().add(UpdateTaskEvent(task));
    } else {
      context.read<TaskBloc>().add(AddTaskEvent(task));
    }

    // Cancel existing reminder if any
    NotificationService.instance.cancelReminder(taskId);

    // Schedule notification if reminder time is in future
    if (_selectedReminderDateTime != null &&
        _selectedReminderDateTime!.isAfter(DateTime.now()) &&
        task.isCompleted == 0) {
      NotificationService.instance.scheduleTaskReminder(
        id: taskId,
        title: task.title,
        body: task.description,
        scheduledDate: _selectedReminderDateTime!,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(isEditing ? 'Edit Task' : 'Add New Task',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Low', 'Medium', 'High'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Reminder Selector Card
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: const Icon(Icons.alarm, color: Colors.deepPurple),
                  title: Text(
                    _selectedReminderDateTime == null
                        ? 'Set Reminder (Optional)'
                        : DateFormat('dd MMM yyyy, hh:mm a')
                            .format(_selectedReminderDateTime!),
                    style: TextStyle(
                      fontWeight: _selectedReminderDateTime == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: _selectedReminderDateTime == null
                          ? Colors.grey.shade700
                          : Colors.deepPurple,
                    ),
                  ),
                  subtitle: _selectedReminderDateTime != null
                      ? const Text(
                          'Tap to change time',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : null,
                  trailing: _selectedReminderDateTime != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _selectedReminderDateTime = null;
                            });
                          },
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _pickReminderDateTime,
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update Task' : 'Save Task',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/services/notification_service.dart';
// import '../../domain/entities/task_entity.dart';
// import '../bloc/task_bloc.dart';
// import '../bloc/task_event.dart';

// class AddEditTaskPage extends StatefulWidget {
//   final TaskEntity? task;

//   const AddEditTaskPage({super.key, this.task});

//   @override
//   State<AddEditTaskPage> createState() => _AddEditTaskPageState();
// }

// class _AddEditTaskPageState extends State<AddEditTaskPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;

//   String _priority = 'Medium';
//   DateTime? _selectedReminderDateTime;

// @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task?.title ?? '');
//     _descriptionController =
//         TextEditingController(text: widget.task?.description ?? '');
//     _priority = widget.task?.priority ?? 'Medium';

//     // Parse reminder time safely supporting both ISO string and custom formats
//     final reminder = widget.task?.reminderDateTime;
//     if (reminder != null && reminder.trim().isNotEmpty) {
//       final trimmed = reminder.trim();
      
//       // 1. Try standard ISO parse
//       _selectedReminderDateTime = DateTime.tryParse(trimmed);

//       // 2. Fallback to common date formats if ISO parse returns null
//       if (_selectedReminderDateTime == null) {
//         final formats = [
//           DateFormat('yyyy-MM-dd HH:mm'),
//           DateFormat('dd MMM yyyy, hh:mm a'),
//           DateFormat('yyyy-MM-ddTHH:mm:ss'),
//         ];

//         for (final format in formats) {
//           try {
//             _selectedReminderDateTime = format.parse(trimmed);
//             break;
//           } catch (_) {}
//         }
//       }
//     }
//   }
 

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   // Date and Time picker
//   Future<void> _pickReminderDateTime() async {
//     final DateTime now = DateTime.now();
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedReminderDateTime ?? now,
//       firstDate: now,
//       lastDate: DateTime(now.year + 5),
//     );

//     if (pickedDate == null) return;

//     if (!mounted) return;
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _selectedReminderDateTime != null
//           ? TimeOfDay.fromDateTime(_selectedReminderDateTime!)
//           : TimeOfDay.now(),
//     );

//     if (pickedTime == null) return;

//     setState(() {
//       _selectedReminderDateTime = DateTime(
//         pickedDate.year,
//         pickedDate.month,
//         pickedDate.day,
//         pickedTime.hour,
//         pickedTime.minute,
//       );
//     });
//   }

// void _saveTask() {
//     if (!_formKey.currentState!.validate()) return;

//     // Save as standard ISO-8601 string
//     final String? reminderString =
//         _selectedReminderDateTime?.toIso8601String();

//     final nowString = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
//     final isEditing = widget.task != null;

//     final int taskId = isEditing
//         ? widget.task!.id!
//         : (DateTime.now().millisecondsSinceEpoch % 1000000);

//     final task = TaskEntity(
//       id: taskId,
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       createdAt: widget.task?.createdAt ?? nowString,
//       isCompleted: widget.task?.isCompleted ?? 0,
//       priority: _priority,
//       reminderDateTime: reminderString,
//     );

//     if (isEditing) {
//       context.read<TaskBloc>().add(UpdateTaskEvent(task));
//     } else {
//       context.read<TaskBloc>().add(AddTaskEvent(task));
//     }

//     NotificationService.instance.cancelReminder(taskId);

//     if (_selectedReminderDateTime != null &&
//         _selectedReminderDateTime!.isAfter(DateTime.now()) &&
//         task.isCompleted == 0) {
//       NotificationService.instance.scheduleTaskReminder(
//         id: taskId,
//         title: task.title,
//         body: task.description,
//         scheduledDate: _selectedReminderDateTime!,
//       );
//     }

//     Navigator.pop(context);
//   }
//   // void _saveTask() {
//   //   if (!_formKey.currentState!.validate()) return;

//   //   // Save as clean ISO8601 string
//   //   final String? reminderString =
//   //       _selectedReminderDateTime?.toIso8601String();

//   //   final nowString = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
//   //   final isEditing = widget.task != null;

//   //   final int taskId = isEditing
//   //       ? widget.task!.id!
//   //       : (DateTime.now().millisecondsSinceEpoch % 1000000);

//   //   final task = TaskEntity(
//   //     id: taskId,
//   //     title: _titleController.text.trim(),
//   //     description: _descriptionController.text.trim(),
//   //     createdAt: widget.task?.createdAt ?? nowString,
//   //     isCompleted: widget.task?.isCompleted ?? 0,
//   //     priority: _priority,
//   //     reminderDateTime: reminderString,
//   //   );

//   //   if (isEditing) {
//   //     context.read<TaskBloc>().add(UpdateTaskEvent(task));
//   //   } else {
//   //     context.read<TaskBloc>().add(AddTaskEvent(task));
//   //   }

//   //   // Cancel old notification
//   //   NotificationService.instance.cancelReminder(taskId);

//   //   // Schedule notification if reminder time is in future
//   //   if (_selectedReminderDateTime != null &&
//   //       _selectedReminderDateTime!.isAfter(DateTime.now()) &&
//   //       task.isCompleted == 0) {
//   //     NotificationService.instance.scheduleTaskReminder(
//   //       id: taskId,
//   //       title: task.title,
//   //       body: task.description,
//   //       scheduledDate: _selectedReminderDateTime!,
//   //     );
//   //   }

//   //   Navigator.pop(context);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.task != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(
//                   labelText: 'Task Title',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter a task title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Description (Optional)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _priority,
//                 decoration: InputDecoration(
//                   labelText: 'Priority',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 items: ['Low', 'Medium', 'High'].map((priority) {
//                   return DropdownMenuItem(
//                     value: priority,
//                     child: Text(priority),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() {
//                       _priority = value;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Reminder Selection Tile
//               Card(
//                 elevation: 0,
//                 color: Colors.grey.shade100,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 child: ListTile(
//                   leading: const Icon(Icons.alarm, color: Colors.deepPurple),
//                   title: Text(
//                     _selectedReminderDateTime == null
//                         ? 'Set Reminder (Optional)'
//                         : DateFormat('dd MMM yyyy, hh:mm a')
//                             .format(_selectedReminderDateTime!),
//                     style: TextStyle(
//                       fontWeight: _selectedReminderDateTime == null
//                           ? FontWeight.normal
//                           : FontWeight.bold,
//                       color: _selectedReminderDateTime == null
//                           ? Colors.grey.shade700
//                           : Colors.deepPurple,
//                     ),
//                   ),
//                   subtitle: _selectedReminderDateTime != null
//                       ? const Text(
//                           'Tap to change time',
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         )
//                       : null,
//                   trailing: _selectedReminderDateTime != null
//                       ? IconButton(
//                           icon: const Icon(Icons.clear, color: Colors.redAccent),
//                           onPressed: () {
//                             setState(() {
//                               _selectedReminderDateTime = null;
//                             });
//                           },
//                         )
//                       : const Icon(Icons.arrow_forward_ios, size: 16),
//                   onTap: _pickReminderDateTime,
//                 ),
//               ),
//               const SizedBox(height: 30),

//               ElevatedButton(
//                 onPressed: _saveTask,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   isEditing ? 'Update Task' : 'Save Task',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }