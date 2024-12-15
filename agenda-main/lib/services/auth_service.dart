
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> sendEmailVerificationLink()async{
    try{
      await _auth.currentUser?.sendEmailVerification();
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> sendPasswordResetLink(String email)async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print(e.toString());
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password)async{

    try{
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch(e){
      exceptionhandler(e.code);
    } catch (e) {
        log("Algo deu errado");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(String email, String password)async{

    try{
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    }on FirebaseAuthException catch(e){
      exceptionhandler(e.code);
    } catch (e) {
        log("Algo deu errado");
    }
    return null;
  }

  Future<void> signout() async{
    try{
      await _auth.signOut();
    }catch(e){
      log("Algo deu errado");
    }
  }
}

exceptionhandler(String code){
  switch(code){
    case "invalid-credentials":
      log('Suas credenciais estão invalidas');
    case "weak-password":
      log('Sua senha deve ter no minímo 8 caracteres');
    case "email-already-in-use":
      log('Esse email já está sendo utilizado');
    default:
      log("Algo deu errado");
    
  }
}