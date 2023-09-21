import 'package:flutter/material.dart';

import '../../data/meal.dart';
import '../calender_meal_form.dart';

class RandomMealDialog extends StatelessWidget {
  const RandomMealDialog({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const Text('Random meal:'), Text(meal.name)],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CalenderMealForm(
                  meal: meal,
                ),
              ),
            );
          },
          child: const Text("Add to calender >>"),
        )
      ],
    );
  }
}
