import 'package:flutter/material.dart';
import 'package:meal_planner/data/shopping_ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';
import 'package:meal_planner/database/meal_planner_database_provider.dart';
import 'package:meal_planner/forms/meal_form.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/ingredient.dart';

class ShoppingAmountCreateDialog extends StatefulWidget {
  final ShoppingIngredient shoppingIngredient;

  ShoppingAmountCreateDialog({
    super.key,
    required this.shoppingIngredient,
  });

  @override
  State<ShoppingAmountCreateDialog> createState() =>
      _ShoppingAmountCreateDialogState();
}

class _ShoppingAmountCreateDialogState
    extends State<ShoppingAmountCreateDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  double amount = 0;

  void _onSave() async {
    if (_formKey.currentState == null) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Database database =
          await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
              .databaseHelper
              .database;
      ShoppingItemDao shoppingItemDao = ShoppingItemDao(database);
      ShoppingItem newItem =
          widget.shoppingIngredient.item.copyWith(amount: amount);
      await shoppingItemDao.setAmountTo(
        setTo: newItem,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop(newItem);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(
          "Add ${widget.shoppingIngredient.ingredient.name} to shopping list"),
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AmountInputField(
                  suffix: Ingredient.suffixOf(
                      widget.shoppingIngredient.ingredient.unit),
                  title: "Amount: ${widget.shoppingIngredient.item.amount}",
                  initialValue: 0,
                  onSaved: (String? amount) {
                    this.amount = double.parse(amount!);
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"))),
              Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () {
                        _onSave();
                      },
                      child: const Text("Save")))
            ],
          ),
        )
      ],
    );
  }
}
