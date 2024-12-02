import 'package:flutter/material.dart';
import 'home_page_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Sintaxe antiga para compatibilidade

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FourSys Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE1515),
          brightness: Brightness.light,
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFFEE1515).withOpacity(0.1),
          ),
          dividerThickness: 1,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE1515),
          brightness: Brightness.dark,
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFFEE1515).withOpacity(0.2),
          ),
          dividerThickness: 1,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePageWidget(),
    );
  }
}