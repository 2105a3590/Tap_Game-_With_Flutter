import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(TapGameApp());
}

class TapGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: TapGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TapGameScreen extends StatefulWidget {
  @override
  _TapGameScreenState createState() => _TapGameScreenState();
}

class _TapGameScreenState extends State<TapGameScreen>
    with TickerProviderStateMixin {
  int score = 0;
  int timeLeft = 30;
  bool gameActive = false;
  List<Target> targets = [];
  Timer? gameTimer;
  Timer? targetTimer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      gameActive = true;
      targets.clear();
    });

    // Game countdown timer
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });
      if (timeLeft <= 0) {
        endGame();
      }
    });

    // Target spawning timer
    targetTimer = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (gameActive) {
        spawnTarget();
      }
    });
  }

  void spawnTarget() {
    if (targets.length < 5) {
      setState(() {
        targets.add(Target(
          id: DateTime.now().millisecondsSinceEpoch,
          x: random.nextDouble() * 300 + 50,
          y: random.nextDouble() * 400 + 100,
          color: Colors.primaries[random.nextInt(Colors.primaries.length)],
        ));
      });

      // Remove target after 2 seconds if not tapped
      int currentTargetId = targets.last.id;
      Timer(Duration(seconds: 2), () {
        setState(() {
          targets.removeWhere((target) => target.id == currentTargetId);
        });
      });
    }
  }

  void tapTarget(int targetId) {
    setState(() {
      targets.removeWhere((target) => target.id == targetId);
      score += 10;
    });
  }

  void endGame() {
    setState(() {
      gameActive = false;
      targets.clear();
    });
    gameTimer?.cancel();
    targetTimer?.cancel();
  }

  void resetGame() {
    gameTimer?.cancel();
    targetTimer?.cancel();
    setState(() {
      score = 0;
      timeLeft = 30;
      gameActive = false;
      targets.clear();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    targetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Tap Game', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Game stats
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('SCORE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('$score', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('TIME', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('$timeLeft', style: TextStyle(
                      color: timeLeft <= 10 ? Colors.red : Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    )),
                  ],
                ),
                Column(
                  children: [
                    Text('TARGETS', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('${targets.length}', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          // Game area
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[900]!, Colors.grey[850]!],
                      ),
                    ),
                  ),
                  
                  // Targets
                  ...targets.map((target) => Positioned(
                    left: target.x,
                    top: target.y,
                    child: GestureDetector(
                      onTap: () => tapTarget(target.id),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: target.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: target.color.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                  
                  // Game start/end overlay
                  if (!gameActive) Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 20),
                        Text(
                          timeLeft == 0 ? 'Game Over!' : 'Tap Game',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (timeLeft == 0)
                          Text(
                            'Final Score: $score',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                timeLeft == 0 ? 'Play Again' : 'Start Game',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            if (timeLeft == 0) ...[
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: resetGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text('Reset', style: TextStyle(fontSize: 18)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Instructions
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              gameActive 
                ? 'Tap the colored circles to score points!' 
                : 'Tap as many targets as you can in 30 seconds!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class Target {
  final int id;
  final double x;
  final double y;
  final Color color;

  Target({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
  });
}