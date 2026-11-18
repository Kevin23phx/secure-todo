import 'package:flutter/material.dart';

import '../../domain/entities/todo.dart';

/// Dumb widget: receives a todo and callbacks, without depending on a bloc.
class TodoTile extends StatelessWidget {
  const TodoTile({required this.todo, required this.onToggle, required this.onDelete, super.key});
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      child: CheckboxListTile(
        value: todo.completed,
        onChanged: (_) => onToggle(),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(todo.title, style: todo.completed ? TextStyle(decoration: TextDecoration.lineThrough, color: theme.colorScheme.outline) : null),
      ),
    );
  }
}
