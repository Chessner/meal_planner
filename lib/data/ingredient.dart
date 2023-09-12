class Ingredient {
  Ingredient(this.id, this.name, this.unit, this.amount);

  int? id;
  String name;
  Unit unit;
  double amount;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "unit": unit,
      "amount": amount,
    };
  }
}

enum Unit { pieces, grams, milliliter }
