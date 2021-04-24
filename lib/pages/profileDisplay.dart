import 'package:flutter/material.dart';

class ProfileDisplay extends StatelessWidget {

  final String name, picUrl, username;
  ProfileDisplay({
    @required this.name,
    @required this.picUrl,
    @required this.username
  });

  String getBetterImageUrl(String url){
    return url.replaceFirst("=s96-c", "=s400-c");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 24,
            fontFamily: "Josefin Sans",
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.chevron_left
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.5,
              ),
              CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(
                  getBetterImageUrl(picUrl)
                ),
              ),
              SizedBox(
                height: 42,
              ),
              Text(
                name,
                style: TextStyle(
                  fontFamily: "Josefin Sans",
                  fontSize: 42,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                "@" + username,
                style: TextStyle(
                  fontFamily: "Josefin Sans",
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
              )
            ],
          ),
        ),
      )
    );
  }
}