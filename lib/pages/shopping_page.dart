import 'package:flutter/material.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/shopping_ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:meal_planner/forms/dialogs/shopping_amount_create_dialog.dart';
import 'package:meal_planner/forms/dialogs/shopping_amount_edit_dialog.dart';
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
    return Consumer<MealPlannerDatabaseProvider>(
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
              return Scaffold(
                body: CustomScrollView(
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
                    ShoppingList(
                      shoppingIngredients: _shoppingIngredients,
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext builder) {
                        return ToAddShoppingList(
                          ignoredShoppingIngredients:
                              _shoppingIngredients.map((e) => e.item1).toList(),
                          onShoppingIngredientAdded: (sI) {
                            setState(() {
                              _shoppingIngredients.add(Tuple(sI, false));
                            });
                          },
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class ToAddShoppingList extends StatefulWidget {
  const ToAddShoppingList({
    super.key,
    required List<ShoppingIngredient> ignoredShoppingIngredients,
    required this.onShoppingIngredientAdded,
  }) : _ignoredShoppingIngredients = ignoredShoppingIngredients;
  final Function(ShoppingIngredient) onShoppingIngredientAdded;
  final List<ShoppingIngredient> _ignoredShoppingIngredients;

  @override
  State<ToAddShoppingList> createState() => _ToAddShoppingListState();
}

class _ToAddShoppingListState extends State<ToAddShoppingList> {
  List<ShoppingIngredient> _addableShoppingIngredients = [];
  List<ShoppingIngredient> _filteredAddableShoppingIngredients = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              _searchData(value);
            },
            decoration: const InputDecoration(
              labelText: 'Search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredAddableShoppingIngredients.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  _showShoppingCreateDialog(
                      context, _filteredAddableShoppingIngredients[index]);
                },
                title: Text(_filteredAddableShoppingIngredients[index].ingredient.name),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    Database database =
        await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
            .databaseHelper
            .database;
    ShoppingItemDao shoppingItemDao = ShoppingItemDao(database);
    IngredientDao ingredientDao = IngredientDao(database);
    final List<ShoppingItem> shoppingItems =
        await shoppingItemDao.getAllWithIdNotIn(
            widget._ignoredShoppingIngredients.map((e) => e.item.id!).toList());
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
    setState(() {
      _addableShoppingIngredients = shoppingIngredients;
      _filteredAddableShoppingIngredients = shoppingIngredients;
    });
  }

  void _searchData(String query) {
    if (query.isNotEmpty) {
      List<ShoppingIngredient> tmpList = [];
      for (ShoppingIngredient ingredient in _addableShoppingIngredients) {
        if (ingredient.ingredient.name.toLowerCase().contains(query.toLowerCase())) {
          tmpList.add(ingredient);
        }
      }

      setState(() {
        _filteredAddableShoppingIngredients = tmpList;
      });
    } else {
      setState(() {
        _filteredAddableShoppingIngredients = _addableShoppingIngredients;
      });
    }
  }

  void _showShoppingCreateDialog(
      BuildContext context, ShoppingIngredient shoppingIngredient) {
    showDialog<ShoppingItem>(
      context: context,
      builder: (BuildContext context) {
        return ShoppingAmountCreateDialog(
          shoppingIngredient: shoppingIngredient,
        );
      },
    ).then((item) {
      setState(() {
        _addableShoppingIngredients.remove(shoppingIngredient);
        _filteredAddableShoppingIngredients.remove(shoppingIngredient);
      });
      widget.onShoppingIngredientAdded(shoppingIngredient.copyWith(item: item));
    });
  }
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({
    super.key,
    required List<Tuple<ShoppingIngredient, bool>> shoppingIngredients,
  }) : _shoppingIngredients = shoppingIngredients;

  final List<Tuple<ShoppingIngredient, bool>> _shoppingIngredients;

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
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
                widget._shoppingIngredients[index].item2 = checked;
              },
            ),
            title:
                Text(widget._shoppingIngredients[index].item1.ingredient.name),
            subtitle: Text(widget
                ._shoppingIngredients[index].item1.ingredient.unit.name
                .toUpperCase()),
            trailing: AmountShowerEditor(
              shoppingIngredient: widget._shoppingIngredients[index].item1,
              onAmountEmpty: () {
                setState(() {
                  widget._shoppingIngredients.removeAt(index);
                });
              },
            ),
          );
        },
        childCount: widget._shoppingIngredients.length,
      ),
    );
  }
}

class AmountShowerEditor extends StatefulWidget {
  const AmountShowerEditor({
    super.key,
    required this.shoppingIngredient,
    required this.onAmountEmpty,
  });

  final Function onAmountEmpty;
  final ShoppingIngredient shoppingIngredient;

  @override
  State<AmountShowerEditor> createState() => _AmountShowerEditorState();
}

class _AmountShowerEditorState extends State<AmountShowerEditor> {
  late ShoppingIngredient shoppingIngredientState;
  bool initDone = false;

  @override
  Widget build(BuildContext context) {
    if (!initDone) {
      setState(() {
        initDone = true;
        shoppingIngredientState = widget.shoppingIngredient;
      });
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            shoppingIngredientState.item.amount.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    _showAmountEditDialog(
                      context,
                      AmountEdit.minus,
                      shoppingIngredientState,
                    );
                  },
                  icon: const Icon(Icons.remove)),
              const VerticalDivider(
                indent: 10,
                endIndent: 10,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showAmountEditDialog(
                    context,
                    AmountEdit.plus,
                    shoppingIngredientState,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAmountEditDialog(BuildContext context, AmountEdit editType,
      ShoppingIngredient shoppingIngredient) async {
    ShoppingItem? newItem = await showDialog<ShoppingItem?>(
      context: context,
      builder: (BuildContext context) {
        return ShoppingAmountEditDialog(
          editType: editType,
          shoppingIngredient: shoppingIngredient,
        );
      },
    );
    if (newItem != null) {
      if (newItem.amount <= 0) {
        widget.onAmountEmpty();
        return;
      }
      setState(() {
        shoppingIngredientState =
            shoppingIngredientState.copyWith(item: newItem);
      });
    }
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
