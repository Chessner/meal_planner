import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meal_planner/database/meal_planner_database_helper.dart';
import 'package:meal_planner/toast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/meal_planner_database_provider.dart';
import '../data/meal.dart';
import '../forms/add_meal_form.dart';
import '../forms/dialogs/edit_meal_dialog.dart';
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

  void _updateMeal(Meal oldMeal, String newMeal) async {
    Meal updatedMeal = oldMeal.copyWith(newName: newMeal);
    int index = _meals.indexOf(oldMeal);
    setState(() {
      _meals[index] = updatedMeal;
    });
    _updateDB(updatedMeal);
  }

  void _updateDB(Meal changedMeal) async {
    MealPlannerDatabaseHelper databaseHelper =
        Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
            .databaseHelper;
    Database database = await databaseHelper.database;
    await database.update("meal", changedMeal.toCompleteMap(),
        where: "id = ?", whereArgs: [changedMeal.id]);
  }

  final _myController = TextEditingController();

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
    int index = _rand.nextInt(_meals.length);
    Meal meal = _meals[index];
    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return RandomMealDialog(meal: meal);
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
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: 200.0,
                        actions: [
                          IconButton(
                              onPressed: _randomMeal,
                              icon: const Icon(Icons.lightbulb))
                        ],
                        backgroundColor: Theme.of(context).canvasColor,
                        flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(widget.title,
                              style: Theme.of(context).textTheme.titleLarge),
                          background: DecoratedBox(
                            position: DecorationPosition.foreground,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).canvasColor,
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                              ),
                            ),
                            child: Image.asset(
                              'assets/bee.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _onEdit(_meals[index]);
                                  },
                                ),
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
          _showAddMealFormDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onEdit(Meal oldMeal) {
    showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return EditMealDialog(
          oldMeal: oldMeal.name,
        );
      },
    ).then(
      (newMealName) => {
        print(newMealName),
        print(oldMeal.name),
        if (newMealName != null)
          {
            if (newMealName.isNotEmpty)
              {
                if (newMealName == oldMeal.name)
                  {
                    MealPlannerToast.showShortToast("Meal remained unchanged"),
                  }
                else
                  {
                    _updateMeal(oldMeal, newMealName),
                  }
              }
            else
              {
                MealPlannerToast.showLongToast(
                    "Did not save, because meal name was empty"),
              },
          }
        else
          {
            MealPlannerToast.showShortToast("Canceled"),
          },
      },
    );
  }

  void _showAddMealFormDialog(BuildContext context) {
    showModalBottomSheet<Meal?>(
      elevation: 5,
      context: context,
      builder: (BuildContext context) {
        return AddMealForm();
      },
    ).then((value) {
      if (value != null) {
        _addMeal(value);
      }
    });
  }
}
