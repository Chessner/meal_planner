import 'package:flutter/material.dart';

class EditDialog extends StatefulWidget {
  const EditDialog({super.key, required this.oldMeal});

  final String oldMeal;

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  String newName = '';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Edit"),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: TextEditingController(text: widget.oldMeal),
            onChanged: (value) {
              newName = value;
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(newName);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}