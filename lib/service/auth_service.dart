import 'package:chat_app_firebase/helper/helper_functions.dart';
import 'package:chat_app_firebase/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;

  // login function
  Future loginWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await firebaseauth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // register function
  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseauth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call database service to to update the user data
        await DatabaseService(uid: user.uid).updateUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signOut function

  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveEmailsf("");
      await HelperFunctions.saveUserNamesf("");
      await firebaseauth.signOut();
    } catch (e) {
      return null;
    }
  }
}
