import 'package:sqflite/sqflite.dart';

class MealIngredient {
  final int? id;
  final int ingredientId;
  final int mealId;
  final num amount;

  MealIngredient({this.id, required this.ingredientId, required this.mealId, required this.amount});

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "ingredient_id": ingredientId,
      "meal_id": mealId,
      "amount": amount,
    };
  }
}

class MealIngredientDao {
  final Database _database;

  MealIngredientDao(this._database);

  Future<void> insertMealIngredients(List<MealIngredient> mealIngredients) async {
    Batch insertBatch = _database.batch();
    for(MealIngredient mealIngredient in mealIngredients){
      insertBatch.insert("ingredients_of_meal", mealIngredient.toMap());
    }
    await insertBatch.commit();
  }
}
