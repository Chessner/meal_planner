import 'package:flutter/material.dart';

class RandomMealDialog extends StatelessWidget {
  const RandomMealDialog({
    super.key,
    required this.meal,
  });

  final String meal;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const Text('Random meal:'), Text(meal)],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Add to calender >>"),
        )
      ],
    );
  }
}
