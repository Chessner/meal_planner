import 'package:flutter/material.dart';
import 'package:meal_planner/calender_meal_form.dart';
import 'package:meal_planner/data/ingredient.dart';

class AddIngredientView extends StatefulWidget {
  @override
  State<AddIngredientView> createState() => _AddIngredientViewState();
}

class _AddIngredientViewState extends State<AddIngredientView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _ingredientAmountController =
      TextEditingController();
  Unit? _chosenUnit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            FormTextInputCard(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name cannot be empty";
                }
                return null;
              },
              title: "Name",
              controller: _ingredientNameController,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Amount"),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.number,
                            controller: _ingredientAmountController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a number.';
                              }
                              if (double.tryParse(value.replaceAll(",", ".")) ==
                                  null) {
                                return 'Please enter a valid number.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.validate();
              },
              child: const Text("validate"),
            ),
          ],
        ),
      ),
    );
  }
}
