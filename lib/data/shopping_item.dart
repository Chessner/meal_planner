import 'package:meal_planner/data/ingredient.dart';

class ShoppingItem {
  final Ingredient ingredient;
  final num amount;

  ShoppingItem._({
    required this.ingredient,
    required this.amount,
  });

  factory ShoppingItem.create({
    required ingredient,
    required amount,
  }) {
    return ShoppingItem._(ingredient: ingredient, amount: amount);
  }
}
