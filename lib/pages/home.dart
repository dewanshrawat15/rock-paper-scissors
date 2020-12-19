import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'gameScreen.dart';
import 'package:share/share.dart';

class HomeScreen extends StatefulWidget {

  final String name, email, username, profileImageUrl;
  HomeScreen({
    @required this.name,
    @required this.email,
    @required this.username,
    @required this.profileImageUrl
  });
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FocusNode roundsFocusNode = FocusNode();
  TextEditingController roundsController = TextEditingController();

  FocusNode roomIdFocusNode = FocusNode();
  TextEditingController roomIdController = TextEditingController();
  DocumentSnapshot doc;
  String playerRoomId;

  String convertEmailToUsername(String email){
    String username = email.split("@")[0];
    return username;
  }

  Future<void> showJoinRoomDialog() async{
    return showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(
            'Room ID',
            style: TextStyle(
              fontFamily: "Josefin Sans",
              fontWeight: FontWeight.bold
            )
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  focusNode: roomIdFocusNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.red,
                  controller: roomIdController,
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: "Josefin Sans",
                    fontWeight: FontWeight.bold
                  ),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 1.0
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard,
                      color: Colors.red
                    ),
                    labelText: 'Enter Room ID',
                    labelStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: "Josefin Sans"
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Join Room',
                style: TextStyle(
                  fontFamily: "Josefin Sans",
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              onPressed: () async {
                var roomId = roomIdController.text.toString();
                DocumentReference gameRoomDocRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
                DocumentSnapshot roomGameSnapshot = await gameRoomDocRef.get();
                Map<String, dynamic> gameDetails = roomGameSnapshot.data();
                String username = convertEmailToUsername(widget.email);
                print(gameDetails.containsKey(username));
                if(gameDetails.containsKey(username)){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => GameScreen(
                        email: widget.email,
                        roomCode: roomId,
                      )
                    )
                  );
                }
                else{
                  gameDetails[username] = {
                    "score": 0
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => GameScreen(
                        email: widget.email,
                        roomCode: roomId,
                      )
                    )
                  );
                  await gameRoomDocRef.set(gameDetails);
                }
              },
            ),
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: "Josefin Sans",
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Future<void> showCreateRoomDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Number of rounds',
            style: TextStyle(
              fontFamily: "Josefin Sans",
              fontWeight: FontWeight.bold
            )
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  focusNode: roundsFocusNode,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.red,
                  controller: roundsController,
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: "Josefin Sans",
                    fontWeight: FontWeight.bold
                  ),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 1.0
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard,
                      color: Colors.red
                    ),
                    labelText: 'Number of rounds',
                    labelStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: "Josefin Sans"
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              focusColor: Colors.redAccent,
              highlightColor: Colors.redAccent,
              hoverColor: Colors.redAccent,
              child: Text(
                'Approve',
                style: TextStyle(
                  fontFamily: "Josefin Sans",
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              onPressed: () async {
                Random randomSeedSource = Random();
                var newGameRoomCode = 1000000 + randomSeedSource.nextInt(99999999);
                var gameDoc = FirebaseFirestore.instance.collection("rooms").doc(newGameRoomCode.toString());
                String username = convertEmailToUsername(widget.email);
                Map<String, dynamic> userGameDetails = {
                  "rounds": int.parse(roundsController.text.toString()),
                  username: {
                    "score": 0
                  }
                };
                await gameDoc.set(userGameDetails);
                roundsController.clear();
                Share.share("Hey\nJoin me in a game of rock paper scissors. Room code is " + newGameRoomCode.toString());
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: "Josefin Sans",
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  setPersonDoc() async{
    var ref = FirebaseFirestore.instance.collection("users");
    doc = await ref.doc(widget.email).get();
    setState((){});
  }

  @override
  void initState() {
    setPersonDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage(
              "assets/images/icon.png"
            ),
          ),
          SizedBox(
            height: 96,
          ),
          InkWell(
            onTap: () async {
              showCreateRoomDialog();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(72)
              ),
              child: Container(
                width: MediaQuery.of(context).size.width / 2.4,
                height: 42,
                child: Center(
                  child: Text(
                    "Start a game",
                    style: TextStyle(
                      fontFamily: "Josefin Sans",
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                color: Colors.redAccent,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          InkWell(
            onTap: (){
              showJoinRoomDialog();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(72)
              ),
              child: Container(
                width: MediaQuery.of(context).size.width / 2.4,
                height: 42,
                child: Center(
                  child: Text(
                    "Join a game",
                    style: TextStyle(
                      fontFamily: "Josefin Sans",
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                color: Colors.redAccent,
              ),
            ),
          )
        ],
      ),
    );
  }
}