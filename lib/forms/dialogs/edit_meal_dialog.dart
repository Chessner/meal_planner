import 'package:flutter/material.dart';

class EditMealDialog extends StatefulWidget {
  const EditMealDialog({super.key, required this.oldMeal});

  final String oldMeal;

  @override
  State<EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends State<EditMealDialog> {
  String _newName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SimpleDialog(
        title: const Text("Edit"),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              initialValue: widget.oldMeal,
              onSaved: (String? content) {
                print(content);
                _newName = content ?? "";
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
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.of(context).pop(_newName);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
