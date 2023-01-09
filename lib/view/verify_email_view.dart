import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/view/login_view.dart';
import 'package:testapp/view/register_view.dart';



class verifyEmailView extends StatefulWidget {
  const verifyEmailView({super.key});

  @override
  State<verifyEmailView> createState() => _verifyEmailViewState();
}

class _verifyEmailViewState extends State<verifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
          children: [
            const Text("We've send you the email for verification. "),
            const Text("If Email not received Click on this button."),
            TextButton(
              onPressed: () async{
                AuthService.firebase().sendEmailVerification();
              },
            child: const Text('Send Email Verification'),
            ),
            TextButton(
              onPressed: () async{
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
              }, 
              child: const Text('Restart'))
          ],
        ),
    );
  }
}