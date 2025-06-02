import 'package:drawingapp/features/draw/models/offset.dart';
import 'package:drawingapp/features/draw/models/stroke.dart';
import 'package:drawingapp/features/draw/presentation/drawscreen.dart';
import 'package:drawingapp/features/home/presentation/homescreen.dart';
import 'package:drawingapp/features/splash/presentation/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(OffsetCustomAdapter()); 
  Hive.registerAdapter(StrokeAdapter());

  // Register adapters
  await Hive.openBox<List<Stroke>>('drawings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint Your Dreams',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(),
        '/home': (context) =>  HomeScreen(),
        '/draw': (context) =>  DrawScreen(),
      },
      
      );
  }
}




