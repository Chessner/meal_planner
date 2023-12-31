import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:meal_planner/data/calendar_event.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../data/meal.dart';
import '../database/meal_planner_database_provider.dart';
import '../forms/dialogs/calendar_event_dialog.dart';

class CalenderPage extends StatefulWidget {
  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  int _viewIndex = 2;
  late final CalendarControllerProvider<Tuple<int?, Meal>> _provider;
  late CalendarControllerProvider<Tuple<int?, Meal>>
      _providerChangedDependencies;
  bool loaded = false;

  Future<void> _onLoad() async {
    if (loaded) return;
    _provider = CalendarControllerProvider.of(context);
    Database db = await Provider.of<MealPlannerDatabaseProvider>(context)
        .databaseHelper
        .database;
    final calendarEventDAO = CalendarEventDao(db);
    final events = await calendarEventDAO.getAllCalenderEvents();
    for (final event in events) {
      final List<Map<String, dynamic>> maps =
          await db.query("meal", where: "id = ?", whereArgs: [event.mealId!]);
      final meal = maps.isNotEmpty ? Meal.fromMap(maps[0]) : Meal.emptyMeal();
      _provider.controller.add(CalendarEventData<Tuple<int?, Meal>>(
        title: event.title,
        description: event.description,
        date: event.startDate,
        endDate: event.endDate,
        startTime: event.startDate,
        endTime: event.endDate,
        event: Tuple(event.id, meal),
      ));
    }
    loaded = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the ancestor widget.
    _providerChangedDependencies = CalendarControllerProvider.of(context);
  }

  @override
  void dispose() {
    _providerChangedDependencies.controller.removeWhere((element) => true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _onLoad(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const CircularProgressIndicator();
        // } else if (snapshot.hasError) {
        //   return Text('Error: ${snapshot.error}');
        // } else {
        return DefaultTabController(
          initialIndex: _viewIndex,
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              elevation: 10,
              title: TabBar(
                onTap: (index) {
                  setState(() {
                    _viewIndex = index;
                  });
                },
                tabs: <Widget>[
                  const Tab(
                    text: "Day",
                    //icon: _viewIndex == 0
                    //    ? const Icon(Icons.calendar_view_day_rounded)
                    //    : const Icon(Icons.calendar_view_day_outlined),
                  ),
                  const Tab(
                    text: "Week",
                    //icon: _viewIndex == 1
                    //    ? const Icon(Icons.calendar_view_week_rounded)
                    //    : const Icon(Icons.calendar_view_week_outlined),
                  ),
                  const Tab(
                    text: "Month",
                    //icon: _viewIndex == 2
                    //    ? const Icon(Icons.calendar_view_month_rounded)
                    //    : const Icon(Icons.calendar_view_month_outlined),
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                TabBarView(
                  children: [
                    DayView<Tuple<int?, Meal>>(
                      onEventTap: (data, time) {
                        _onEventTap(data, time);
                      },
                    ),
                    WeekView<Tuple<int?, Meal>>(
                      onEventTap: (data, time) {
                        _onEventTap(data, time);
                      },
                    ),
                    MonthView<Tuple<int?, Meal>>(
                      onEventTap: (data, time) {
                        _onEventTap([data], time);
                      },
                      onCellTap: (events, date) {
                        // Implement callback when user taps on a cell.
                      },
                      useAvailableVerticalSpace: true,
                    ),
                  ],
                ),
                snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : Container(),
                snapshot.hasError
                    ? Center(
                        child: AlertDialog(
                          title: const Text("An error has occurred!"),
                          content: Text(snapshot.error!.toString()),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onEventTap(
      List<CalendarEventData<Tuple<int?, Meal>>> dataList, DateTime time) {
    final data = dataList[0];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CalendarEventDialog(event: data);
        });
  }
}
