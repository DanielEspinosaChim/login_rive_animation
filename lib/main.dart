import 'package:flutter/material.dart';
import 'package:login_rive_animation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}
//stateful widget: es un widget que puede cambiar su estado interno durante su ciclo de vida
//stateless widget: es un widget que no puede cambiar su estado interno durante su ciclo de vida

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  //context: indica donde estas situado
  Widget build(BuildContext context) {
    //android stile
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}
