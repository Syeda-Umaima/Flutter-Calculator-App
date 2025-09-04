import 'package:calculator/basic.dart';
import 'package:calculator/scientific.dart';
import 'package:calculator/history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 37,
            backgroundColor: Colors.black,
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "Ordinary",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Scientific",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Tab(icon: Icon(Icons.history,color: Colors.white,),)
              ],
            ),
          ),
          backgroundColor: Color.fromARGB(255, 255, 250, 250),
          body: TabBarView(
            children: [
              basic(), 
              Scientific(), 
              HistoryPage(), 
            ],
          ),
        ),
      ),
    );
  }
}