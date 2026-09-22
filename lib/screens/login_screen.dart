import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //inmportar el timer;
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
  
  //2.1 veriable para el recorrido de la mirada
  SMIInput<double>? _numLook; //controla hacia donde mira el oso (0-100)

  //3.2 timer para deter la mirada al dejar de escribir
  Timer? _typingDebounce;

  //un FocusNode por campo: toda la animacion se controla exclusivamente desde aqui
  //crear variables para focus node
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  //PASO 1.2 cerar un listener para el focus node, para saber cuando el usuario esta escribiendo en el campo de texto
  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //Verificar que no sea nulo
        if (_isHandsUp != null) {
          //Manos arriba en el email
          _isHandsUp?.change(false);
          //2.2 Mirada neutral 
          _numLook?.value = 50;
        }
      }
    });

    _passwordFocusNode.addListener(() {
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
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
                  //2.3 vincular la variable de _numLook con la entrada de la state machine
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
                //PASO 2.4: mover la mirada del oso segun cuanto texto lleva escrito
                onChanged: (value) {
                  //guard clause: si la state machine aun no esta lista, no hacer nada
                  if (_isChecking == null) return;
                  _isChecking?.change(true);
                  //calibracion: a los 80 caracteres el oso ya mira al 100%
                  //clamp(0.0, 1.0) limita el resultado entre 0 y 1 antes de pasarlo a 0-100
                  final look = (value.length / 80).clamp(0.0, 1.0) * 100;
                  _numLook?.change(look);

                  //3.3 debounce: cada vez que se vuelve a teclear, se reinicia el contador
                  _typingDebounce?.cancel();
                  //crear un nuevo timer
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    //cuando el timer se cumple (dejaste de escribir 3s), el oso vuelve a neutral
                    if (!mounted) return;
                    _isChecking?.change(false);
                    _numLook?.change(50);
                  });
                },
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
  //1.4 liberar recursos al salir de la pantalla
  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //liberar el timer
    _typingDebounce?.cancel();
    super.dispose();

  }
}

