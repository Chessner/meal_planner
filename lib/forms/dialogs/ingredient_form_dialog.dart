import 'package:flutter/material.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';
import 'package:meal_planner/database/meal_planner_database_provider.dart';
import 'package:provider/provider.dart';

import '../form_text_input_card.dart';

class IngredientDialog extends StatefulWidget {
  IngredientDialog({this.ingredient, required this.title});

  final Ingredient? ingredient;
  final String title;

  @override
  State<IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  Unit? _chosenUnit;
  String _chosenName = "";
  bool? _shoppable;

  void _submit() async {
    setState(() {
      _isSubmitting = true;
    });
    final formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();

      var database =
          await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
              .databaseHelper
              .database;
      final ingredientDao = IngredientDao(database);

      Ingredient submittedIngredient;

      if (widget.ingredient != null) {
        //update
        submittedIngredient = widget.ingredient!.copyWith(
            name: _chosenName,
            unit: _chosenUnit,
            includeInShopping: _shoppable ?? true);

        await ingredientDao.updateIngredient(submittedIngredient);
      } else {
        //insert
        int id = await ingredientDao.insertIngredient(Ingredient.create(
            name: _chosenName,
            unit: _chosenUnit,
            includeInShopping: _shoppable ?? true));
        submittedIngredient = await ingredientDao.getIngredient(id);
        if (submittedIngredient.includeInShopping) {
          await ShoppingItemDao(database).insertShoppingItem(
              item: ShoppingItem.create(
            ingredientId: submittedIngredient.id!,
            amount: 0,
          ));
        }
      }
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop(submittedIngredient);
      });
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.title),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                FormTextInputCard(
                  onSaved: (String? value) {
                    setState(() {
                      _chosenName = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name cannot be empty.";
                    }
                    return null;
                  },
                  title: "Name",
                  initValue: widget.ingredient?.name,
                  //controller: _ingredientNameController,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Unit"),
                        DropdownButtonFormField<Unit>(
                          value: widget.ingredient?.unit,
                          validator: (unit) {
                            if (unit == null) {
                              return "Please choose a type of measurement.";
                            }
                            return null;
                          },
                          items: Unit.values.map((unit) {
                            return DropdownMenuItem<Unit>(
                                value: unit,
                                child: Text(unit.name.toUpperCase()));
                          }).toList(),
                          onChanged: (value) {},
                          onSaved: (value) {
                            setState(() {
                              _chosenUnit = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Include in shopping list?",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Checkbox(
                              value:
                                  widget.ingredient?.includeInShopping ?? true,
                              onChanged: (newBool) {
                                setState(() {
                                  _shoppable = newBool ?? true;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!_isSubmitting)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _submit();
                          },
                          child: const Text("Submit"),
                        ),
                      ),
                    ],
                  )
                else
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
