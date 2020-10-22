import 'package:flutter/material.dart';
import 'package:smart_list_app/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.yellow[50],
        scaffoldBackgroundColor: Colors.yellow[50],
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
      },
    );
  }
}

