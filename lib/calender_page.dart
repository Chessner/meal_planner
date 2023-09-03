import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:meal_planner/data/calendar_event.dart';
import 'package:meal_planner/meal_planner_database_provider.dart';
import 'package:provider/provider.dart';

class CalenderPage extends StatefulWidget {
  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  late final CalendarControllerProvider _provider;
  bool loaded = false;

  Future<void> _onLoad() async {
    if (loaded) return;
    _provider = CalendarControllerProvider.of(context);
    MealPlannerDatabaseProvider dbProvider =
        Provider.of<MealPlannerDatabaseProvider>(context);
    final calendarEventDAO =
        CalendarEventDao(await dbProvider.databaseHelper.database);
    final events = await calendarEventDAO.getAllCalenderEvents();
    for (var event in events) {
      _provider.controller.add(CalendarEventData(
        title: event.title,
        description: event.description,
        date: event.startDate,
        endDate: event.endDate,
        startTime: event.startDate,
        endTime: event.endDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _onLoad(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            body: MonthView(
              onCellTap: (events, date) {
                // Implement callback when user taps on a cell.
                print(events);
              },
              useAvailableVerticalSpace: true,
            ),
          );
        }
      },
    );
  }
}
