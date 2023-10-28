import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/meal.dart';
import '../calender_meal_form.dart';

class RandomMealDialog extends StatefulWidget {
  const RandomMealDialog({
    super.key,
    required this.meals,
    required this.random,
  });

  final List<Meal> meals;
  final Random random;

  @override
  State<RandomMealDialog> createState() => _RandomMealDialogState();
}

class _RandomMealDialogState extends State<RandomMealDialog> {
  bool _initMealChosen = false;
  late Meal _meal;
  late List<Meal> _meals;
  MaterialStatesController _nextButtonController = MaterialStatesController();

  Meal _randomMeal() {
    int index = widget.random.nextInt(_meals.length);
    return _meals[index];
  }

  @override
  Widget build(BuildContext context) {
    if (!_initMealChosen) {
      _meals = widget.meals.toList();
      setState(() {
        _meal = _randomMeal();
        _meals.remove(_meal);
        _initMealChosen = true;
      });
    }
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const Text('Random meal:'), Text(_meal.name)],
        ),
      ),
      actions: [
        ElevatedButton(
            statesController: _nextButtonController,
            onPressed: _meals.isEmpty
                ? null
                : () {
                    Meal newMeal = _randomMeal();
                    while (newMeal.id == _meal.id && _meals.isNotEmpty) {
                      newMeal = _randomMeal();
                    }
                    setState(() {
                      _meals.remove(newMeal);
                      _meal = newMeal;
                    });
                  },
            child: const Text("Next")),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CalenderMealForm(
                  meal: _meal,
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
