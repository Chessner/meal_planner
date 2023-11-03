import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/data/calendar_event.dart';
import 'package:meal_planner/data/meal.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:meal_planner/toast.dart';
import 'package:provider/provider.dart';

import '../database/meal_planner_database_provider.dart';
import 'form_text_input_card.dart';


class CalenderMealForm extends StatefulWidget {
  const CalenderMealForm(
      {super.key,
      required this.meal,
      this.initialStartDate,
      this.initialEndDate,
      this.initialStartTime,
      this.initialEndTime,
      this.initialTitle,
      this.initialDescription,
      this.calendarEventId});

  final Meal meal;
  final int? calendarEventId;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final String? initialTitle;
  final String? initialDescription;

  @override
  State<CalenderMealForm> createState() => _CalenderMealFormState();
}

class _CalenderMealFormState extends State<CalenderMealForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late final CalendarControllerProvider<Tuple<int?, Meal>>
      _calendarControllerProvider;
  bool _calendarControllerProviderSet = false;

  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  bool _initialStartDateSet = false;
  bool _initialEndDateSet = false;
  bool _initialStartTimeSet = false;
  bool _initialEndTimeSet = false;
  bool _initialTitleSet = false;
  bool _initialDescriptionSet = false;

  bool _startEndDateOnSameDay = true;
  bool _addToShoppingList = true;
  bool _isSubmitting = false;

  Future<bool> _submit() async {
    setState(() {
      _isSubmitting = true;
    });
    DateTime endDate =
        _startEndDateOnSameDay ? _selectedStartDate : _selectedEndDate;
    DateTime startDateTime = _selectedStartDate.copyWith(
        hour: _startTime.hour,
        minute: _startTime.minute,
        second: 0,
        millisecond: 0,
        microsecond: 0);
    DateTime endDateTime = endDate.copyWith(
        hour: _endTime.hour,
        minute: _endTime.minute,
        second: 0,
        millisecond: 0,
        microsecond: 0);
    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime) ||
        endDateTime.hour < startDateTime.hour ||
        (endDateTime.hour == startDateTime.hour &&
            endDateTime.minute < startDateTime.minute)) {
      setState(() {
        _isSubmitting = false;
      });
      return false;
    }

    final ced = CalendarEventData<Tuple<int?, Meal>>(
      title: _mealNameController.text,
      description: _descriptionController.text,
      date: startDateTime,
      endDate: endDateTime,
      startTime: startDateTime,
      endTime: endDateTime,
      event: Tuple(widget.calendarEventId, widget.meal),
    );
    final calendarEvent = CalendarEvent.fromCalendarEventData(ced);
    final calendarEventDAO = CalendarEventDao(
        await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
            .databaseHelper
            .database);
    await calendarEventDAO.insertCalendarEvent(calendarEvent);

    //Update calendar if event is not new
    if (_initialStartDateSet) {
      _calendarControllerProvider.controller.removeWhere((element) {
        return element.event?.item1 == widget.calendarEventId;
      });
      _calendarControllerProvider.controller.add(ced);
    }

    setState(() {
      _isSubmitting = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_calendarControllerProviderSet) {
      setState(() {
        _calendarControllerProvider =
            CalendarControllerProvider.of<Tuple<int?, Meal>>(context);
        _calendarControllerProviderSet = true;
      });
    }
    setState(() {
      if (widget.initialStartDate != null && !_initialStartDateSet) {
        _selectedStartDate = widget.initialStartDate!;
        _initialStartDateSet = true;
      }
      if (widget.initialEndDate != null && !_initialEndDateSet) {
        _selectedEndDate = widget.initialEndDate!;
        _initialEndDateSet = true;
      }
      if (widget.initialStartTime != null && !_initialStartTimeSet) {
        _startTime = widget.initialStartTime!;
        _initialStartTimeSet = true;
      }
      if (widget.initialEndTime != null && !_initialEndTimeSet) {
        _endTime = widget.initialEndTime!;
        _initialEndTimeSet = true;
      }
      if (widget.initialTitle != null && !_initialTitleSet) {
        _mealNameController.text = widget.initialTitle!;
        _initialTitleSet = true;
      } else if(!_initialTitleSet) {
        _mealNameController.text = widget.meal.name;
        _initialTitleSet = true;
      }
      if (widget.initialDescription != null && !_initialDescriptionSet) {
        _descriptionController.text = widget.initialDescription!;
        _initialDescriptionSet = true;
      } else if(!_initialDescriptionSet) {
        _descriptionController.text = "";
        _initialDescriptionSet = true;
      }
    });
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Scaffold(
              body: Column(
                children: [
                  FormTextInputCard(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Meal name cannot be empty';
                      }
                      return null;
                    },
                    title: "Meal name",
                    controller: _mealNameController,
                  ),
                  FormTextInputCard(
                    validator: null,
                    title: "Description",
                    controller: _descriptionController,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                InputDatePickerFormField(
                                  firstDate: _selectedStartDate.subtract(
                                    const Duration(days: 10000),
                                  ),
                                  lastDate: _selectedStartDate.add(
                                    const Duration(days: 10000),
                                  ),
                                  acceptEmptyDate: false,
                                  initialDate: _selectedStartDate,
                                  fieldLabelText: "Start date",
                                  onDateSubmitted: (date) {
                                    setState(() {
                                      _selectedStartDate = date;
                                    });
                                  },
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  bottom: 8,
                                  child: IconButton(
                                    onPressed: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: _selectedStartDate,
                                        firstDate: _selectedStartDate.subtract(
                                          const Duration(days: 10000),
                                        ),
                                        lastDate: _selectedStartDate.add(
                                          const Duration(days: 10000),
                                        ),
                                      );
                                      if (pickedDate != null) {
                                        setState(
                                          () {
                                            _selectedStartDate = pickedDate;
                                          },
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      !_startEndDateOnSameDay
                          ? Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      InputDatePickerFormField(
                                        firstDate: _selectedEndDate.subtract(
                                          const Duration(days: 10000),
                                        ),
                                        lastDate: _selectedEndDate.add(
                                          const Duration(days: 10000),
                                        ),
                                        acceptEmptyDate: false,
                                        initialDate: _selectedEndDate,
                                        fieldLabelText: "End date",
                                        onDateSubmitted: (date) {
                                          setState(() {
                                            _selectedEndDate = date;
                                          });
                                        },
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        bottom: 8,
                                        child: IconButton(
                                          onPressed: () async {
                                            final DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: _selectedEndDate,
                                              firstDate:
                                                  _selectedEndDate.subtract(
                                                const Duration(days: 10000),
                                              ),
                                              lastDate: _selectedEndDate.add(
                                                const Duration(days: 10000),
                                              ),
                                            );
                                            if (pickedDate != null) {
                                              setState(
                                                () {
                                                  _selectedEndDate = pickedDate;
                                                },
                                              );
                                            }
                                          },
                                          icon:
                                              const Icon(Icons.calendar_month),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Same day?",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Checkbox(
                                value: _startEndDateOnSameDay,
                                onChanged: (newBool) {
                                  setState(() {
                                    _startEndDateOnSameDay = newBool ?? false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Start time"),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _startTime.format(context).toString(),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showTimePicker(
                                            context: context,
                                            initialTime: _startTime,
                                            initialEntryMode:
                                                TimePickerEntryMode.dial,
                                          ).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                _startTime = value;
                                              });
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.watch_later))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("End time"),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _endTime.format(context).toString(),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showTimePicker(
                                            context: context,
                                            initialTime: _endTime,
                                            initialEntryMode:
                                                TimePickerEntryMode.dial,
                                          ).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                _endTime = value;
                                              });
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.watch_later))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Add ingredients to shopping list?",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Checkbox(
                                value: _addToShoppingList,
                                onChanged: (newBool) {
                                  setState(() {
                                    _addToShoppingList = newBool ?? false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              bool submissionResult = await _submit();
                              if (submissionResult) {
                                MealPlannerToast.showShortToast("Saved");
                                Future.delayed(Duration.zero, () {
                                  Navigator.of(context).pop();
                                });
                              } else {
                                MealPlannerToast.showLongToast(
                                    "End date and time must be after start date and time");
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
