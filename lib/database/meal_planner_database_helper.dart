import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      version: 7,
    );
    return _database;
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
  if (fromVersion < 4 && curVersion < toVersion) {
    await _v4(db);
    curVersion++;
  }
  if (fromVersion < 5 && curVersion < toVersion) {
    await _v5(db);
    curVersion++;
  }
  if (fromVersion < 6 && curVersion < toVersion) {
    await _v6(db);
    curVersion++;
  }
  if (fromVersion < 7 && curVersion < toVersion) {
    await _v7(db);
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

Future<void> _v4(Database db) async {
  await db.execute("""CREATE TABLE ingredients_of_meal(
    id INTEGER PRIMARY KEY,
    ingredient_id INTEGER,
    meal_id INTEGER,
    amount REAL,
    FOREIGN KEY (ingredient_id) REFERENCES ingredient(id) ON DELETE CASCADE,
    FOREIGN KEY (meal_id) REFERENCES meal(id) ON DELETE CASCADE
  )""");
}

Future<void> _v5(Database db) async {
  await db.execute("""
    CREATE TABLE shopping_list(
      id INTEGER PRIMARY KEY,
      ingredient_id INTEGER,
      amount REAL,
      FOREIGN KEY (ingredient_id) REFERENCES ingredient(id) ON DELETE CASCADE
    )""");
  var ingredientIds = await db.query("ingredient",
      columns: ["id"], where: "include_in_shopping = 1");
  for (var map in ingredientIds) {
    var shoppingItem = {
      "ingredient_id": map["id"],
      "amount": 0,
    };
    db.insert("shopping_list", shoppingItem);
  }
}

Future<void> _v6(Database db) async {
  await db.execute("""
    ALTER TABLE meal ADD COLUMN instructions TEXT DEFAULT "";
  """);
}

Future<void> _v7(Database db) async {
  await db.execute("""
    CREATE TABLE new_calendar_event(
      id INTEGER PRIMARY KEY, 
      title TEXT,
      description TEXT, 
      start_date TEXT, 
      end_date Text, 
      meal_id INTEGER, 
      FOREIGN KEY (meal_id) REFERENCES meal(id) ON DELETE CASCADE
    )""");
  await db.execute("""
    INSERT INTO new_calendar_event 
      (id, title, description, start_date, end_date, meal_id) 
      SELECT id, title, description, start_date, end_date, meal_id FROM calendar_event
  """);
  await db.execute("DROP TABLE calendar_event");
  await db.execute("ALTER TABLE new_calendar_event RENAME TO calendar_event");
}
