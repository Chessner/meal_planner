class CalendarEvent {
  int id;
  int mealId;
  String description;
  DateTime startDate;
  DateTime endDate;

  CalendarEvent(
      {required this.id,
      required this.mealId,
      required this.description,
      required this.startDate,
      required this.endDate});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "meal_id": mealId,
      "description": description,
      "start_date": startDate,
      "end_date": endDate,
    };
  }

  @override
  String toString() {
    return """CalendarEvent{id: $id, mealId: $mealId, description: $description, startDate: $startDate, endDate: $endDate}""";
  }
}
