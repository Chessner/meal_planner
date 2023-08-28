import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class CalenderPage extends StatefulWidget {
  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  final event = CalendarEventData(
    title: "title",
    description: "dada",
    date: DateTime.now(),
    startTime: DateTime.now(),
    endDate: DateTime.now().add(const Duration(hours: 2)),
    endTime: DateTime.now().add(const Duration(hours: 2)),
  );

  late final CalendarControllerProvider _provider;

  @override
  Widget build(BuildContext context) {
    _provider = CalendarControllerProvider.of(context);
    _provider.controller.add(event);
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

  @override
  void dispose() {
    super.dispose();
    _provider.controller.remove(event);
  }
}
