import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    //scaffold: es un widget que proporciona una estructura básica para la aplicación, como una barra de navegación, un cajón de navegación y un cuerpo, como el esqueleto de la aplicación
    //andamio
    return Scaffold(
      body: Column(
        children: [Expanded(child: RiveAnimation.asset('assets/login_bear.riv'))],
      )
    );
  }
}