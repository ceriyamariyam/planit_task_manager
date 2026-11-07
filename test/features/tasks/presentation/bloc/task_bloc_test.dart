import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:offline_task_manager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:offline_task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:offline_task_manager/features/tasks/presentation/bloc/task_event.dart';
import 'package:offline_task_manager/features/tasks/presentation/bloc/task_state.dart';

// Mock all domain use cases using mocktail
class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}
class MockAddTaskUseCase extends Mock implements AddTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  late TaskBloc taskBloc;
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockAddTaskUseCase = MockAddTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();

    taskBloc = TaskBloc(
      getTasksUseCase: mockGetTasksUseCase,
      addTaskUseCase: mockAddTaskUseCase,
      updateTaskUseCase: mockUpdateTaskUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
    );
  });

  tearDown(() {
    taskBloc.close();
  });

  const tTask = TaskEntity(
    id: 1,
    title: 'Test PlanIt Task',
    description: 'Unit testing presentation BLoC',
    createdAt: '2026-11-07 10:00',
    isCompleted: 0,
    priority: 'High',
    reminderDateTime: '2026-11-07T18:00:00.000',
  );

  final List<TaskEntity> tTaskList = [tTask];

  test('initial state should be TaskInitialState', () {
    expect(taskBloc.state, equals(TaskInitialState()));
  });

  group('LoadTasksEvent', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoadingState, TaskLoadedState] when tasks are loaded successfully',
      build: () {
        when(() => mockGetTasksUseCase()).thenAnswer((_) async => tTaskList);
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasksEvent()),
      expect: () => [
        TaskLoadingState(),
        TaskLoadedState(tTaskList),
      ],
      verify: (_) {
        verify(() => mockGetTasksUseCase()).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoadingState, TaskErrorState] when loading tasks fails',
      build: () {
        when(() => mockGetTasksUseCase()).thenThrow(Exception('Database fetch failure'));
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasksEvent()),
      expect: () => [
        TaskLoadingState(),
        isA<TaskErrorState>(),
      ],
      verify: (_) {
        verify(() => mockGetTasksUseCase()).called(1);
      },
    );
  });

  group('AddTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
      'calls AddTaskUseCase and triggers LoadTasksEvent on success',
      build: () {
        when(() => mockAddTaskUseCase(tTask)).thenAnswer((_) async {});
        when(() => mockGetTasksUseCase()).thenAnswer((_) async => tTaskList);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const AddTaskEvent(tTask)),
      expect: () => [
        TaskLoadingState(),
        TaskLoadedState(tTaskList),
      ],
      verify: (_) {
        verify(() => mockAddTaskUseCase(tTask)).called(1);
        verify(() => mockGetTasksUseCase()).called(1);
      },
    );
  });

  group('DeleteTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
      'calls DeleteTaskUseCase and refreshes list on success',
      build: () {
        when(() => mockDeleteTaskUseCase(1)).thenAnswer((_) async {});
        when(() => mockGetTasksUseCase()).thenAnswer((_) async => []);
        return taskBloc;
      },
      act: (bloc) => bloc.add(const DeleteTaskEvent(1)),
      expect: () => [
        TaskLoadingState(),
        const TaskLoadedState([]),
      ],
      verify: (_) {
        verify(() => mockDeleteTaskUseCase(1)).called(1);
        verify(() => mockGetTasksUseCase()).called(1);
      },
    );
  });
}