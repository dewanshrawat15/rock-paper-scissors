import 'package:flutter/material.dart';
import 'services/authHandler.dart';

void main()
{
  return runApp(Application());

}

class Application extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.redAccent,
      theme: ThemeData(
        accentColor: Colors.redAccent,
        primaryColor: Colors.redAccent,
      ),
      home: AuthHandler(),
    );
  }
  
}