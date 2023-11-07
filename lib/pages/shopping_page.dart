import 'package:flutter/material.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/shopping_ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/meal_planner_database_provider.dart';
import '../widgets/meal_planner_app_bar.dart';

class ShoppingPage extends StatefulWidget {
  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  List<ShoppingIngredient> _shoppingIngredients = [];

  Future<void> _loadData(Future<Database> fDatabase) async {
    Database database = await fDatabase;
    ShoppingItemDao shoppingItemDao = ShoppingItemDao(database);
    IngredientDao ingredientDao = IngredientDao(database);
    final List<ShoppingItem> shoppingItems =
        await shoppingItemDao.getAllWithAmountGreater0();
    final List<ShoppingIngredient> shoppingIngredients = await Future.wait(
      shoppingItems.map(
        (sI) async {
          return ShoppingIngredient(
            item: sI,
            ingredient: await ingredientDao.getIngredient(sI.ingredientId),
          );
        },
      ),
    );
    _shoppingIngredients = shoppingIngredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealPlannerDatabaseProvider>(
        builder: (BuildContext context, MealPlannerDatabaseProvider mDbProvider,
            Widget? child) {
          return FutureBuilder<void>(
            future: _loadData(mDbProvider.databaseHelper.database),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CustomScrollView(
                  slivers: [
                    const MealPlannerAppBar(
                      title: "Shopping List",
                      imagePath: "assets/shopping_carts.jpg",
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return ListTile(
                            leading: Checkbox(
                              value: false,
                              onChanged: (_) {},
                            ),
                            title: Text(
                                _shoppingIngredients[index].ingredient.name),
                            subtitle: Text(_shoppingIngredients[index]
                                .ingredient
                                .unit
                                .name
                                .toUpperCase()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _shoppingIngredients[index]
                                        .item
                                        .amount
                                        .toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Card(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.remove)),
                                      const VerticalDivider(
                                        indent: 10,
                                        endIndent: 10,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: _shoppingIngredients.length,
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
