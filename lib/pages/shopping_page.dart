import 'package:flutter/material.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/shopping_ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database/meal_planner_database_provider.dart';
import '../forms/dialogs/checkbox_dialog.dart';
import '../widgets/meal_planner_app_bar.dart';

class ShoppingPage extends StatefulWidget {
  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  List<Tuple<ShoppingIngredient, bool>> _shoppingIngredients = [];
  bool _initialLoadDone = false;

  Future<void> _loadData(Future<Database> fDatabase) async {
    if (_initialLoadDone) return;
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
    _initialLoadDone = true;
    _shoppingIngredients =
        shoppingIngredients.map((e) => Tuple(e, false)).toList();
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
                    MealPlannerAppBar(
                      title: "Shopping List",
                      imagePath: "assets/shopping_carts.jpg",
                      actions: [
                        Card(
                          child: IconButton(
                            onPressed: () {
                              showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return const CheckBoxDialog();
                                },
                              ).then((result) async {
                                if (result != null && result) {
                                  ShoppingItemDao shoppingItemDao =
                                      ShoppingItemDao(await mDbProvider
                                          .databaseHelper.database);
                                  final checkedShoppingIngredients =
                                      _shoppingIngredients
                                          .where((element) => element.item2)
                                          .toList();
                                  for (var element
                                      in checkedShoppingIngredients) {
                                    await shoppingItemDao.setAmountTo(
                                      setTo: ShoppingItem.create(
                                          ingredientId:
                                              element.item1.item.ingredientId,
                                          amount: 0),
                                    );
                                  }
                                  setState(() {
                                    _shoppingIngredients
                                        .removeWhere((sI) => sI.item2);
                                  });
                                }
                              });
                            },
                            icon: const Icon(Icons.check_box),
                          ),
                        )
                      ],
                    ),
                    ShoppingList(shoppingIngredients: _shoppingIngredients),
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

class ShoppingList extends StatelessWidget {
  const ShoppingList({
    super.key,
    required List<Tuple<ShoppingIngredient, bool>> shoppingIngredients,
  }) : _shoppingIngredients = shoppingIngredients;

  final List<Tuple<ShoppingIngredient, bool>> _shoppingIngredients;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return ListTile(
            leading: ShoppingListCheckbox(
              initChecked: false,
              index: index,
              onCheckboxChanged: (index, checked) {
                _shoppingIngredients[index].item2 = checked;
              },
            ),
            title: Text(_shoppingIngredients[index].item1.ingredient.name),
            subtitle: Text(_shoppingIngredients[index]
                .item1
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
                    _shoppingIngredients[index].item1.item.amount.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.remove)),
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
    );
  }
}

typedef CheckboxChangedCallback = void Function(int index, bool isChecked);

class ShoppingListCheckbox extends StatefulWidget {
  final bool initChecked;
  final int index;
  final CheckboxChangedCallback onCheckboxChanged;

  const ShoppingListCheckbox(
      {super.key,
      required this.initChecked,
      required this.index,
      required this.onCheckboxChanged});

  @override
  State<ShoppingListCheckbox> createState() => _ShoppingListCheckboxState();
}

class _ShoppingListCheckboxState extends State<ShoppingListCheckbox> {
  bool checkedState = false;
  bool setupDone = false;

  @override
  Widget build(BuildContext context) {
    if (!setupDone) {
      setState(() {
        checkedState = widget.initChecked;
        setupDone = true;
      });
    }
    return Checkbox(
      value: checkedState,
      onChanged: (newBool) {
        setState(() {
          checkedState = newBool ?? false;
        });
        widget.onCheckboxChanged(widget.index, checkedState);
      },
    );
  }
}
