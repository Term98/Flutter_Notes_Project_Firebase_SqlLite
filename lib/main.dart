import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/view/login_view.dart';
import 'package:testapp/view/notes_view.dart';
import 'package:testapp/view/register_view.dart';
import 'package:testapp/view/verify_email_view.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( 
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute:(context) => const LoginView(),
        registerRoute:(context) => const RegisterView(),
        notesRoute:(context) => const NotesView(),
        verifyEmailRoute:(context) => const verifyEmailView(),
      },
    )
    );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

    @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot){
          switch (snapshot.connectionState) {
            case ConnectionState.done:  
            final user = AuthService.firebase().currentUser;
            print(user);
            if(user!=null){
              if(user.isEmailVerified){
                return const NotesView();
              }else{
                return const verifyEmailView();
              }           
            }else{
              return const LoginView(); 
              }             
            default:
            return const CircularProgressIndicator();
          }
        },        
      );
  }
}





