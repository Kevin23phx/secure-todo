part of 'todo_bloc.dart';

enum TodoStatus { initial, loading, success, failure }
enum TodoFilter { all, active, completed }

class TodoState extends Equatable {
  const TodoState({this.status = TodoStatus.initial, this.todos = const [], this.filter = TodoFilter.all, this.failure});
  final TodoStatus status;
  final List<Todo> todos;
  final TodoFilter filter;
  final Failure? failure;

  List<Todo> get visibleTodos => switch (filter) {
        TodoFilter.all => todos,
        TodoFilter.active => todos.where((todo) => !todo.completed).toList(),
        TodoFilter.completed => todos.where((todo) => todo.completed).toList(),
      };
  int get activeCount => todos.where((todo) => !todo.completed).length;

  TodoState copyWith({TodoStatus? status, List<Todo>? todos, TodoFilter? filter, Failure? failure}) => TodoState(
        status: status ?? this.status,
        todos: todos ?? this.todos,
        filter: filter ?? this.filter,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, todos, filter, failure];
}
