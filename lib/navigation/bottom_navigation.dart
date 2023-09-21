import 'package:flutter/material.dart';
import 'package:meal_planner/pages/calender_page.dart';
import 'package:meal_planner/pages/ingredients_page.dart';
import 'package:meal_planner/pages/meal_page.dart';

const List<Widget> _navigationDestinations = [
  NavigationDestination(
    selectedIcon: Icon(Icons.list),
    icon: Icon(Icons.list_outlined),
    label: "Ingredients",
  ),
  NavigationDestination(
    selectedIcon: Icon(Icons.set_meal),
    icon: Icon(Icons.set_meal_outlined),
    label: "Meals",
  ),
  NavigationDestination(
    selectedIcon: Icon(Icons.calendar_month),
    icon: Icon(Icons.calendar_month_outlined),
    label: "Calender",
  ),
];

class BottomNavigationScreen extends StatefulWidget {
  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 1;
  final List<Widget> _screens = [
    IngredientsPage(),
    const MealPage(title: "Meal List"),
    CalenderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        child: NavigationBar(
          destinations: _navigationDestinations,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          indicatorColor: Colors.green[200],
          elevation: 10,
          selectedIndex: _currentIndex,
          indicatorShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
      ),
    );
  }
}
