import 'package:calendar_view/calendar_view.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:sqflite/sqflite.dart';

import 'meal.dart';

class CalendarEvent {
  int? id;
  int? mealId;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;

  CalendarEvent(
      {required this.id,
      required this.mealId,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate});

  static fromCalendarEventData(CalendarEventData<Tuple<int?, Meal>> data) {
    return CalendarEvent(
        id: data.event!.item1,
        mealId: data.event!.item2.id,
        title: data.title,
        description: data.description,
        startDate: data.date,
        endDate: data.endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "meal_id": mealId,
      "title": title,
      "description": description,
      "start_date": startDate.toIso8601String(),
      "end_date": endDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return """CalendarEvent{id: $id, mealId: $mealId, title: $title, description: $description, startDate: $startDate, endDate: $endDate}""";
  }
}

class CalendarEventDao {
  final Database database;

  CalendarEventDao(this.database);

  Future<int> insertCalendarEvent(CalendarEvent event) async {
    return await database.insert('calendar_event', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CalendarEvent>> getAllCalenderEvents() async {
    final List<Map<String, dynamic>> maps =
        await database.query("calendar_event");
    return List.generate(maps.length, (index) {
      return CalendarEvent(
        id: maps[index]["id"],
        mealId: maps[index]["meal_id"],
        title: maps[index]["title"],
        description: maps[index]["description"],
        startDate: DateTime.parse(maps[index]["start_date"]),
        endDate: DateTime.parse(maps[index]["end_date"]),
      );
    });
  }
}
