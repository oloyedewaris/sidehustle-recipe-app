import 'package:flutter/material.dart';
import 'package:recipe-app/src/ui/screens/add_recipe.dart';

import 'package:recipe-app/src/ui/screens/recipes_home.dart';
import 'package:recipe-app/src/ui/screens/recipes_login.dart';
import 'package:recipe-app/src/ui/recipes_theme.dart';

class RecipesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipes',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/add_recipe': (context) => AddRecipe(),
      },
    );
  }
}