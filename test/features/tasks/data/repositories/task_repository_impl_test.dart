import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:offline_task_manager/features/tasks/data/datasources/task_repository_impl.dart';
import 'package:offline_task_manager/features/tasks/data/models/task_model.dart';
import 'package:offline_task_manager/features/tasks/domain/entities/task_entity.dart';

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(const TaskModel(
      id: 0,
      title: '',
      description: '',
      createdAt: '',
      isCompleted: 0,
      priority: 'Low',
    ));
  });

  setUp(() {
    mockLocalDataSource = MockTaskLocalDataSource();
    repository = TaskRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const tTaskEntity = TaskEntity(
    id: 101,
    title: 'Repo Test Task',
    description: 'Verifying Clean Architecture repository implementation',
    createdAt: '2026-11-07 11:00',
    isCompleted: 0,
    priority: 'Medium',
    reminderDateTime: '2026-11-07T19:30:00.000',
  );

  final tTaskModel = TaskModel.fromEntity(tTaskEntity);

  test('getTasks should return list of TaskEntity from local data source', () async {
    when(() => mockLocalDataSource.getTasks()).thenAnswer((_) async => [tTaskModel]);

    final result = await repository.getTasks();

    expect(result, equals([tTaskModel]));
    verify(() => mockLocalDataSource.getTasks()).called(1);
  });

  test('addTask should pass mapped TaskModel to local data source', () async {
    when(() => mockLocalDataSource.insertTask(any())).thenAnswer((_) async => 1);

    await repository.addTask(tTaskEntity);

    verify(() => mockLocalDataSource.insertTask(tTaskModel)).called(1);
  });

  test('deleteTask should forward id to local data source', () async {
    when(() => mockLocalDataSource.deleteTask(101)).thenAnswer((_) async {});

    await repository.deleteTask(101);

    verify(() => mockLocalDataSource.deleteTask(101)).called(1);
  });
}