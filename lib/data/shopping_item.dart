import 'package:sqflite/sqflite.dart';

class ShoppingItem {
  final int? id;
  final int ingredientId;
  final num amount;

  ShoppingItem._({
    required this.id,
    required this.ingredientId,
    required this.amount,
  });

  factory ShoppingItem.create({
    required int ingredientId,
    required num amount,
  }) {
    return ShoppingItem._(id: null, ingredientId: ingredientId, amount: amount);
  }

  ShoppingItem copyWith({int? ingredientId, num? amount}) {
    return ShoppingItem._(
        id: id,
        ingredientId: ingredientId ?? this.ingredientId,
        amount: amount ?? this.amount);
  }

  static ShoppingItem fromMap(Map<String, dynamic> map) {
    return ShoppingItem._(
        id: map["id"],
        ingredientId: map["ingredient_id"],
        amount: map["amount"]);
  }
}

class ShoppingItemDao {
  final Database _database;
  final String _tableName = "shopping_list";

  ShoppingItemDao(this._database);

  Future<void> insertShoppingItem({required ShoppingItem item}) async {
    await _database.insert(_tableName, {
      "ingredient_id": item.ingredientId,
      "amount": item.amount,
    });
  }

  Future<List<ShoppingItem>> getAllWithAmountGreater0() async {
    final maps = await _database.query(_tableName, where: "amount > 0.0");
    return maps.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  Future<List<ShoppingItem>> getAllWithIdNotIn(
      List<int> ids) async {
    var placeholders = List<String>.generate(ids.length, (index) => '?').join(',');
    final maps = await _database.rawQuery(
        "SELECT * FROM shopping_list WHERE id NOT IN ($placeholders)",
        ids);
    return maps.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  Future<void> addAmount({required ShoppingItem toAdd}) async {
    await _database.rawUpdate(
        "UPDATE shopping_list SET amount = amount + ? WHERE ingredient_id = ?",
        [toAdd.amount, toAdd.ingredientId]);
  }

  Future<void> setAmountTo({required ShoppingItem setTo}) async {
    await _database.rawUpdate(
        "UPDATE shopping_list SET amount = ? WHERE ingredient_id = ?",
        [setTo.amount, setTo.ingredientId]);
  }
}
