import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MealPlannerDatabaseProvider extends ChangeNotifier {
  Database? _database;

  Database? get database => _database;

  Future<void> init() async {
    // Open the database and store the reference.
    _database = await openDatabase(
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
      version: 1,
    );
    notifyListeners();
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
