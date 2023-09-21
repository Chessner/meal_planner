import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meal_planner/navigation/bottom_navigation.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'data/meal.dart';
import 'database/meal_planner_database_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => MealPlannerDatabaseProvider(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<MealPlannerDatabaseProvider>(context);
    return CalendarControllerProvider<Tuple<int?, Meal>>(
      controller: EventController(),
      child: MaterialApp(
        supportedLocales: [
          const Locale('de'), // German
          const Locale('en'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: "Meal Planner",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: FutureBuilder<Database>(
          future: databaseProvider.databaseHelper.init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Return a loading indicator if the future is still running
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Handle error state
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              // Handle null data state
              return const Text('No data available');
            } else {
              // Build UI using the snapshot.data (Database object)
              return BottomNavigationScreen();
            }
          },
        ),
      ),
    );
  }
}
