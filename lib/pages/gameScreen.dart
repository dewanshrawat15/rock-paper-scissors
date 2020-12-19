import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resultScreen.dart';

class GameScreen extends StatefulWidget {

  final String email, roomCode;
  GameScreen({
    @required this.email,
    @required this.roomCode
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  bool hasLoaded = false;
  Map<String, dynamic> playerMap = {};
  Map<String, dynamic> opponentMap = {};

  String convertEmailToUsername(String email){
    String username = email.split("@")[0];
    return username;
  }

  String convertUsernameToEmail(String username){
    return username + "@gmail.com";
  }

  getUserDetails() async {
    var gameRef = await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).get();
    Map<String, dynamic> gameDetails = gameRef.data();
    List<String> keys = gameDetails.keys.toList();
    keys.remove(convertEmailToUsername(widget.email));
    keys.remove("rounds");
    CollectionReference usersRef = FirebaseFirestore.instance.collection("users");
    DocumentSnapshot playerDocSnapshot = await usersRef.doc(widget.email).get();
    playerMap = playerDocSnapshot.data();
    if(keys.length == 1){
      DocumentSnapshot opponentDocSnapshot = await usersRef.doc().get();
      opponentMap = opponentDocSnapshot.data();
    }
    setState(() {
      hasLoaded = true;
    });
  }

  handleResultScreenPush(Map<String, dynamic> gameCurrentData) async {
    String winnerImage, winnerUsername, looserUsername, looserImage;
    int playerScore = gameCurrentData[convertEmailToUsername(widget.email)]["score"];
    List ks = gameCurrentData.keys.toList();
    ks.remove("rounds");
    ks.remove(convertEmailToUsername(widget.email));
    int opponentScore = gameCurrentData[ks[0]]["score"];
    var player = await FirebaseFirestore.instance.collection("users").doc(widget.email).get();
    var playerData = player.data();
    var opponent = await FirebaseFirestore.instance.collection("users").doc(convertUsernameToEmail(ks[0])).get();
    var opponentData = opponent.data();
    if(playerScore > opponentScore){
      winnerImage = playerData["photoUrl"];
      winnerUsername = convertEmailToUsername(playerData["email"]);
      looserImage = opponentData["photoUrl"];
      looserUsername = ks[0];
    }
    else{
      winnerImage = opponentData["photoUrl"];
      winnerUsername = ks[0];
      looserImage = playerData["photoUrl"];
      looserUsername = convertEmailToUsername(playerData["email"]);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ResultScreen(
          winnerImage: winnerImage,
          winnerUsername: winnerUsername,
          looserUsername: looserUsername,
          looserImage: looserImage
        )
      )
    );
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: hasLoaded ? StreamBuilder(
        stream: FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            Map<String, dynamic> gameCurrentData = snapshot.data.data();

            if(gameCurrentData["rounds"] == 0){
              handleResultScreenPush(gameCurrentData);
            }

            bool hasOtherPlayerJoined = false;
            List<String> keys = gameCurrentData.keys.toList();
            keys.remove(convertEmailToUsername(widget.email));
            keys.remove("rounds");
            if(keys.isEmpty){
              hasOtherPlayerJoined = false;
            }
            else{
              hasOtherPlayerJoined = true;
            }
            String opponentUsername = keys[0];
            Widget playerMoveWidget, opponentMoveWidget;
            if(hasOtherPlayerJoined){
              Map<String, dynamic> playerMoveDetails = gameCurrentData[convertEmailToUsername(widget.email)];
              Map<String, dynamic> opponentMoveDetails = gameCurrentData[convertEmailToUsername(keys[0])];
              if(playerMoveDetails.containsKey("move") && opponentMoveDetails.containsKey("move")){
                String playerMove, opponentMove;
                playerMove = playerMoveDetails["move"];
                opponentMove = opponentMoveDetails["move"];
                String playerResultString, opponentResultString;
                int playerScore, opponentScore, rounds;
                rounds = gameCurrentData["rounds"];
                playerScore = playerMoveDetails["score"];
                opponentScore = opponentMoveDetails["score"];
                if(playerMove == "rock"){
                  switch (opponentMove) {
                    case "rock":
                      playerResultString = "Draw";
                      opponentResultString = "Draw";
                      break;
                    case "paper":
                      playerResultString = "Lost to paper";
                      opponentResultString = "Wham, paper wraps rock";
                      opponentScore = opponentScore + 10;
                      rounds = rounds - 1;
                      break;
                    case "scissors":
                      playerResultString = "Boom, scissors - broken";
                      opponentResultString = "Crushed by rock";
                      playerScore = playerScore + 10;
                      rounds = rounds - 1;
                      break;
                  }
                }
                if(playerMove == "paper"){
                  switch (opponentMove) {
                    case "rock":
                      playerResultString = "Wham, paper wraps rock";
                      opponentResultString = "Lost to paper";
                      playerScore = playerScore + 10;
                      rounds = rounds - 1;
                      break;
                    case "paper":
                      playerResultString = "Draw";
                      opponentResultString = "Draw";
                      break;
                    case "scissors":
                      playerResultString = "Ouch, Sharp pointy scissors";
                      opponentResultString = "Shredded paper to pieces";
                      opponentScore = opponentScore + 10;
                      rounds = rounds - 1;
                      break;
                  }
                }
                if(playerMove == "scissors"){
                  switch (opponentMove) {
                    case "rock":
                      playerResultString = "Crushed by rock";
                      opponentResultString = "Boom, scissors - broken";
                      opponentScore = opponentScore + 10;
                      rounds = rounds - 1;
                      break;
                    case "paper":
                      playerResultString = "Shredded paper to pieces";
                      opponentResultString = "Ouch, Sharp pointy scissors";
                      playerScore = playerScore + 10;
                      rounds = rounds - 1;
                      break;
                    case "scissors":
                      playerResultString = "Draw";
                      opponentResultString = "Draw";
                      break;
                  }
                }
                playerMoveDetails.remove("move");
                opponentMoveDetails.remove("move");
                playerMoveDetails["score"] = playerMoveDetails["score"] + playerScore;
                opponentMoveDetails["score"] = opponentMoveDetails["score"] + opponentScore;
                gameCurrentData[convertEmailToUsername(widget.email)] = playerMoveDetails;
                gameCurrentData[opponentUsername] = opponentMoveDetails;
                gameCurrentData["rounds"] = rounds;
                FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).set(gameCurrentData);
                playerMoveWidget = Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18
                  ),
                  child: Text(
                    playerResultString,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: "Josefin Sans"
                    ),
                  )
                );
                opponentMoveWidget = Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18
                  ),
                  child: Text(
                    opponentResultString,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: "Josefin Sans"
                    ),
                  )
                );
              }
              else{
                if(playerMoveDetails.containsKey("move") && !opponentMoveDetails.containsKey("move")){
                  String imgPath;
                  switch (playerMoveDetails["move"]) {
                    case "rock":
                      imgPath = "assets/images/rock.png";
                    break;
                    case "paper":
                      imgPath = "assets/images/paper.png";
                    break;
                    case "scissors":
                      imgPath = "assets/images/scissors.png";
                    break;
                  }
                  playerMoveWidget = CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(imgPath)
                  );
                  opponentMoveWidget = Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18
                    ),
                    child: Text(
                      "Waiting for opponent's move",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Josefin Sans"
                      ),
                    )
                  );
                }
                else{
                  if(!playerMoveDetails.containsKey("move") && opponentMoveDetails.containsKey("move")){
                    playerMoveWidget = Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18
                      ),
                      child: Text(
                        "Waiting for your move",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Josefin Sans"
                        ),
                      )
                    );
                    opponentMoveWidget = Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18
                      ),
                      child: Text(
                        "Opponent has played",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Josefin Sans"
                        ),
                      )
                    );
                  }
                  else{
                    playerMoveWidget = Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18
                      ),
                      child: Text(
                        "Waiting for your move",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Josefin Sans"
                        ),
                      )
                    );
                    opponentMoveWidget = Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18
                      ),
                      child: Text(
                        "Waiting for opponent's move",
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Josefin Sans"
                        ),
                      )
                    );
                  }
                }
              }
            }
            return hasOtherPlayerJoined ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 15,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Rounds:" + gameCurrentData["rounds"].toString(),
                          style: TextStyle(
                            fontFamily: "Josefin Sans",
                            fontSize: 25
                          )
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 54,
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 24
                        ),
                        color: Colors.grey[300],
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "@" + convertEmailToUsername(widget.email),
                                    style: TextStyle(
                                      fontFamily: "Josefin Sans",
                                      fontSize: 20,
                                      color: Colors.black
                                    )
                                  ),
                                  Text(
                                    gameCurrentData[convertEmailToUsername(widget.email)]["score"].toString(),
                                    style: TextStyle(
                                      fontFamily: "Josefin Sans",
                                      fontSize: 24,
                                      color: Colors.black
                                    )
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 32,),
                            playerMoveWidget,
                            SizedBox(height: 32,),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      String username = convertEmailToUsername(widget.email);
                                      var docRef = await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).get();
                                      Map<String, dynamic> gameDet = docRef.data();
                                      print(gameDet[username]);
                                      if(!gameDet[username].containsKey("move")){
                                        gameDet[username]["move"] = "rock";
                                        await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).set(gameDet);
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 21,
                                      backgroundImage: AssetImage(
                                        "assets/images/rock.png"
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      String username = convertEmailToUsername(widget.email);
                                      var docRef = await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).get();
                                      Map<String, dynamic> gameDet = docRef.data();
                                      print(gameDet[username]);
                                      if(!gameDet[username].containsKey("move")){
                                        gameDet[username]["move"] = "paper";
                                        await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).set(gameDet);
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 21,
                                      backgroundImage: AssetImage(
                                        "assets/images/paper.png"
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      String username = convertEmailToUsername(widget.email);
                                      var docRef = await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).get();
                                      Map<String, dynamic> gameDet = docRef.data();
                                      print(gameDet[username]);
                                      if(!gameDet[username].containsKey("move")){
                                        gameDet[username]["move"] = "scissors";
                                        await FirebaseFirestore.instance.collection("rooms").doc(widget.roomCode).set(gameDet);
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 21,
                                      backgroundImage: AssetImage(
                                        "assets/images/scissors.png"
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 8
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 24
                        ),
                        color: Colors.grey[300],
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "@" + opponentUsername,
                                    style: TextStyle(
                                      fontFamily: "Josefin Sans",
                                      fontSize: 20,
                                      color: Colors.black
                                    )
                                  ),
                                  Text(
                                    gameCurrentData[opponentUsername]["score"].toString(),
                                    style: TextStyle(
                                      fontFamily: "Josefin Sans",
                                      fontSize: 24,
                                      color: Colors.black
                                    )
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 32,),
                            opponentMoveWidget,
                            SizedBox(height: 32,),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ) : WaitingForPlayerToJoin();
          }
          else{
            return Center(child: CircularProgressIndicator());
          }
        },
      ) : Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}

class WaitingForPlayerToJoin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
          ),
          CircularProgressIndicator(),
          SizedBox(
            height: 32,
          ),
          Text(
            "Waiting for other player to join",
            style: TextStyle(
              fontFamily: "Josefin Sans",
              fontSize: 25
            ),
          )
        ],
      ),
    );
  }
}