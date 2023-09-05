import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/data/calendar_event.dart';
import 'package:meal_planner/meal_planner_database_provider.dart';
import 'package:provider/provider.dart';

class CalenderMealForm extends StatefulWidget {
  const CalenderMealForm({super.key, required this.meal});

  final String meal;

  @override
  State<CalenderMealForm> createState() => _CalenderMealFormState();
}

class _CalenderMealFormState extends State<CalenderMealForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<int> _submit() async {
    final ced = CalendarEventData(
      title: _mealNameController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      endDate: _selectedDate.add(
        const Duration(hours: 1),
      ),
      startTime: _selectedDate,
      endTime: _selectedDate.add(
        const Duration(hours: 1),
      ),
    );
    final calendarEvent = CalendarEvent.fromCalendarEventData(ced);
    final calendarEventDAO = CalendarEventDao(
        await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
            .databaseHelper
            .database);
    return await calendarEventDAO.insertCalendarEvent(calendarEvent);
  }

  @override
  Widget build(BuildContext context) {
    _mealNameController.text = widget.meal;
    _descriptionController.text = "";
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          InputDatePickerFormField(
                            firstDate: _selectedDate.subtract(
                              const Duration(days: 10000),
                            ),
                            lastDate: _selectedDate.add(
                              const Duration(days: 10000),
                            ),
                            acceptEmptyDate: false,
                            initialDate: _selectedDate,
                            fieldLabelText: "Date",
                            onDateSubmitted: (date) {
                              setState(() {
                                _selectedDate = date;
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
                                  initialDate: _selectedDate,
                                  firstDate: _selectedDate.subtract(
                                    const Duration(days: 10000),
                                  ),
                                  lastDate: _selectedDate.add(
                                    const Duration(days: 10000),
                                  ),
                                );
                                if (pickedDate != null) {
                                  setState(
                                    () {
                                      _selectedDate = pickedDate;
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
                ],
              ),
              floatingActionButton: ElevatedButton(
                onPressed: () {
                  FutureBuilder(
                    future: _submit(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container();
                      } else {
                        // Show a loading indicator or other UI while waiting for the future.
                        return const CircularProgressIndicator();
                      }
                    },
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Save"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormTextInputCard extends StatelessWidget {
  const FormTextInputCard({
    super.key,
    required this.validator,
    required this.title,
    required this.controller,
  });

  final String? Function(String?)? validator;
  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(title),
            ),
            TextFormField(
              controller: controller,
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}
