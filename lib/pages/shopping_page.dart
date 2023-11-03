import 'package:flutter/material.dart';
import 'package:meal_planner/data/ingredient.dart';
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
  List<ShoppingItem> _shoppingItems = [];

  Future<List<ShoppingItem>> _loadData(Future<Database> database) async {
    return [
      ShoppingItem.create(
          ingredient: Ingredient.create(
              name: "Zwiebel", unit: Unit.pieces, includeInShopping: true),
          amount: 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealPlannerDatabaseProvider>(
        builder: (BuildContext context, MealPlannerDatabaseProvider mDbProvider,
            Widget? child) {
          return FutureBuilder<List<ShoppingItem>>(
            future: _loadData(mDbProvider.databaseHelper.database),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                _shoppingItems = snapshot.data!;
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
                            title: Text(_shoppingItems[index].ingredient.name),
                            subtitle: Text(_shoppingItems[index]
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
                                    _shoppingItems[index].amount.toString(),
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
                        childCount: _shoppingItems.length,
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
