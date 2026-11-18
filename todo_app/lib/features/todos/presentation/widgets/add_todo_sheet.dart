import 'package:flutter/material.dart';

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});
  static Future<String?> show(BuildContext context) => showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddTodoSheet(),
      );

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _controller = TextEditingController();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) Navigator.of(context).pop(title);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Row(children: [
          Expanded(child: TextField(controller: _controller, autofocus: true, maxLength: 200, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(hintText: 'What needs to be done?', counterText: ''), onSubmitted: (_) => _submit())),
          const SizedBox(width: 12),
          IconButton.filled(onPressed: _submit, icon: const Icon(Icons.check)),
        ]),
      );
}
