import 'package:sqflite/sqflite.dart';

// Caution: Units are saved in database according to their index.
// Only append new units to avoid interfering with saved data.
enum Unit { pieces, grams, milliliter }

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.includeInShopping,
  });

  final int? id;
  final String name;
  final Unit unit;
  final bool includeInShopping;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "unit": unit.index,
      "include_in_shopping": includeInShopping ? 1 : 0,
    };
  }

  static Ingredient fromMap(Map<String, dynamic> map) {
    return Ingredient(
        id: map["id"],
        name: map["name"],
        unit: Ingredient.intToUnit(map["unit"]),
        includeInShopping: intToBool(map["include_in_shopping"]));
  }

  static bool intToBool(int value) {
    return value == 1;
  }

  static Unit intToUnit(int index) {
    assert(index < Unit.values.length,
        "Index out of bounds of amount of Unit types.");
    return Unit.values[index];
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

  Future<Map<String, dynamic>> getIngredient(int id) async {
    return (await _database
        .query("ingredient", where: "id = ?", whereArgs: [id]))[0];
  }
}
