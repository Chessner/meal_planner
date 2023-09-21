import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/data/calendar_event.dart';
import 'package:provider/provider.dart';

import 'data/meal.dart';
import 'data/tuple.dart';
import 'database/meal_planner_database_provider.dart';
import 'forms/calender_meal_form.dart';

class CalendarEventDialog extends StatelessWidget {
  const CalendarEventDialog({super.key, required this.event});

  final CalendarEventData<Tuple<int?, Meal>> event;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(event.title),
          ),
          Expanded(
            flex: 2,
            child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () async {
                Navigator.of(context).pop();
                CalendarControllerProvider.of<Tuple<int?, Meal>>(context).controller.remove(event);
                var db =
                    await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
                        .databaseHelper
                        .database;
                CalendarEventDao(db)
                    .removeCalendarEvent(event.event?.item1 ?? -1);
              },
            ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CalenderMealForm(
                        meal: event.event?.item2 ??
                            Meal(id: -1, name: event.title),
                        calendarEventId: event.event?.item1,
                        initialTitle: event.title,
                        initialDescription: event.description,
                        initialStartDate: event.date,
                        initialEndDate: event.endDate,
                        initialStartTime: TimeOfDay.fromDateTime(
                            event.startTime ?? event.date),
                        initialEndTime: TimeOfDay.fromDateTime(
                            event.endTime ?? event.endDate),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                event.description.isNotEmpty
                    ? event.description
                    : "Empty description",
                style: event.description.isNotEmpty
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "Date",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                DateFormat.yMMMEd(Localizations.localeOf(context).languageCode)
                    .format(event.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
