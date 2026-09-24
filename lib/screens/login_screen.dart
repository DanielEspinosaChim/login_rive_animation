import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //inmportar el timer;
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
//TextFieldController controla lo que obtiene lo que el suario escribe en el campo de texto

class _LoginScreenState extends State<LoginScreen> {
  //control para ocultal y mostrar contraseña
  //el giuon bajo es ina varaible ams pricada
  bool _obscureText = true;


  //crear un state machine
  StateMachineController? _controller; //el ? actiava la coactividad del nulo
  //SMI: State Machine Input
  SMIInput<bool>? _isHandsUp; //para controlar el estado de las manos
  SMIInput<bool>? _isChecking; //para controlar el estado de la cabeza
  SMITrigger? _trigSuccess; //dispara la animacion de login correcto
  SMITrigger? _trigFail; //dispara la animacion de login fallido
  
  //2.1 variable para el recorrido de la mirada
  SMIInput<double>? _numLook; //controla hacia donde mira el oso (0-100)

  //3.1 timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;

  //1.1 un FocusNode por campo: toda la animacion se controla exclusivamente desde aqui
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  //4.1 controller para manipular el texto escrito por el usuario 
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //4.2 errores apra mostar al usuario UI 
  String?emailError;
  String?passwordError;

  //4.3 validadores de email y contrasena
  bool isValidEmail(String email) {
    //expresion regular para validar el email
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }
  bool isValidPassword(String password) {
    //expresion regular para validar la contraseña
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',); 
    return re.hasMatch(password);
  }
  //4.4 accion al boton de login
  void _onLoguin(){
    final email = emailController.text.trim();
    final password = passwordController.text;

    //recalcular los errores
    final eError = isValidEmail(email) ? null : 'Invalid email';
    final pError = isValidPassword(password) ? null : 'Invalid password';

    setState(() {
      emailError = eError;
      passwordError = pError;
    });
    //4.5 cerrar el teclado y bajar las manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50;

    //4.6 activar triggers
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }
  //1.2 listeners de los focus node, para saber cuando el usuario esta escribiendo en el campo de texto
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
      //1.3 manos arriba en password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {

    //para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
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
                //2.4 mover la mirada del oso segun cuanto texto lleva escrito
                onChanged: (value) {
                  //guard clause: si la state machine aun no esta lista, no hacer nada
                  if (_isChecking == null) return;
                  _isChecking?.change(true);
                  //calibracion: a los 80 caracteres el oso ya mira al 100%
                  //clamp(0.0, 1.0) limita el resultado entre 0 y 1 antes de pasarlo a 0-100
                  final look = (value.length / 80).clamp(0.0, 1.0) * 100;
                  _numLook?.change(look);

                  //3.2 debounce: cada vez que se vuelve a teclear, se reinicia el contador
                  _typingDebounce?.cancel();
                  //crear un nuevo timer
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    //cuando el timer se cumple (dejaste de escribir 3s), el oso vuelve a neutral
                    if (!mounted) return;
                    _isChecking?.change(false);
                    _numLook?.change(50);
                  });
                },
                //4.7 enlazar el controlador de texto con el campo de email
                controller: emailController,
                decoration: InputDecoration(
                  //4.8 mostrar el error del email
                  errorText: emailError,
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

                //4.9 enlazar el controlador de texto con el campo de password
                controller: passwordController,

                obscureText:  _obscureText, //para ocultar la contraseña
                decoration: InputDecoration(
                  //4.10 mostrar el error de la contrasena
                  errorText: passwordError,
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
                //tEXTO OLVIDE MI CONTRASEÑA
                SizedBox(height: 10),
                SizedBox(
                  width: size.width,
                  child: const Text(
                    "Forgot Password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                SizedBox(height: 10),
              //4.11 boton de login
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  onPressed: _onLoguin,
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const SizedBox(height: 20),
                //no tienes cuenta? registrate
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          //navegar a la pantalla de registro
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

            ],
          ), // Column
        ), // Padding
      ),
    );
  }
  //1.4 liberar los focus node al salir de la pantalla
  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.3 liberar el timer
    _typingDebounce?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();

  }
}

