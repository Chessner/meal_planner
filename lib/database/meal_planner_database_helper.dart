import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/ingredient.dart';
import '../data/meal.dart';

class MealPlannerDatabaseHelper {
  late final Future<Database> _database;
  bool _initCalled = false;

  Future<Database> get database => _database;

  Future<Database> init() async {
    if (_initCalled) return _database;
    _initCalled = true;
    // Open the database and store the reference.
    _database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'meal_planner.db'),

      onCreate: (db, version) async {
        await _updateDatabase(db, 0, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _updateDatabase(db, oldVersion, newVersion);
      },
      version: 3,
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

  Future<List<Ingredient>> getAllIngredients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("ingredient");
    return List.generate(maps.length, (i) {
      return Ingredient.fromMap(maps[i]);
    });
  }
}

Future<void> _updateDatabase(
    Database db, int fromVersion, int toVersion) async {
  int curVersion = fromVersion;
  if (fromVersion < 1 && curVersion < toVersion) {
    await _v1(db);
    curVersion++;
  }
  if (fromVersion < 2 && curVersion < toVersion) {
    await _v2(db);
    curVersion++;
  }
  if (fromVersion < 3 && curVersion < toVersion) {
    await _v3(db);
    curVersion++;
  }
}

Future<void> _v1(Database db) async {
  await db.execute("""
            CREATE TABLE meal(
              id INTEGER PRIMARY KEY, 
              name TEXT
            )""");
  await db.execute("""CREATE TABLE calendar_event(
          id INTEGER PRIMARY KEY, 
          title TEXT,
          description TEXT, 
          start_date TEXT, 
          end_date Text, 
          meal_id INTEGER, 
          CONSTRAINT fk_meal FOREIGN KEY (meal_id) REFERENCES meal(id)
          )""");
}

Future<void> _v2(Database db) async {
  await db.execute("""
       CREATE TABLE ingredient(
         id INTEGER PRIMARY KEY,
         name TEXT,
         unit INTEGER
       )""");
}

Future<void> _v3(Database db) async {
  await db.execute("""
       ALTER TABLE ingredient ADD COLUMN include_in_shopping INTEGER DEFAULT 1;
       """);
}
