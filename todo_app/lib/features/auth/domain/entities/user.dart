import 'package:equatable/equatable.dart';

/// Domain user: independent of JSON, Flutter, and networking.
class User extends Equatable {
  const User({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;

  @override
  List<Object?> get props => [id, name, email];
}
