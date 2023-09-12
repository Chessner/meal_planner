import 'package:flutter/material.dart';
import 'package:meal_planner/add_ingredient_view.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:provider/provider.dart';

import '../database/meal_planner_database_provider.dart';

class IngredientsPage extends StatefulWidget {
  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<String> _ingredients = [];

  _showAddIngredientDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddIngredientView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealPlannerDatabaseProvider>(
        builder: (BuildContext context, MealPlannerDatabaseProvider mDbProvider,
            Widget? child) {
          return FutureBuilder<List<Ingredient>>(
            future: mDbProvider.databaseHelper.getAllIngredients(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 200.0,
                      backgroundColor: Theme.of(context).canvasColor,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text("Ingredients",
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
                            key: Key(_ingredients[index]),
                            direction: DismissDirection.startToEnd,
                            onUpdate: (details) {
                              print("onUpdate ${details.progress}");
                            },
                            onResize: () {
                              print("onResize");
                            },
                            onDismissed: (direction) {
                              print("onDismissed $direction");
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
                              title: Text(_ingredients[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                        childCount: _ingredients.length,
                      ),
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
          _showAddIngredientDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
