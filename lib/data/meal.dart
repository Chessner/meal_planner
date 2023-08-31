
class Meal {
  final int? id;
  final String name;
  //Recipe? recipe;

  Meal({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      "name": name,
    };
  }
  Map<String, dynamic> toCompleteMap() {
    return {
      "id": id,
      "name": name,
    };
  }

  @override
  String toString() {
    return "Meal{id: $id, name: $name}";
  }
}
