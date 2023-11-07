import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/meal_ingredient.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:meal_planner/database/meal_planner_database_helper.dart';
import 'package:meal_planner/widgets/meal_planner_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/meal_planner_database_provider.dart';
import '../data/meal.dart';
import '../forms/calender_meal_form.dart';
import '../forms/meal_form.dart';
import '../forms/dialogs/random_meal_dialog.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key, required this.title});

  final String title;

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<Meal> _meals = [];
  Random _rand = Random();
  final _myController = TextEditingController();

  void _addMeal(Meal meal) {
    setState(() {
      _meals.add(meal);
    });
  }

  void _removeMeal(Meal meal) async {
    setState(() {
      _meals.remove(meal);
    });
    MealPlannerDatabaseHelper databaseHelper =
        Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
            .databaseHelper;
    Database database = await databaseHelper.database;
    await database.delete("meal", where: "id = ?", whereArgs: [meal.id]);
  }

  void _updateMeal(Meal oldMeal, Meal newMeal) async {
    int index = _meals.indexOf(oldMeal);
    setState(() {
      _meals[index] = newMeal;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myController.dispose();
    super.dispose();
  }

  void _randomMeal() {
    if (_meals.isEmpty) {
      Fluttertoast.showToast(
        msg: "The list is empty. Please add some meals and try again!",
        fontSize: 16,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return RandomMealDialog(
          meals: _meals,
          random: _rand,
        );
      },
    );
  }

  Future<List<Meal>> _loadData(Future<Database> database) async {
    return MealDao(await database).getAllMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealPlannerDatabaseProvider>(
        builder: (context, databaseProvider, child) {
          return FutureBuilder<List<Meal>>(
              future: _loadData(databaseProvider.databaseHelper.database),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Meal> meals = snapshot.data!;
                  _meals = meals;
                  return CustomScrollView(
                    slivers: [
                      MealPlannerAppBar(
                        title: "Meals",
                        imagePath: "assets/family_meal.jpg",
                        actions: [
                          Card(
                            child: IconButton(
                                onPressed: _randomMeal,
                                icon: const Icon(Icons.lightbulb)),
                          )
                        ],
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Dismissible(
                              key: Key(_meals[index].toString()),
                              direction: DismissDirection.startToEnd,
                              onDismissed: (direction) {
                                _removeMeal(_meals[index]);
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: ListTile(
                                title: Text(_meals[index].name),
                                trailing: _buildMealButtonBar(
                                    context, index, databaseProvider),
                              ),
                            );
                          },
                          childCount: _meals.length,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text('No data available');
                }
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMealForm(context: context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealButtonBar(BuildContext context, int index,
      MealPlannerDatabaseProvider databaseProvider) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CalenderMealForm(
                    meal: _meals[index],
                  ),
                ),
              );
            },
          ),
          const VerticalDivider(
            indent: 10,
            endIndent: 10,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Database db = await databaseProvider.databaseHelper.database;
              final mealIngredientDao = MealIngredientDao(db);
              final mealIngredients = await mealIngredientDao
                  .getMealIngredientsOfMeal(_meals[index].id ?? -1);

              final ingredientDao = IngredientDao(db);
              final List<Tuple<Ingredient, num>> ingredientsAmount =
                  await Future.wait(
                mealIngredients.map((mI) async {
                  Ingredient ingredient =
                      await ingredientDao.getIngredient(mI.ingredientId);
                  return Tuple(ingredient, mI.amount);
                }).toList(),
              );
              if (context.mounted) {
                _showMealForm(
                    context: context,
                    meal: _meals[index],
                    ingredients: ingredientsAmount);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMealForm(
      {required BuildContext context,
      Meal? meal,
      List<Tuple<Ingredient, num>>? ingredients}) {
    showModalBottomSheet<Meal?>(
      enableDrag: true,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      elevation: 5,
      context: context,
      builder: (BuildContext context) {
        return MealForm(
          givenMeal: meal,
          givenIngredientsAmount: ingredients,
        );
      },
    ).then((resultMeal) {
      if (resultMeal != null) {
        if (meal != null) {
          _updateMeal(meal, resultMeal);
        } else {
          _addMeal(resultMeal);
        }
      }
    });
  }
}
