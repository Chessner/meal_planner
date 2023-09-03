import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarEventDialog extends StatelessWidget {
  const CalendarEventDialog({super.key, required this.event});

  final CalendarEventData event;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: [
          Text(event.title),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {},
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
