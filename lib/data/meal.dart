import 'package:sqflite/sqflite.dart';

class Meal {
  final int? id;
  final String name;
  final String instructions;

  Meal._({required this.id, required this.name, required this.instructions});

  factory Meal.create({required String name, required String instructions}) {
    return Meal._(id: null, name: name, instructions: instructions);
  }

  factory Meal.emptyMeal() {
    return Meal._(id: null, name: "", instructions: "");
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "instructions": instructions,
    };
  }

  Map<String, dynamic> toCompleteMap() {
    return {
      "id": id,
      "name": name,
      "instructions": instructions,
    };
  }

  Meal copyWith({String? newName, String? newInstructions}) {
    return Meal._(
      id: id,
      name: newName ?? name,
      instructions: newInstructions ?? instructions,
    );
  }

  @override
  String toString() {
    return "Meal{id: $id, name: $name}";
  }

  static Meal fromMap(Map<String, dynamic> map) {
    return Meal._(
      id: map["id"],
      name: map["name"],
      instructions: map["instructions"],
    );
  }
}

class MealDao {
  final Database _database;

  MealDao(this._database);

  Future<void> updateCalendarEventReferencesFromTo(
      int mealId, int newId) async {
    await _database.execute(
        "UPDATE calendar_event SET meal_id = $newId WHERE meal_id = $mealId");
  }

  Future<Meal> insertAndReturnMeal(Meal meal) async {
    int insertedId = await _database.insert("meal", meal.toMap());
    final List<Map<String, dynamic>> maps =
        await _database.query("meal", where: "id = ?", whereArgs: [insertedId]);
    return Meal.fromMap(maps[0]);
  }

  Future<List<Meal>> getAllMeals() async {
    final List<Map<String, dynamic>> maps = await _database.query('meal');
    return List.generate(maps.length, (i) {
      return Meal.fromMap(maps[i]);
    });
  }

  Future<void> updateMeal(Meal meal) async {
    _database.update("meal", meal.toCompleteMap(),
        where: "id = ?", whereArgs: [meal.id!]);
  }
}
