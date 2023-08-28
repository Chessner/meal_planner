import 'package:flutter/material.dart';
import 'package:meal_planner/calender_page.dart';
import 'package:meal_planner/meal_page.dart';

class BottomNavigationScreen extends StatefulWidget {
  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;
  final int _previousIndex = 0;
  final List<Widget> _screens = [
    const MealPage(title: "Meal List"),
    CalenderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
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
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: Colors.green[200],
        elevation: 10,
        selectedIndex: _currentIndex,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_previousIndex == _currentIndex) {
      return true;
    }
    setState(() {
      _currentIndex = 0;
    });
    return false;
  }
}
