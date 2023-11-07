import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';

class ShoppingIngredient {
  final ShoppingItem item;
  final Ingredient ingredient;

  ShoppingIngredient({required this.item, required this.ingredient});
}
