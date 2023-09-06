import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meal_planner/bottom_navigation.dart';
import 'package:meal_planner/data/tuple.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'data/meal.dart';
import 'meal_planner_database_provider.dart';

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
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
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
              // Build your UI using the snapshot.data (Database object)
              return BottomNavigationScreen();
            }
          },
        ),
      ),
    );
  }
}
