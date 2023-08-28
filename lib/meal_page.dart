import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_meal_form.dart';
import 'edit_dialog.dart';
import 'random_meal_dialog.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key, required this.title});

  final String title;

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<String> _meals = [];
  Random _rand = Random();

  void _addMeal(String meal) async {
    setState(() {
      if (_meals.contains(meal)) {
        showDialog(
            context: context,
            builder: (BuildContext builder) {
              return const AlertDialog(
                title: Center(
                  child: Text("Meal already exists"),
                ),
              );
            });
      } else {
        _meals.add(meal);
      }
    });
    _updatePrefs();
  }

  void _removeMeal(String meal) async {
    setState(() {
      _meals.remove(meal);
    });
    _updatePrefs();
  }

  void _updateMeal(String oldMeal, String newMeal) async {
    int index = _meals.indexOf(oldMeal);
    setState(() {
      _meals.removeAt(index);
      _meals.insert(index, newMeal);
    });
    _updatePrefs();
  }

  void _updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("meals", _meals);
  }

  final _myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("meals") ?? ["empty"];
    setState(() {
      _meals = list;
    });
  }

  void _randomMeal() {
    int index = _rand.nextInt(_meals.length);
    String meal = _meals[index];
    showDialog(
        context: context,
        builder: (BuildContext builder) {
          return RandomMealDialog(meal: meal);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            actions: [
              IconButton(
                  onPressed: _randomMeal, icon: const Icon(Icons.lightbulb))
            ],
            backgroundColor: Theme.of(context).canvasColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(widget.title,
                  style: Theme.of(context).textTheme.titleLarge),
              background: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).canvasColor, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                  // gradient: RadialGradient(
                  //   colors: [Colors.white, Colors.transparent],
                  //   center: Alignment.bottomCenter,
                  //   radius: 0.8
                  // ),
                ),
                child: Image.asset(
                  'assets/bee.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            //title: Text(widget.title),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Dismissible(
                  key: Key(_meals[index]),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    _removeMeal(_meals[index]);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Text(_meals[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _onEdit(_meals[index]);
                      },
                    ),
                  ),
                );
              },
              childCount: _meals.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMealFormDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onEdit(String oldMeal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(
          oldMeal: oldMeal,
        );
      },
    ).then(
          (newMeal) => {
        if (newMeal != null)
          {
            if (newMeal != "")
              {_updateMeal(oldMeal, newMeal)}
            else
              {
                Fluttertoast.showToast(
                  msg: "Did not save, because meal name was empty.",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0,
                ),
              },
          }
        else
          {
            Fluttertoast.showToast(
              msg: "Canceled.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0,
            ),
          },
      },
    );
  }

  void _showAddMealFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddMealForm();
      },
    ).then((value) => _addMeal(value));
  }
}
