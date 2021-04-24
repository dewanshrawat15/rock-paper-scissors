import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {

  final String winnerUsername, winnerImage, looserUsername, looserImage;
  ResultScreen({
    @required this.winnerImage,
    @required this.winnerUsername,
    @required this.looserUsername,
    @required this.looserImage
  });

  String getBetterImageUrl(String url){
    return url.replaceFirst("=s96-c", "=s400-c");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Winner",
              style: TextStyle(
                fontFamily: "Josefin Sans",
                fontSize: 32,
                fontWeight: FontWeight.bold
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  getBetterImageUrl(winnerImage)
                ),
                radius: 54,
              ),
            ),
            Text(
              "@" + winnerUsername,
              style: TextStyle(
                fontFamily: "Josefin Sans",
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(
              height: 42,
            ),
            Text(
              "Aww, better luck next time!",
              style: TextStyle(
                fontFamily: "Josefin Sans",
                fontSize: 32,
                fontWeight: FontWeight.bold
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  getBetterImageUrl(looserImage)
                ),
                radius: 54,
              ),
            ),
            Text(
              "@" + looserUsername,
              style: TextStyle(
                fontFamily: "Josefin Sans",
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pop(context);
        },
        child: Icon(Icons.done),
      ),
    );
  }
}