// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:myapp/appbar_provider.dart';
import 'package:myapp/home.dart';
import 'package:myapp/login.dart';
import 'package:myapp/parameter.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomeScreen(),
    const LoginScreen(),
    const ParameterScreen(),
  ];

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppProvider>(
      create: (context) => AppProvider(),
      builder: (context, _) {
        final appProvider = Provider.of<AppProvider>(context);
        return MaterialApp(
          darkTheme: ThemeData.dark(),
          title: 'My Flutter App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[900],
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Ocr Scan',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              backgroundColor: appProvider.appColor,
            ),
            body: _children[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: onTabTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.red),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.login, color: Colors.green),
                  label: 'Login',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Colors.blue),
                  label: 'Paramètres',
                ),
              ],
            ),
          ),
        );
      });

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
