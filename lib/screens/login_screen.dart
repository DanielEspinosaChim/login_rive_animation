import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  //control para ocultal y mostrar contraseña
  //el giuon bajo es ina varaible ams pricada
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {

    //para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: size.width,
                child: RiveAnimation.asset('assets/login_bear.riv'),
              ), // SizedBox
              //para separa widgets
              SizedBox(height: 10),
              //campo de texto para el email
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration( 
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //campo de texto para la contraseña
              TextField(
                obscureText:  _obscureText, //para ocultar la contraseña
                decoration: InputDecoration( 
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      //el if ternario es para escribir un if else de fomra sencilla o corta
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ), // Column
        ), // Padding
      ),
    );
  }
}