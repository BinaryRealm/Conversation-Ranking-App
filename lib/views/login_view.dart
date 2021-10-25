import 'package:chat_app/driver.dart';
import 'package:chat_app/views/register_view.dart';
import 'package:chat_app/auth_class.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/ui/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController, _passwordController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  bool _loading = false;
  String _email = "";
  String _password = "";
  User? user;

  @override
  Widget build(BuildContext context) {
    final emailInput = TextFormField(
      autocorrect: false,
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      decoration: const InputDecoration(
          labelText: "EMAIL ADDRESS",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          hintText: 'Enter Email'),
    );
    final passwordInput = TextFormField(
      autocorrect: false,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "PASSWORD",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        hintText: 'Enter Password',
        suffixIcon: Padding(
          padding: EdgeInsets.all(15), // add padding to adjust icon
          child: Icon(Icons.lock),
        ),
      ),
    );
    final submitButton = OutlinedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Processing Data')));
          _email = _emailController.text;
          _password = _passwordController.text;

          // _emailController.clear();
          // _passwordController.clear();

          setState(() {
            _loading = true;
          });
          user = await FireAuthClass.loginEmailPassword(
              email: _email, password: _password);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (con) => AppDriver()));

          setState(() {
            _loading = false;
          });
        }
      },
      child: const Text('Login'),
    );
    final registerButton = OutlinedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (con) => const RegisterPage()));
      },
      child: const Text('Register'),
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            user != null
                ? Container() //Text(_auth.currentUser!.uid)
                : _loading
                    ? Loading()
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            emailInput,
                            const SizedBox(height: 10.0),
                            passwordInput,
                            submitButton,
                            registerButton
                          ],
                        ),
                      )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
