import 'package:flutter/material.dart';
import 'package:meal_planner/calender_meal_form.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/database/meal_planner_database_provider.dart';
import 'package:provider/provider.dart';

class AddIngredientDialog extends StatefulWidget {
  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ingredientNameController =
      TextEditingController();
  bool _isSubmitting = false;
  Unit? _chosenUnit;
  String _chosenName = "";
  bool _shoppable = true;

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
      int id = await database.insert(
        "ingredient",
        Ingredient(
                id: null,
                name: _chosenName,
                unit: _chosenUnit!,
                includeInShopping: _shoppable)
            .toMap(),
      );
      var ingredientWithId =
          Ingredient.fromMap(await IngredientDao(database).getIngredient(id));
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop(ingredientWithId);
      });
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Create a new ingredient"),
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
                  controller: _ingredientNameController,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Expanded(
                    //  child: Card(
                    //    child: Padding(
                    //      padding: const EdgeInsets.all(8.0),
                    //      child: Column(
                    //        crossAxisAlignment: CrossAxisAlignment.start,
                    //        children: [
                    //          const Text("Amount"),
                    //          TextFormField(
                    //            onSaved: (String? value) {
                    //
                    //            },
                    //            autovalidateMode:
                    //                AutovalidateMode.onUserInteraction,
                    //            keyboardType: TextInputType.number,
                    //            controller: _ingredientAmountController,
                    //            validator: (value) {
                    //              if (value == null || value.isEmpty) {
                    //                return 'Please enter a number.';
                    //              }
                    //              if (double.tryParse(value.replaceAll(",", ".")) ==
                    //                  null) {
                    //                return 'Please enter a valid number.';
                    //              }
                    //              return null;
                    //            },
                    //          ),
                    //        ],
                    //      ),
                    //    ),
                    //  ),
                    //),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Unit"),
                              DropdownButtonFormField<Unit>(
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
                    ),
                  ],
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
                              value: _shoppable,
                              onChanged: (newBool) {
                                setState(() {
                                  _shoppable = newBool ?? false;
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
