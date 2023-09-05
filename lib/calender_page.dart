import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:meal_planner/calendar_event_dialog.dart';
import 'package:meal_planner/data/calendar_event.dart';
import 'package:meal_planner/meal_planner_database_provider.dart';
import 'package:provider/provider.dart';

class CalenderPage extends StatefulWidget {
  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  int _viewIndex = 1;
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
    loaded = true;
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
                    Tab(
                      icon: _viewIndex == 0
                          ? const Icon(Icons.calendar_view_day_rounded)
                          : const Icon(Icons.calendar_view_day_outlined),
                    ),
                    Tab(
                      icon: _viewIndex == 1
                          ? const Icon(Icons.calendar_view_week_rounded)
                          : const Icon(Icons.calendar_view_week_outlined),
                    ),
                    Tab(
                      icon: _viewIndex == 2
                          ? const Icon(Icons.calendar_view_month_rounded)
                          : const Icon(Icons.calendar_view_month_outlined),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  DayView(
                    onEventTap: (data, time) {
                      _onEventTap(data, time);
                    },
                  ),
                  WeekView(
                    onEventTap: (data, time) {
                      _onEventTap(data, time);
                    },
                  ),
                  MonthView(
                    onEventTap: (data, time) {
                      _onEventTap([data], time);
                    },
                    onCellTap: (events, date) {
                      // Implement callback when user taps on a cell.
                      print(events);
                    },
                    useAvailableVerticalSpace: true,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _onEventTap(List<CalendarEventData<dynamic>> dataList, DateTime time) {
    final data = dataList[0];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CalendarEventDialog(event: data);
        });
    print(data.title);
  }
}
