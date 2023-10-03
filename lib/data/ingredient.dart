import 'package:sqflite/sqflite.dart';

// Caution: Units are saved in database according to their index.
// Only append new units to avoid interfering with saved data.
enum Unit { pieces, grams, milliliter }

class Ingredient {
  const Ingredient._({
    required this.id,
    required this.name,
    required this.unit,
    required this.includeInShopping,
  });

  factory Ingredient.create(
      {required name, required unit, required includeInShopping}) {
    return Ingredient._(
        id: null, name: name, unit: unit, includeInShopping: includeInShopping);
  }

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

  @override
  String toString() {
    return "Ingredient{id: $id, name: $name, unit: ${unit.name}, includeInShopping: $includeInShopping}";
  }

  static Ingredient fromMap(Map<String, dynamic> map) {
    return Ingredient._(
        id: map["id"],
        name: map["name"],
        unit: Ingredient.intToUnit(map["unit"]),
        includeInShopping: intToBool(map["include_in_shopping"]));
  }

  static bool intToBool(int value) {
    print("intToBool value: $value");
    return value == 1;
  }

  static Unit intToUnit(int index) {
    assert(index < Unit.values.length,
        "Index out of bounds of amount of Unit types.");
    return Unit.values[index];
  }

  static String suffixOf(Unit unit) {
    switch (unit) {
      case Unit.pieces:
        return "pc";
      case Unit.grams:
        return "g";
      case Unit.milliliter:
        return "ml";
    }
  }

  Ingredient copyWith({String? name, Unit? unit, bool? includeInShopping}) {
    return Ingredient._(
        id: id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        includeInShopping: includeInShopping ?? this.includeInShopping);
  }
}

class IngredientDao {
  final Database _database;

  IngredientDao(this._database);

  Future<int> insertIngredient(Ingredient ingredient) async {
    return await _database.insert(
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

  Future<Ingredient> getIngredient(int id) async {
    return Ingredient.fromMap((await _database
        .query("ingredient", where: "id = ?", whereArgs: [id]))[0]);
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final List<Map<String, dynamic>> maps = await _database.query("ingredient");
    return List.generate(maps.length, (i) {
      return Ingredient.fromMap(maps[i]);
    });
  }
}
