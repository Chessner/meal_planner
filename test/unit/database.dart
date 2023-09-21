
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/ingredient.dart';
import 'package:meal_planner/data/meal.dart';
import 'package:meal_planner/database/meal_planner_database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group("Database Tests", () {
    late MealPlannerDatabaseHelper dbHelper;
    late Database database;

    setUpAll(() async {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
      dbHelper = MealPlannerDatabaseHelper();
      database = await dbHelper.init();
    });

    tearDownAll(() async {
      await database.close();
      await deleteDatabase("meal_planner.db");
    });

    group("Meal Tests", () {
      test("empty table at install", () async {
        final mealMaps = await database.query("meal");
        expect(mealMaps, []);
      });

      test("Insert and return returns new meal with id", () async {
        MealDao mealDataAccessObject = MealDao(database);
        Meal mealPreDb = Meal(id: null, name: "Zwetschkenkuchen");
        Meal mealPostDb =
            await mealDataAccessObject.insertAndReturnMeal(mealPreDb);
        expect(mealPreDb.name, mealPostDb.name);
        expect(mealPreDb.id, null);
        expect(mealPostDb.id, 1);
      });
    });

    group("Ingredients test", () {
      test("empty table at install", () async {
        final ingredientMaps = await IngredientDao(database).getAllIngredients();
        expect(ingredientMaps, []);
      });
    });
  });
}
