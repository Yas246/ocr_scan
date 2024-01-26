// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:myapp/appbar_provider.dart';
import 'package:provider/provider.dart';

class ParameterScreen extends StatefulWidget {
  const ParameterScreen({super.key});

  @override
  _ParameterScreenState createState() => _ParameterScreenState();
}

class _ParameterScreenState extends State<ParameterScreen> {
  MaterialColor _appBarColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    _appBarColor = appProvider.getAppColor;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Changer la couleur de l'AppBar:",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          DropdownButton<MaterialColor>(
            value: _appBarColor,
            onChanged: (MaterialColor? color) {
              setState(() {
                _appBarColor = color!;
                appProvider.changeAppColor(color);
              });
            },
            items: const [
              DropdownMenuItem<MaterialColor>(
                value: Colors.blue,
                child: Text('Bleue'),
              ),
              DropdownMenuItem<MaterialColor>(
                value: Colors.green,
                child: Text('Verte'),
              ),
              DropdownMenuItem<MaterialColor>(
                value: Colors.red,
                child: Text('Rouge'),
              ),
              DropdownMenuItem<MaterialColor>(
                value: Colors.orange,
                child: Text('Orange'),
              ),
              DropdownMenuItem<MaterialColor>(
                value: Colors.purple,
                child: Text('Violette'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
