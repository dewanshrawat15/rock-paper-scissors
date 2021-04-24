import 'package:flutter/material.dart';

import 'package:flare_flutter/flare_actor.dart';

class PlayerWaitScreen extends StatefulWidget {
  final Size size;
  PlayerWaitScreen({
    @required this.size
  });

  @override
  _PlayerWaitScreenState createState() => _PlayerWaitScreenState();
}

class _PlayerWaitScreenState extends State<PlayerWaitScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.height,
      width: widget.size.width,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: widget.size.height / 5,
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
              height: 32,
            ),
            Text(
              "Waiting for opponent to join in!",
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Josefin Sans"
              )
            )
          ],
        ),
      )
    );
  }
}