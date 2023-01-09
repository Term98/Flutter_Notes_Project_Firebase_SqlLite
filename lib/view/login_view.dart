import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/error/errorHandling.dart';
import 'package:testapp/services/auth/auth_exception.dart';
import 'package:testapp/services/auth/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect : false,
                decoration: const InputDecoration(
                  hintText: 'Enter Email Here',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect : false,
                decoration: const InputDecoration(
                  hintText: 'Enter Password Here', 
                ),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try{
                    
                    await AuthService.firebase().login(
                      email: email, 
                      password: password);

                      final User = AuthService.firebase().currentUser;
                      if(User?.isEmailVerified ?? false){
                        Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                      }else{
                        Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                      }
                      
                  } on UserNotFoundAuthException{
                      await showErrorDialog(context, 'User Not Found');
                  } on WrongPasswordAuthException{
                      await showErrorDialog(context, 'Wrong Credentials');
                  } on GenericAuthException {
                    showErrorDialog(context, 'Authentication Error');
                  }                  
                },
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false);
                },
                child: const Text('Not Registered Yet? Register Here!'))
            ],
          ),
    );
  }
}
