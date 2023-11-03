import 'package:flutter/material.dart';

class MealPlannerAppBar extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<Widget>? actions;

  const MealPlannerAppBar({
    super.key,
    required this.title,
    required this.imagePath,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: actions,
      pinned: true,
      expandedHeight: 200.0,
      backgroundColor: Theme.of(context).canvasColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).canvasColor, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
