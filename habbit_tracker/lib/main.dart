import 'package:flutter/material.dart';
import 'package:habbit_tracker/database/habit_database.dart';
import 'package:habbit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'Pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLauncheDate();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create:(context)=>HabitDatabase() ),
      ChangeNotifierProvider(create: (context)=>ThemeProvider()),
    ],
    child:const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}