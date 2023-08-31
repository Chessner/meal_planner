import 'package:flutter/material.dart';
import 'package:meal_planner/meal_planner_database_helper.dart';


class MealPlannerDatabaseProvider extends ChangeNotifier {
  final MealPlannerDatabaseHelper _databaseHelper = MealPlannerDatabaseHelper();

  MealPlannerDatabaseHelper get databaseHelper => _databaseHelper;
}