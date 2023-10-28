import 'package:sqflite/sqflite.dart';

class Meal {
  final int? id;
  final String name;

  Meal._({required this.id, required this.name});

  factory Meal.create({required String name}) {
    return Meal._(id: null, name: name);
  }

  factory Meal.emptyMeal() {
    return Meal._(id: null, name: "");
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
    };
  }

  Map<String, dynamic> toCompleteMap() {
    return {
      "id": id,
      "name": name,
    };
  }

  Meal copyWith({required String newName}){
    return Meal._(id: id, name: newName);
  }

  @override
  String toString() {
    return "Meal{id: $id, name: $name}";
  }

  static Meal fromMap(Map<String, dynamic> map){
    return Meal._(id: map["id"], name: map["name"]);
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
    return Meal._(id: maps[0]["id"], name: maps[0]["name"]);
  }

  Future<List<Meal>> getAllMeals() async {
    final List<Map<String, dynamic>> maps = await _database.query('meal');
    return List.generate(maps.length, (i) {
      return Meal._(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> updateMeal(Meal meal) async {
    _database.update("meal", meal.toCompleteMap(), where: "id = ?", whereArgs: [meal.id!]);
  }
}
