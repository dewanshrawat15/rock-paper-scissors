import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pageHandler.dart';
import '../pages/splashPage.dart';
import '../pages/loginPage.dart';

String name, email, imageUrl;

class AuthHandler extends StatefulWidget {
  @override
  _AuthHandlerState createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {

  FirebaseAuth auth;

  String getUsername(String email){
    String username = email.split("@")[0];
    return username;
  }

  initApp() async {
    FirebaseApp defaultApp = await Firebase.initializeApp();
    FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: defaultApp);

    setState(() {
      auth = tempAuth;
    });
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return SplashPage();
          else if (snapshot.hasData && snapshot.data != null) {
            name = snapshot.data.displayName;
            email = snapshot.data.email;
            imageUrl = snapshot.data.photoUrl;
            return PageHandler(
              name: name,
              email: email,
              imageUrl: imageUrl,
              username: getUsername(email)
            );
          } else
            return LoginPage();
        });
  }
}
