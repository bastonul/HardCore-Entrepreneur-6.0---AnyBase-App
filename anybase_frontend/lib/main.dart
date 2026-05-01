import 'package:flutter/material.dart';
import 'screens/home_screen.dart';


class AnyBaseApp extends StatefulWidget{

    const AnyBaseApp({super.key});

    @override
    State<AnyBaseApp> createState() => _AnyBaseAppState();
}

class _AnyBaseAppState extends State<AnyBaseApp> {

    ThemeMode _themeMode = ThemeMode.light;
    void _toggleTheme() {
      setState(() {
        _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      });
    }

    @override
    Widget build(BuildContext context) {
      const softLinen = Color(0xFFE6E1D6); //off-white ish
      const tropicalTeal = Color(0xFF4DB6AC); //teal blue
      const charcoalBlue = Color(0xFF3D5361); //grayish blue

      return MaterialApp(
        title: 'AnyBase',
        debugShowCheckedModeBanner: false,

        themeMode: _themeMode,

        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: softLinen,
          colorScheme: const ColorScheme.light(
            primary: tropicalTeal,
            secondary: charcoalBlue,
            surface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: charcoalBlue,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),

        //dark theme
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: charcoalBlue,
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF4A6475),
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
           backgroundColor: Color(0xFF2C3E4A),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),

        home: HomeScreen(onThemeToggle: _toggleTheme),
      );
    }
}
void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnyBaseApp());
}


