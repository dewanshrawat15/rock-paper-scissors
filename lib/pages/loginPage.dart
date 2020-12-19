import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'buttonBuilder.dart';
import 'package:flare_flutter/flare_actor.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _visible = false;

  void showProgress() {
    setState(() {
      _visible = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 72,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.4,
                height: MediaQuery.of(context).size.height / 2.4,
                child: FlareActor(
                  "assets/flares/timer.flr",
                  fit: BoxFit.contain,
                  animation: "move",
                )
              ),
              SizedBox(
                height: 42,
              ),
              Text(
                "Rock Paper Scissors",
                style: TextStyle(
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontFamily: "Josefin Sans"
                )
              ),
              SizedBox(
                height: 18,
              ),
              Text(
                "Got bored of your UT's? Got you covered!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontFamily: "Josefin Sans"
                )
              ),
              SizedBox(
                height: 54,
              ),
              _loginButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return GoogleSignInButton(
      progressVisible: _visible,
      onPressed: () async {
        showProgress();
        bool res = await AuthProvider().signInWithGoogle();
        if (!res){
          setState(() {
            _visible = false;
          });
        }
      },
      borderRadius: 20.0,
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final String text;
  final double borderRadius;
  final VoidCallback onPressed;
  final bool progressVisible;

  GoogleSignInButton({
    this.onPressed,
    this.text = 'Sign in with',
    this.borderRadius = 3.0,
    this.progressVisible = false,
  });

  Widget progressImage() {
    return progressVisible
        ? Padding(
            padding: EdgeInsets.all(5.0),
            child: CircularProgressIndicator(),
          )
        : Image(
            image: AssetImage("assets/images/google_logo.png"),
            height: 20.0,
            width: 20.0,
          );
  }

  @override
  Widget build(BuildContext context) {
    return StretchableButton(
      buttonColor: Color(0xFF4285F4),
      borderRadius: borderRadius,
      onPressed: onPressed,
      buttonPadding: 0.0,
      children: <Widget>[
        SizedBox(width: 14.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontFamily: "Josefin Sans",
              fontWeight: FontWeight.bold
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            height: 38.0,
            width: 38.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(this.borderRadius),
            ),
            child: Center(
              child: progressImage(),
            ),
          ),
        ),
      ],
    );
  }
}