import 'dart:async';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'data/meal.dart';

class MealPlannerDatabaseHelper {
  late final Future<Database> _database;

  Future<Database> get database => _database;

  Future<Database> init() async {
    // Open the database and store the reference.
    _database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'meal_planner.db'),

      onCreate: (db, version) async {
        await db.execute("""
            CREATE TABLE meal(
              id INTEGER PRIMARY KEY, 
              name TEXT
            )""");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          final prefs = await SharedPreferences.getInstance();
          var list = prefs.getStringList("meals") ?? [];
          List<Map<String, dynamic>> meals = list.map((e) {
            return Meal(name: e, id: null).toMap();
          }).toList();
          print(meals);
          for (var meal in meals) {
            await db.insert("meal", meal,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          prefs.remove("meals");
        }
      },
      version: 4,
    );
    return _database;
  }

  Future<List<Meal>> getAllMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('meal');
    return List.generate(maps.length, (i) {
      return Meal(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }
}

/*

            CREATE TABLE calendar_event(
              id INTEGER PRIMARY KEY,
              FOREIGN KEY (meal_id) REFERENCES meal(id),
              description TEXT,
              start_date TEXT,
              end_date TEXT
            )
 */
