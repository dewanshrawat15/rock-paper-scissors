import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'gameScreen.dart';

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
                await setPersonDoc();
                if(roomIdController.text.toString().length == 6){
                  var roomId = roomIdController.text.toString();
                  Navigator.pop(context);
                  var userDetails = doc.data();
                  List roomsList = userDetails["rooms"];
                  if(roomsList.contains(roomId)){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => GameScreen(
                          name: widget.name,
                          email: widget.email,
                          imageUrl: widget.profileImageUrl,
                          username: widget.username,
                          roomId: roomId,
                        )
                      )
                    );
                  }
                  else{
                    roomsList.add(roomId);
                    userDetails["rooms"] = roomsList;
                    Fluttertoast.showToast(
                      msg: "Joining room, please wait",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0
                    );
                    await FirebaseFirestore.instance.collection("users").doc(widget.email).set(userDetails);
                    var roomDoc = await FirebaseFirestore.instance.collection("rooms").doc(roomId).get();
                    var roomDetails = roomDoc.data();
                    roomDetails["playerB"] = widget.username;
                    roomDetails["playerBEmail"] = widget.email;
                    roomDetails["playerAScore"] = 0;
                    roomDetails["playerBScore"] = 0;
                    await FirebaseFirestore.instance.collection("rooms").doc(roomId).set(roomDetails);
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => GameScreen(
                          name: widget.name,
                          email: widget.email,
                          imageUrl: widget.profileImageUrl,
                          username: widget.username,
                          roomId: roomId,
                        )
                      )
                    );
                  }
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
                Navigator.pop(context);
                setState((){});
                if(roundsController.text.length >= 1){
                  var rnd = Random();
                  var next = rnd.nextDouble() * 1000000;
                  while (next < 100000) {
                    next *= 10;
                  }
                  var roomId = next.toInt();
                  var ref = FirebaseFirestore.instance.collection("rooms");
                  Map<String, dynamic> roomDetails = {
                    "playerA": widget.username,
                    "playerAEmail": widget.email,
                    "rounds": int.parse(roundsController.text),
                    "roomId": roomId.toString()
                  };
                  await ref.doc(roomId.toString()).set(roomDetails);
                  Map userDetails = doc.data();
                  List roomList = userDetails["rooms"];
                  roomList.add(roomId.toString());
                  userDetails["rooms"] = roomList;
                  await FirebaseFirestore.instance.collection("users").doc(widget.email).set(userDetails);                  
                  setState(() {
                    playerRoomId = roomId.toString();
                  });
                  Clipboard.setData(
                    ClipboardData(
                      text: "Room ID for Rock, Paper, Scissors is " + playerRoomId
                    )
                  );
                  Fluttertoast.showToast(
                    msg: "Room ID copied!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0
                  );
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
            onTap: (){
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