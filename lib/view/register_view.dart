import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/error/errorHandling.dart';
import 'package:testapp/services/auth/auth_exception.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/view/verify_email_view.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register'),),
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
                    
                    await AuthService.firebase().createUser(
                      email: email, 
                      password: password);
                      
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(context, 'User already exist');
                  } on WeakPasswordAuthException {
                      await showErrorDialog(context, 'Enter Strong Password');
                  } on InvalidEmailAuthException {
                      await showErrorDialog(context, 'Enter Valid Email');
                  } on GenericAuthException {
                      await showErrorDialog(context, 'Failed To Register');
                  }
                },
                child: const Text("Register"),
              ),
              TextButton(
                onPressed:(){
                  Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute, 
                  (route) => false);
                } ,
                child: const Text('Already Registered? Login Here!'))
            ],
          ),
    );
  }
}