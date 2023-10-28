import 'package:sqflite/sqflite.dart';

const String tableName = "ingredients_of_meal";

class MealIngredient {
  final int? id;
  final int ingredientId;
  final int mealId;
  final num amount;


  MealIngredient({this.id,
    required this.ingredientId,
    required this.mealId,
    required this.amount});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "ingredient_id": ingredientId,
      "meal_id": mealId,
      "amount": amount,
    };
  }

  static MealIngredient fromMap(Map<String, dynamic> map) {
    return MealIngredient(
        id: map["id"],
        ingredientId: map["ingredient_id"],
        mealId: map["meal_id"],
        amount: map["amount"]);
  }
}

class MealIngredientDao {
  final Database _database;

  MealIngredientDao(this._database);

  Future<void> insertMealIngredients(
      List<MealIngredient> mealIngredients) async {
    Batch insertBatch = _database.batch();
    for (MealIngredient mealIngredient in mealIngredients) {
      insertBatch.insert(tableName, mealIngredient.toMap());
    }
    await insertBatch.commit();
    }

  Future<List<MealIngredient>> getMealIngredientsOfMeal(int id) async {
    List<Map<String, dynamic>> mealIngredientMaps = await _database
        .query(tableName, where: "meal_id = ?", whereArgs: [id]);
    return mealIngredientMaps.map((map) {
      return MealIngredient.fromMap(map);
    }).toList();
  }

  Future<int> deleteMealIngredientsOfMeal(int id) async {
    return await _database
        .delete(tableName, where: "meal_id = ?", whereArgs: [id]);
  }
}
