import 'package:flutter/material.dart';

class AddMealForm extends StatefulWidget {
  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  String mealName = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add meal'),
      content: TextField(
        onChanged: (value) {
          mealName = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(mealName); // Close the dialog
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}