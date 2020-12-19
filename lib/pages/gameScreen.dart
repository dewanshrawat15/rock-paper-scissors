import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resultScreen.dart';

class GameScreen extends StatefulWidget {

  final String name, email, imageUrl, username, roomId;
  GameScreen({
    @required this.name,
    @required this.email,
    @required this.imageUrl,
    @required this.username,
    @required this.roomId
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  bool isPlayerA = false;
  String opponentUsername, opponentImage;

  setOpponentImage(username) async{
    var ref = await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: username).get();
    var opponentDoc = ref.docs[0].data();
    opponentImage = opponentDoc["photoUrl"];
    setState((){});
  }

  setPlayerState(Map<String, dynamic> roomDetails) async{
    if(roomDetails["rounds"] == 0){
      var playerADoc = await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: roomDetails["playerA"]).get();
      var playerBDoc = await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: roomDetails["playerB"]).get();
      var playerADetails = playerADoc.docs[0].data();
      var playerBDetails = playerBDoc.docs[0].data();
      if(roomDetails["playerAScore"] > roomDetails["playerBScore"]){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ResultScreen(
              winnerImage: playerADetails["photoUrl"],
              winnerUsername: playerADetails["username"],
              looserUsername: playerBDetails["username"],
              looserImage: playerBDetails["photoUrl"]
            )
          )
        );
      }
      else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ResultScreen(
              winnerImage: playerBDetails["photoUrl"],
              winnerUsername: playerBDetails["username"],
              looserUsername: playerADetails["username"],
              looserImage: playerADetails["photoUrl"]
            )
          )
        );
      }
    }
    if(roomDetails["playerA"] == widget.username){
      isPlayerA = true;
      opponentUsername = roomDetails["playerB"];
    }
    if(roomDetails["playerB"] == widget.username){
      isPlayerA = false;
      opponentUsername = roomDetails["playerA"];
    }
    setOpponentImage(opponentUsername);
  }

  @override
  void initState() {
    super.initState();
  }

  calculateScore(String moveA, String moveB, int playerAScore, int playerBScore) async{
    if(moveA == "rock" && moveB == "paper"){
      playerBScore = playerBScore + 10;
    }
    if(moveB == "rock" && moveA == "paper"){
      playerAScore = playerAScore + 10;
    }
    if(moveA == "paper" && moveB == "scissors"){
      playerBScore = playerBScore + 10;
    }
    if(moveB == "paper" && moveA == "scissors"){
      playerAScore = playerAScore + 10;
    }
    if(moveA == "scissors" && moveB == "rock"){
      playerBScore = playerBScore + 10;
    }
    if(moveB == "scissors" && moveA == "rock"){
      playerAScore = playerAScore + 10;
    }
    var doc = await FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).get();
    var gameDetails = doc.data();
    if(gameDetails.containsKey("playerAMove") && gameDetails.containsKey("playerBMove")){
      gameDetails.remove("playerAMove");
      gameDetails.remove("playerBMove");
      gameDetails["playerAScore"] = playerAScore;
      gameDetails["playerBScore"] = playerBScore;
      gameDetails["rounds"] = gameDetails["rounds"].toDouble() - 1;
      await Future.delayed(Duration(seconds: 2));
      await FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).set(gameDetails);
    }
  }

  Widget returnPlayerPlayedMoveWidget(String move){
    // print(move);
    if(move == null){
      return Text(
        "Waiting for your response!",
        style: TextStyle(
          fontFamily: "Josefin Sans",
          fontWeight: FontWeight.bold,
          fontSize: 20
        ),
      );
    }
    else{
      if(move == "rock"){
        return Center(
          child: CircleAvatar(
            radius: 54,
            backgroundImage: AssetImage(
              "assets/images/rock.png"
            ),
          ),
        );
      }
      else if(move == "scissors"){
        return Center(
          child: CircleAvatar(
            radius: 54,
            backgroundImage: AssetImage(
              "assets/images/scissors.png"
            ),
          ),
        );
      }
      else{
        return Center(
          child: CircleAvatar(
            radius: 54,
            backgroundImage: AssetImage(
              "assets/images/paper.png"
            ),
          ),
        );
      }
    }
  }

  setMove(String move) async{
    Future.delayed(
      Duration(
        seconds: 3
      )
    );
    var doc = await FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).get();
    var gameDetails = doc.data();
    if(isPlayerA){
      gameDetails["playerAMove"] = move;
    }
    else{
      gameDetails["playerBMove"] = move;
    }
    await FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).set(gameDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            DocumentSnapshot details = snapshot.data;
            setPlayerState(details.data());
            var gameDetails = details.data();
            int playerAScore = gameDetails["playerAScore"];
            int playerBScore = gameDetails["playerBScore"];
            var playerAMove;
            var playerBMove;
            bool playerAMoveStatus;
            bool playerBMoveStatus;
            if(gameDetails.containsKey("playerAMove")){
              playerAMoveStatus = true;
              playerAMove = gameDetails["playerAMove"];
            }
            else{
              playerAMoveStatus = false;
            }
            if(gameDetails.containsKey("playerBMove")){
              playerBMoveStatus = true;
              playerBMove = gameDetails["playerBMove"];
            }
            else{
              playerBMoveStatus = false;
            }
            if(playerAMoveStatus == true && playerBMoveStatus == true){
              calculateScore(playerAMove, playerBMove, playerAScore, playerBScore);
            }
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 32
                        ),
                        child: Text(
                          "Rounds left: " + gameDetails["rounds"].toInt().toString(),
                          style: TextStyle(
                            fontFamily: "Josefin Sans",
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 1.2,
                      color: Colors.black12,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 8,
                                    top: 12
                                  ),
                                  child: Text(
                                    isPlayerA ? "Points: " + playerAScore.toString() : "Points: " + playerBScore.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Josefin Sans",
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                              ],
                            ),
                            isPlayerA ? returnPlayerPlayedMoveWidget(playerAMove) : returnPlayerPlayedMoveWidget(playerBMove),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 6,
                                left: 8,
                                right: 8
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () async{
                                      setMove("rock");
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/rock.png"
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async{
                                      setMove("paper");
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/paper.png"
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      setMove("scissors");
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/scissors.png"
                                        ),
                                      ),
                                    ),
                                  )
                                ]
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: Center(
                        child: isPlayerA ?
                        playerAMoveStatus && playerBMoveStatus ? returnPlayerPlayedMoveWidget(playerBMove) : playerBMoveStatus ? Text(
                          "Opponent played move",
                          style: TextStyle(
                            fontFamily: "Josefin Sans",
                            fontWeight: FontWeight.bold
                          ),
                        ) : Text(
                          "Waiting for opponents response",
                          style: TextStyle(
                            fontFamily: "Josefin Sans",
                            fontWeight: FontWeight.bold
                          ),
                        )
                          : playerAMoveStatus && playerBMoveStatus ? returnPlayerPlayedMoveWidget(playerAMove) : playerAMoveStatus ? Text(
                            "Opponent played move",
                            style: TextStyle(
                              fontFamily: "Josefin Sans",
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ) : Text(
                            "Waiting for opponents response",
                            style: TextStyle(
                              fontFamily: "Josefin Sans",
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          )
                      )
                    ),
                  )
                ],
              ),
            );
          }
          else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}