import 'package:flutter/material.dart';
import '../pages/profileDisplay.dart';
import 'auth.dart';
import '../pages/home.dart';

class PageHandler extends StatefulWidget {

  final String name, email, imageUrl, username;
  PageHandler({
    @required this.name,
    @required this.email,
    @required this.imageUrl,
    @required this.username
  });

  @override
  _PageHandlerState createState() => _PageHandlerState();
}

class _PageHandlerState extends State<PageHandler>{

  @override
  void initState() {
    super.initState();
  }

  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Rock Paper Scissors!",
          style: TextStyle(
            fontFamily: "Josefin Sans",
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black
          )
        ),
        actions: <Widget>[
          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ProfileDisplay(
                    name: widget.name,
                    picUrl: widget.imageUrl,
                    username: widget.username
                  )
                )
              );
            },
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.person,
                color: Colors.black
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              AuthProvider().signOutGoogle();
              setState(() {});
            },
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.power_settings_new,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: HomeScreen(
        name: widget.name,
        email: widget.email,
        profileImageUrl: widget.imageUrl,
        username: widget.username
      )
    );
  }
}