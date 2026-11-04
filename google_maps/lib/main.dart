import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_app/presentation/screens/home_screen.dart';

// import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Sets the status bar style globally
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.blue, // Background color of the status bar
            statusBarIconBrightness: Brightness
                .light, // Icons/text color: light (white) or dark (black)
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
