import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/calender_meal_form.dart';
import 'package:meal_planner/data/meal_ingredient.dart';
import 'package:meal_planner/database/meal_planner_database_provider.dart';
import 'package:meal_planner/toast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'data/ingredient.dart';
import 'data/meal.dart';
import 'data/tuple.dart';

class AddMealForm extends StatefulWidget {
  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();

  bool _isSubmitting = false;

  // form data
  String _mealName = "";
  List<Tuple<Ingredient, num>> _selectedIngredientsAndAmount = [];

  Future<Meal?> _onSubmit() async {
    if (_formKey.currentState == null) {
      MealPlannerToast.showLongToast("Something went wrong with the form");
      return null;
    }
    setState(() {
      _isSubmitting = true;
    });
    final formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();

      Database database =
          await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
              .databaseHelper
              .database;
      Meal dbMeal = await MealDao(database)
          .insertAndReturnMeal(Meal(id: null, name: _mealName));

      final List<MealIngredient> mealIngredients =
          _selectedIngredientsAndAmount.map((ingredientAndAmount) {
        return MealIngredient(
            ingredientId: ingredientAndAmount.item1.id!,
            mealId: dbMeal.id!,
            amount: ingredientAndAmount.item2);
      }).toList();
      await MealIngredientDao(database).insertMealIngredients(mealIngredients);
      setState(() {
        _isSubmitting = false;
      });
      return dbMeal;
    }
    setState(() {
      _isSubmitting = false;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        8,
                        0,
                      ),
                      child: Text(
                        "Add meal",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FormTextInputCard(
                      validator: (String? content) {
                        if (content == null || content.isEmpty) {
                          return 'Meal name cannot be empty';
                        }
                        return null;
                      },
                      onSaved: (name) {
                        _mealName = name ?? "";
                      },
                      title: "Name",
                      controller: _mealNameController,
                    ),
                    Consumer<MealPlannerDatabaseProvider>(
                      builder: (BuildContext context, db, Widget? child) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownSearch<Ingredient>(
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    hintText:
                                        "Search for and add ingredients!"),
                              ),
                              onBeforeChange:
                                  (oldIngredient, newIngredient) async {
                                setState(() {
                                  _selectedIngredientsAndAmount
                                      .add(Tuple(newIngredient!, 0));
                                });
                                return false;
                              },
                              popupProps: PopupProps.modalBottomSheet(
                                emptyBuilder: (context, filterString) {
                                  return const ListTile(
                                    title: Text("No ingredients found!"),
                                  );
                                },
                                searchFieldProps: const TextFieldProps(
                                  decoration: InputDecoration(
                                      hintText:
                                          "Search for and add ingredients!"),
                                ),
                                showSearchBox: true,
                                searchDelay: Duration.zero,
                              ),
                              enabled: true,
                              clearButtonProps: const ClearButtonProps(
                                isVisible: true,
                                icon: Icon(Icons.cancel_outlined),
                              ),
                              filterFn: (ingredient, filter) {
                                return ingredient.name.contains(filter);
                              },
                              asyncItems: (filterString) async {
                                List<Ingredient> ingredients =
                                    await db.databaseHelper.getAllIngredients();
                                return ingredients.where((ingredient) {
                                  return ingredient.name
                                          .contains(filterString) &&
                                      !_selectedIngredientsAndAmount.any(
                                          (element) =>
                                              element.item1.id ==
                                              ingredient.id);
                                }).toList();
                              },
                              compareFn: (ingredient1, ingredient2) {
                                return ingredient1.id! == ingredient2.id!;
                              },
                              itemAsString: (ingredient) {
                                return ingredient.name;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IngredientAmountList(
                      selectedIngredientsAndAmount:
                          _selectedIngredientsAndAmount,
                      deleteEntry: (index) {
                        setState(() {
                          _selectedIngredientsAndAmount.removeAt(index);
                        });
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 60
                          ? MediaQuery.of(context).viewInsets.bottom
                          : 60,
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text("Close"),
                    ),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              Meal? meal = await _onSubmit();
                              if (meal == null) {
                                MealPlannerToast.showLongToast(
                                    "Please check the form and make sure everything is filled out correctly");
                              } else {
                                Future.delayed(Duration.zero, () {
                                  Navigator.of(context)
                                      .pop(meal); // Close the dialog
                                });
                              }
                            },
                            child: const Text("Add"),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IngredientAmountList extends StatelessWidget {
  const IngredientAmountList({
    super.key,
    required List<Tuple<Ingredient, num>> selectedIngredientsAndAmount,
    required this.deleteEntry,
  }) : _selectedIngredientsAndAmount = selectedIngredientsAndAmount;

  final List<Tuple<Ingredient, num>> _selectedIngredientsAndAmount;
  final Function(int) deleteEntry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _selectedIngredientsAndAmount.isEmpty
            ? Row(
                children: [
                  Text(
                    "No meals added!",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    onDismissed: (_) {
                      deleteEntry(index);
                    },
                    direction: DismissDirection.startToEnd,
                    background: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ),
                    ),
                    key: Key(
                        _selectedIngredientsAndAmount[index].item1.toString()),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _selectedIngredientsAndAmount[index].item1.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              0,
                              8,
                              0,
                            ),
                            child: AmountInputField(
                              suffix: Ingredient.suffixOf(
                                  _selectedIngredientsAndAmount[index]
                                      .item1
                                      .unit),
                              onSaved: (String? amount) {
                                _selectedIngredientsAndAmount[index].item2 =
                                    double.parse(amount!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: _selectedIngredientsAndAmount.length,
              ),
      ),
    );
  }
}

class AmountInputField extends StatefulWidget {
  const AmountInputField({
    super.key,
    this.title,
    this.suffix,
    this.onSaved,
  });

  final String? title;
  final String? suffix;
  final void Function(String?)? onSaved;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title != null ? Text(widget.title!) : Container(),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: _globalKey,
                    //scrollPadding: EdgeInsets.only(
                    //    bottom: MediaQuery.of(context).viewInsets.bottom + 12),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 400));
                      Scrollable.ensureVisible(
                        _globalKey.currentContext!,
                        alignment: 0.3,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    decoration: InputDecoration(
                      errorMaxLines: 4,
                      suffixText: widget.suffix ?? "",
                    ),
                    initialValue: "0",
                    onSaved: widget.onSaved,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a number.";
                      }
                      if (double.tryParse(value.replaceAll(",", ".")) == null) {
                        return "Please enter a valid number.";
                      }
                      if (value == "0") {
                        return "Amount cannot be 0.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
