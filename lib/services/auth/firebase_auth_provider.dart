import 'package:firebase_auth/firebase_auth.dart' 
        show FirebaseAuth , FirebaseAuthException ;
import 'package:firebase_core/firebase_core.dart';
        

import 'package:testapp/services/auth/auth_provider.dart';
import 'package:testapp/services/auth/auth_user.dart';
import 'package:testapp/services/auth/auth_exception.dart';

import '../../firebase_options.dart';


class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async{
    await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
  }


  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password);
        final user = currentUser;
        if(user != null){
          return user;
        }else{
          throw UserNotFoundAuthException();
        }
    }on FirebaseAuthException catch(e){
                    if(e.code == "email-already-in-use"){
                      throw EmailAlreadyInUseAuthException();
                    }else if(e.code == 'weak-password') {
                      throw WeakPasswordAuthException();
                    }else if (e.code == "invalid-email") {
                      throw InvalidEmailAuthException();                      
                    }else{
                      throw GenericAuthException();
                    }
    } catch (_){
      throw GenericAuthException();
    }
  }

  @override
  AuthUser ? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null ){
      return AuthUser.fromFirebase(user,user);
    }else{
      null;
    }
  }

  @override
  Future<void> logOut() async{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null ){
      await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLogedInAuthException();
    }
  }

  @override
  Future<AuthUser> login({
    required String email, 
    required String password}) async{
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword
        (email: email, password: password);
        final user = currentUser;
        if(user != null){
          return user;
        }else{
          throw UserNotLogedInAuthException();
        }
      }on FirebaseAuthException catch (e){
                    if (e.code == 'user-not-found'){
                      throw UserNotFoundAuthException();
                    }else if(e.code == 'wrong-Password'){
                      throw WrongPasswordAuthException();
                    }else{
                      throw GenericAuthException();
                    }
      }catch(e){
        throw GenericAuthException();
      }
  }

  @override
  Future<void> sendEmailVerification() async{
    final user = FirebaseAuth.instance.currentUser ;
    if(user != null){
      await user.sendEmailVerification;
    }else{
      throw UserNotLogedInAuthException();
    }
  }

}