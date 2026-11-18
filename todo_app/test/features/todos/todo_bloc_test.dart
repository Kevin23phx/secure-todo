import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/core/error/failure.dart';
import 'package:todo_app/core/result/result.dart';
import 'package:todo_app/features/todos/domain/entities/todo.dart';
import 'package:todo_app/features/todos/domain/repositories/todo_repository.dart';
import 'package:todo_app/features/todos/domain/usecases/todo_usecases.dart';
import 'package:todo_app/features/todos/presentation/bloc/todo_bloc.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository repository;
  final milk = Todo(id: '1', title: 'Buy milk', completed: false, createdAt: DateTime(2026));
  final bread = Todo(id: '2', title: 'Buy bread', completed: true, createdAt: DateTime(2026));
  TodoBloc buildBloc() => TodoBloc(getTodos: GetTodos(repository), addTodo: AddTodo(repository), toggleTodo: ToggleTodo(repository), deleteTodo: DeleteTodo(repository));
  setUp(() => repository = MockTodoRepository());

  blocTest<TodoBloc, TodoState>(
    'loads todos successfully',
    setUp: () => when(() => repository.getTodos()).thenAnswer((_) async => Ok([milk, bread])),
    build: buildBloc,
    act: (bloc) => bloc.add(const TodosRequested()),
    expect: () => [const TodoState(status: TodoStatus.loading), TodoState(status: TodoStatus.success, todos: [milk, bread])],
  );

  blocTest<TodoBloc, TodoState>(
    'reports a load failure',
    setUp: () => when(() => repository.getTodos()).thenAnswer((_) async => const Err(NetworkFailure())),
    build: buildBloc,
    act: (bloc) => bloc.add(const TodosRequested()),
    expect: () => [const TodoState(status: TodoStatus.loading), const TodoState(status: TodoStatus.failure, failure: NetworkFailure())],
  );

  blocTest<TodoBloc, TodoState>(
    'trims a new title and inserts the returned todo first',
    setUp: () => when(() => repository.addTodo('Buy milk')).thenAnswer((_) async => Ok(milk)),
    build: buildBloc,
    seed: () => TodoState(status: TodoStatus.success, todos: [bread]),
    act: (bloc) => bloc.add(const TodoAdded(' Buy milk ')),
    expect: () => [TodoState(status: TodoStatus.success, todos: [milk, bread])],
    verify: (_) => verify(() => repository.addTodo('Buy milk')).called(1),
  );

  blocTest<TodoBloc, TodoState>(
    'optimistically toggles then accepts the server response',
    setUp: () => when(() => repository.updateTodo('1', completed: true)).thenAnswer((_) async => Ok(milk.copyWith(completed: true))),
    build: buildBloc,
    seed: () => TodoState(status: TodoStatus.success, todos: [milk]),
    act: (bloc) => bloc.add(TodoToggled(milk)),
    expect: () => [TodoState(status: TodoStatus.success, todos: [milk.copyWith(completed: true)])],
  );

  blocTest<TodoBloc, TodoState>(
    'rolls back an optimistic toggle if the API fails',
    setUp: () => when(() => repository.updateTodo('1', completed: true)).thenAnswer((_) async => const Err(NetworkFailure())),
    build: buildBloc,
    seed: () => TodoState(status: TodoStatus.success, todos: [milk]),
    act: (bloc) => bloc.add(TodoToggled(milk)),
    expect: () => [
      TodoState(status: TodoStatus.success, todos: [milk.copyWith(completed: true)]),
      TodoState(status: TodoStatus.success, todos: [milk], failure: const NetworkFailure()),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'rolls back a failed delete at its original position',
    setUp: () => when(() => repository.deleteTodo('1')).thenAnswer((_) async => const Err(ServerFailure())),
    build: buildBloc,
    seed: () => TodoState(status: TodoStatus.success, todos: [milk, bread]),
    act: (bloc) => bloc.add(TodoDeleted(milk)),
    expect: () => [
      TodoState(status: TodoStatus.success, todos: [bread]),
      TodoState(status: TodoStatus.success, todos: [milk, bread], failure: const ServerFailure()),
    ],
  );

  blocTest<TodoBloc, TodoState>(
    'deletes successfully',
    setUp: () => when(() => repository.deleteTodo('1')).thenAnswer((_) async => const Ok(null)),
    build: buildBloc,
    seed: () => TodoState(status: TodoStatus.success, todos: [milk, bread]),
    act: (bloc) => bloc.add(TodoDeleted(milk)),
    expect: () => [TodoState(status: TodoStatus.success, todos: [bread])],
  );

  blocTest<TodoBloc, TodoState>(
    'changes the visible-list filter',
    build: buildBloc,
    seed: () => TodoState(status: TodoStatus.success, todos: [milk, bread]),
    act: (bloc) => bloc.add(const TodoFilterChanged(TodoFilter.active)),
    expect: () => [TodoState(status: TodoStatus.success, todos: [milk, bread], filter: TodoFilter.active)],
  );

  test('derived visible todos and active count follow the filter', () {
    final state = TodoState(todos: [milk, bread]);
    expect(state.visibleTodos, [milk, bread]);
    expect(state.copyWith(filter: TodoFilter.active).visibleTodos, [milk]);
    expect(state.copyWith(filter: TodoFilter.completed).visibleTodos, [bread]);
    expect(state.activeCount, 1);
  });
}
