import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';

/// Widget TodoTile terpisah agar kode build lebih pendek, rapi, dan mudah diuji
class TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.done,
        onChanged: onToggle,
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
          color: todo.done ? Colors.grey : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Hapus Tugas',
        onPressed: onDelete,
      ),
    );
  }
}
