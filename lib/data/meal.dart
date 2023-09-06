import 'package:sqflite/sqflite.dart';

class Meal {
  final int? id;
  final String name;

  //Recipe? recipe;

  Meal({required this.id, required this.name});

  static Meal emptyMeal() {
    return Meal(id: -1, name: "");
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

  @override
  String toString() {
    return "Meal{id: $id, name: $name}";
  }
}

class MealDao {
  final Database database;

  MealDao(this.database);

  Future<void> updateCalendarEventReferencesFromTo(
      int mealId, int newId) async {
    await database.execute(
        "UPDATE calendar_event SET meal_id = $newId WHERE meal_id = $mealId");
  }
}
