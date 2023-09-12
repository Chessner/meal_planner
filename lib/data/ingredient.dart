import 'package:sqflite/sqflite.dart';

enum Unit { pieces, grams, milliliter }

class Ingredient {
  const Ingredient(
      {required this.id,
      required this.name,
      required this.unit,
      required this.amount});

  final int? id;
  final String name;
  final Unit unit;
  final double amount;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "unit": unit,
      "amount": amount,
    };
  }
}

class IngredientDao {
  final Database _database;

  IngredientDao(this._database);

  Future<void> insertIngredient(Ingredient ingredient) async {
    await _database.insert(
      "ingredient",
      ingredient.toMap(),
    );
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await _database.update(
      "ingredient",
      ingredient.toMap(),
      where: "id = ?",
      whereArgs: [ingredient.id!],
    );
  }

  Future<void> deleteIngredient(Ingredient ingredient) async {
    await _database.delete(
      "ingredient",
      where: "id = ?",
      whereArgs: [ingredient.id],
    );
  }
}
