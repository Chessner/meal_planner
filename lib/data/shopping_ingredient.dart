import 'package:intl/intl.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/shopping_item.dart';

class ShoppingIngredient {
  final ShoppingItem item;
  final Ingredient ingredient;

  ShoppingIngredient({required this.item, required this.ingredient});

  ShoppingIngredient copyWith({ShoppingItem? item, Ingredient? ingredient}) {
    return ShoppingIngredient(
        item: item ?? this.item, ingredient: ingredient ?? this.ingredient);
  }

  String _shareString() {
    return "${ingredient.name}: ${item.amount}${Ingredient.suffixOf(ingredient.unit)}";
  }

  static String shareString(List<ShoppingIngredient> ingredients) {
    StringBuffer buffer = StringBuffer();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, yyyy HH:mm').format(now);
    buffer.writeln("Shopping list created at $formattedDate");
    for (var element in ingredients) {
      buffer.writeln(element._shareString());
    }
    return buffer.toString();
  }
}
