import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:developer' as devTools show log;

import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';

import '../enums/menu_actions.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Ui'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devTools.log(shouldLogout.toString());
                  if(shouldLogout??true){
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute, (_) => false);
                  }                  
                  break;
              }            
          },itemBuilder: (context){
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'))
            ];            
          },)
        ],
      ),
    );
  }
}

Future<bool?> showLogOutDialog (BuildContext context){
  return showDialog<bool> (
    context: context,
    builder: (context){
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are You Sure You Want To Sign Out ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),),
          TextButton(onPressed: () {
            Navigator.of(context).pop(true);
          }, 
          child: const Text('Logout'),)  
        ],
      );
    }
  );
}