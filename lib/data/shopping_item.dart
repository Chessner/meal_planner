import 'package:meal_planner/data/ingredient.dart';
import 'package:sqflite/sqflite.dart';

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

class ShoppingItemDao {
  final Database _database;
  final String _tableName = "shopping_list";

  ShoppingItemDao(this._database);

  Future<void> insertShoppingItem(
      {required int id, required num amount}) async {
    await _database.insert(_tableName, {
      "ingredient_id": id,
      "amount": amount,
    });
  }
}
