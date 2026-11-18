import 'package:dio/dio.dart';

import '../models/todo_model.dart';

class TodoRemoteDataSource {
  const TodoRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<TodoModel>> getTodos() async {
    final response = await _dio.get<Map<String, dynamic>>('/todos', queryParameters: {'limit': 100});
    final items = response.data!['data'] as List<dynamic>;
    return [for (final item in items) TodoModel.fromJson(item as Map<String, dynamic>)];
  }

  Future<TodoModel> addTodo(String title) async {
    final response = await _dio.post<Map<String, dynamic>>('/todos', data: {'title': title});
    return _parse(response);
  }

  Future<TodoModel> updateTodo(String id, {String? title, bool? completed}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/todos/$id',
      data: {'title': ?title, 'completed': ?completed},
    );
    return _parse(response);
  }

  Future<void> deleteTodo(String id) => _dio.delete<void>('/todos/$id');

  TodoModel _parse(Response<Map<String, dynamic>> response) =>
      TodoModel.fromJson(response.data!['data'] as Map<String, dynamic>);
}
