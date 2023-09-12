import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meal_planner/meal_planner_database_provider.dart';
import 'package:provider/provider.dart';

class IngredientsPage extends StatefulWidget {
  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<String> _ingredients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MealPlannerDatabaseProvider>(
        builder: (BuildContext context, MealPlannerDatabaseProvider mDbProvider,
            Widget? child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.0,
                backgroundColor: Theme.of(context).canvasColor,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Ingredients",
                      style: Theme.of(context).textTheme.titleLarge),
                  background: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).canvasColor,
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                    child: Image.asset(
                      'assets/bee.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Dismissible(
                      key: Key(_ingredients[index]),
                      direction: DismissDirection.startToEnd,
                      onUpdate: (details) {
                        print("onUpdate ${details.progress}");
                      },
                      onResize: () {
                        print("onResize");
                      },
                      onDismissed: (direction) {
                        print("onDismissed $direction");
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                      ),
                      child: ListTile(
                        title: Text(_ingredients[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  childCount: _ingredients.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _ingredients.add(Random().nextInt(100000000).toString());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
