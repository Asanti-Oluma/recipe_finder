import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/home_screen.dart';

//Design tokens
const kPrimary = Color(0xFF2D1B69); // deep violet
const kAccent = Color(0xFFE8445A); // vivid coral-red
const kBackground = Color(0xFFF7F7FC);

void main() {
  runApp(const RecipeFinderApp());
}

class RecipeFinderApp extends StatelessWidget {
  const RecipeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeProvider(),
      child: MaterialApp(
        title: 'Recipe Finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimary,
            primary: kPrimary,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false),
          scaffoldBackgroundColor: kBackground,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
