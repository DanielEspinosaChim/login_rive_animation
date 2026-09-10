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


  //crear un state machine
  StateMachineController? _controller; //el ? actiava la coactividad del nulo
  //SMI: State Machine Input
  SMIInput<bool>? _isHandsUp; //para controlar el estado de las manos
  SMIInput<bool>? _isChecking; //para controlar el estado de la cabeza
  SMIInput<bool>? _trigSuccess; //para controlar el estado de la cabeza
  SMIInput<bool>? _trigFail; //para controlar el estado de la cabeza
  SMIInput<double>? _numLook; //controla hacia donde mira el oso (0-100)

  //un FocusNode por campo: toda la animacion se controla exclusivamente desde aqui
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //al entrar al campo, el oso voltea a ver una sola vez (no lo sigue mientras escribes)
        _isHandsUp?.change(false);
        _numLook?.change(50);
        _isChecking?.change(true);
      } else {
        //al salir del campo deja de voltear
        _isChecking?.change(false);
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        //el oso se tapa los ojos con la contraseña
        _isChecking?.change(false);
        _isHandsUp?.change(true);
      } else {
        //al salir del campo se destapa
        _isHandsUp?.change(false);
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

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
                child: RiveAnimation.asset('assets/login_bear.riv',
                stateMachines: ['Login Machine'],
                //al iniciar la animacion
                onInit:(artboard){
                  _controller = StateMachineController.fromArtboard(artboard,
                  'Login Machine');
                  if(_controller == null) return;
                  //agregar controlado al tablero/escenario
                  artboard.addController(_controller!);
                  //vinvular las entradas de la state machine con las variables
                  _isChecking = _controller?.findSMI('isChecking');
                  _isHandsUp = _controller?.findSMI('isHandsUp');
                  _trigSuccess = _controller?.findSMI('trigSuccess');
                  _trigFail = _controller?.findSMI('trigFail');
                  _numLook = _controller?.findSMI('numLook');
                },
                ),
              ), // SizedBox
              //para separa widgets
              SizedBox(height: 10),
              //campo de texto para el email
              TextField(
                focusNode: _emailFocusNode,
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
                focusNode: _passwordFocusNode,
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
