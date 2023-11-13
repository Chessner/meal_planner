import 'package:flutter/material.dart';
import 'package:meal_planner/forms/dialogs/ingredient_form_dialog.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/widgets/meal_planner_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/meal_planner_database_provider.dart';

class IngredientsPage extends StatefulWidget {
  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<Ingredient> _ingredients = [];

  _showIngredientDialog(
      {required BuildContext context,
      Ingredient? ingredient,
      required String title}) async {
    final resultingIngredient = await showDialog<Ingredient?>(
      context: context,
      builder: (BuildContext context) {
        return IngredientDialog(
          ingredient: ingredient,
          title: title,
        );
      },
    );
    if (resultingIngredient != null) {
      setState(() {
        _ingredients.add(resultingIngredient);
      });
    }
  }

  Future<List<Ingredient>> _loadData(Future<Database> database) async {
    return IngredientDao(await database).getAllIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealPlannerDatabaseProvider>(
        builder: (BuildContext context, MealPlannerDatabaseProvider mDbProvider,
            Widget? child) {
          return FutureBuilder<List<Ingredient>>(
            future: _loadData(mDbProvider.databaseHelper.database),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                _ingredients = snapshot.data!;
                return CustomScrollView(
                  slivers: [
                    const MealPlannerAppBar(
                      title: "Ingredients",
                      imagePath: "assets/vegetable_isle.jpg",
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Dismissible(
                            key: Key(_ingredients[index].id.toString()),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) async {
                              IngredientDao(
                                      await mDbProvider.databaseHelper.database)
                                  .deleteIngredient(_ingredients[index]);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                            ),
                            child: ListTile(
                              title: Text(_ingredients[index].name),
                              subtitle: Text(
                                  _ingredients[index].unit.name.toUpperCase()),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showIngredientDialog(
                                      context: context,
                                      ingredient: _ingredients[index],
                                      title: "Edit an ingredient");
                                },
                              ),
                            ),
                          );
                        },
                        childCount: _ingredients.length,
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 56.0),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showIngredientDialog(
              context: context, title: "Create a new ingredient");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
