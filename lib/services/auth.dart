import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String getUsername(String email){
    var username = email.split("@")[0];
    return username;
  }

  Future<bool> signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount == null) return false;

    GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential authResult = await _auth.signInWithCredential(credential);

    if (authResult.user == null){
      return false;
    }

    var ref = FirebaseFirestore.instance.collection("users");
    Map<String, dynamic> userDetails = {
      "name": authResult.user.displayName,
      "email": authResult.user.email,
      "photoUrl": authResult.user.photoURL,
      "username": getUsername(authResult.user.email),
      "rooms": []
    };
    ref.doc(authResult.user.email).get().then((docSnapshot) async => {
      if(!docSnapshot.exists){
        await ref.doc(authResult.user.email).set(userDetails)
      }
    });
    return true;
  }

  Future<void> signOutGoogle() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    print("signOutWithGoogle succeeded");
  }
}