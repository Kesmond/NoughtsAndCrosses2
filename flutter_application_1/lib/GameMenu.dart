import 'package:flutter/material.dart';
import 'dart:math'; //Random function
import 'dart:async'; //Timer
import 'package:shared_preferences/shared_preferences.dart';

class GameMenu extends StatefulWidget {
  const GameMenu({required this.mode, required this.first, super.key});

  final String mode; //'Computer' or '2 Player'
  final bool first;

  @override
  State<GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  bool turn = true; //X always goes first
  List <String> board = ['', '', '', '', '', '', '', '', ''];
  String turnMessage = '';
  late int lastMark;
  bool gameOver = false;
  bool computerIsMoving = false; //Can't make a move when Computer's Turn
  late Future<Map<String, int>> record;
  int _win=0, _lose=0, _draw=0, _xWin=0, _oWin=0, _xoDraw=0;

  @override
  void initState(){
    super.initState();
    _updateRecord();
    if(widget.mode == '2 Player') {
      turnMessage = 'Player X Turn';
    }
    else if(widget.mode == 'Computer' && widget.first) {
      turnMessage = 'Your Turn';
    }
    else if(widget.mode == 'Computer' && !widget.first) {
      turnMessage = "Computer's Turn";
      computerIsMoving = true;
      Timer(const Duration(milliseconds: 1500), _computerMove);
    }
  }
  
  //Load the initial value from persistent storage on start
  //If value isn't there, make it 0
  //Save game statics
  Future<void> _setRecord() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('win', _win);
    prefs.setInt('lose', _lose);
    prefs.setInt('draw', _draw);
    prefs.setInt('xWin', _xWin);
    prefs.setInt('oWin', _oWin);
    prefs.setInt('xoDraw', _xoDraw);
  }

  //Increment and save it to persistent storage
  //Retrieve game statistics
  Future<Map<String, int>> _getRecord() async {
    final prefs = await SharedPreferences.getInstance();
    //If not present, make it 0
    int win = prefs.getInt('win') ?? 0;
    int lose = prefs.getInt('lose') ?? 0;
    int draw = prefs.getInt('draw') ?? 0;
    int xWin = prefs.getInt('xWin') ?? 0;
    int oWin = prefs.getInt('oWin') ?? 0;
    int xoDraw = prefs.getInt('xoDraw') ?? 0;
    
    return {
      'win': win,
      'lose': lose,
      'draw': draw,
      'xWin': xWin,
      'oWin': oWin,
      'xoDraw': xoDraw
    };
  }

  Future<void> _updateRecord() async {
    Map<String,int> record = await _getRecord();

    setState(() {
      _xWin = record['xWin']!;
      _oWin = record['oWin']!;
      _xoDraw = record['xoDraw']!;
      _win = record['win']!;
      _lose = record['lose']!;
      _draw = record['draw']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: Text('${widget.mode} Mode'),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),

            Row(
              children: [
                Text(
                  turnMessage,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Expanded(
              flex: 4,
              child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemCount: 9, itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _tapped(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Colors.red,
                      ),
                      color: Colors.orange[50],
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: const TextStyle(fontSize: 64, color: Colors.black),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.mode == 'Computer'
              ? [
                  Text(
                    'Win: $_win',
                    style: const TextStyle(fontSize: 20),
                  ),

                  const SizedBox(width: 30,),

                  Text(
                    'Lose: $_lose',
                    style: TextStyle(fontSize: 20),
                  ),

                  const SizedBox(width: 30,),

                  Text(
                    'Draw: $_draw',
                    style: TextStyle(fontSize: 20),
                  ),
                ]
              : widget.mode == '2 Player'
                ? [
                    Text(
                      'Player X: $_xWin',
                      style: TextStyle(fontSize: 20),
                    ),

                    const SizedBox(width: 20,),

                    Text(
                      'Player O: $_oWin',
                      style: TextStyle(fontSize: 20),
                    ),

                    const SizedBox(width: 20,),

                    Text(
                      'Draw: $_xoDraw',
                      style: TextStyle(fontSize: 20),
                    ),
                  ]
              : [],
            ),

            const SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: ElevatedButton(onPressed: _resetGame, child: const Text('Reset')),
                ),
                const SizedBox(width: 20,),
                SizedBox(
                  child: ElevatedButton(onPressed: _clearScore, child: const Text('Clear Score')),
                ),
              ],
            ),

            const SizedBox(height: 100),

            
          ],
        ),
      )
    );
  }

  void _tapped(int index) {
    if(!gameOver && !computerIsMoving && board[index] == ''){
      setState(() {
        if(turn) {board[index] = 'X';}
        else {board[index] = 'O';}
        lastMark = index;

        turn = !turn;

        if(widget.mode == '2 Player') {
          if(turn) {turnMessage = 'Player X Turn';}
          else {turnMessage = 'Player O Turn';}
        }
        else if(widget.mode == 'Computer') {
          _computerMove();
        }

        _checkWinner();
      });
    }
  }

  void _computerMove() {
    if(!gameOver) {
      setState(() {
        computerIsMoving = true;
        turnMessage = "Computer's Turn";
        //Computer Hard mode Logic with Timer
        Timer(const Duration(milliseconds: 1000), _computerLogicDelay);
      });
    }
  }

  void _computerLogicDelay() {
    int move = _computerLogic();

    //Update board
    if(move != -1 && turn) {board[move] = 'X';}
    else if (move != -1) {board[move] = 'O';}

    if(!gameOver) {
      setState(() {
        turn = !turn;
        turnMessage = 'Your Turn';
        computerIsMoving = false;
        _checkWinner();
      });
    }
  }

  int _randomNumber() {
    var availableCells = [];
    for(int t=0; t<9; t++) {
      if(board[t] == '') {
        availableCells.add(t);
      }
    }
    //Just in case
    if(availableCells.isEmpty) {
      return -1;
    }

    int randomChoice = Random().nextInt(availableCells.length);
    int move = availableCells[randomChoice];
    return move;
  }

  int _computerLogic() {
    int hardCheckLine(int a, int b, int c, String marker) {
      if(board[a] == marker && board[b] == marker && board[c] == '') {
        return c;
      }
      if(board[b] == marker && board[c] == marker && board[a] == '') {
        return a;
      }
      if(board[a] == marker && board[c] == marker && board[b] == '') {
        return b;
      }

      return 99;
    }

    late int move;

    for(int temp=0; temp<3; temp++) {
      //Rows
      move = hardCheckLine(temp * 3, temp * 3 + 1, temp * 3 + 2, 'O');
      if(move != 99) {
        return move;
      }
      move = hardCheckLine(temp * 3, temp * 3 + 1, temp * 3 + 2, 'X');
      if(move != 99) {
        return move;
      }

      //Column
      move = hardCheckLine(temp, temp + 3, temp + 6, 'O');
      if(move != 99) {
        return move;
      }
      move = hardCheckLine(temp, temp + 3, temp + 6, 'X');
      if(move != 99) {
        return move;
      }
    }

    //Diagonal
    move = hardCheckLine(0, 4, 8, 'O');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(2, 4, 6, 'O');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(0, 4, 8, 'X');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(2, 4, 6, 'X');
    if(move != 99) {
      return move;
    }

    //Two lines of two in a row
    if(board[0] == 'X' && board[8] == 'X') {
      return 1;
    }
    if(board[2] == 'X' && board[6] == 'X') {
      return 1;
    }

    move = hardCheckLine(1, 3, 0, 'O');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(1, 3, 0, 'X');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(1, 5, 2, 'O');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(1, 5, 2, 'X');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(3, 7, 6, 'O');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(3, 7, 6, 'X');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(5, 7, 8, 'O');
    if(move != 99) {
      return move;
    }
    move = hardCheckLine(5, 7, 8, 'X');
    if(move != 99) {
      return move;
    }

    //Centre is Free
    if(board[4] == '') {
      return 4;
    }

    //Opponent played in a corner, play the opposite corner
    if(lastMark == 0 && board[8] == '') {
      return 8;
    }
    else if(lastMark == 2 && board[6] == '') {
      return 6;
    }
    else if(lastMark == 6 && board[2] == '') {
      return 2;
    }
    else if(lastMark == 8 && board[0] == '') {
      return 0;
    }

    //Free corner
    if(board[0] == '') {
      return 0;
    }
    else if(board[2] == '') {
      return 2;
    }
    else if(board[6] == '') {
      return 6;
    }
    else if(board[8] == '') {
      return 8;
    }

    return _randomNumber();
  }

  void _checkWinner() {
    bool checkLine(a, b, c) {
      return board[a] != '' && board[a] == board[b] && board[a] == board[c];
    }

    bool isDraw() {
      for(int checkwin=0; checkwin<9; checkwin++) {
        if(board[checkwin] == '') {
          return false;
        }
      }
      return true;
    }

    if(gameOver) {return;}

    //Rows
    for(int row=0; row<3; row++) {
      if(checkLine(row * 3, row * 3 + 1, row * 3 + 2)) {
        _winMessage(board[row*3]);
        return;
      }
    }

    //Column
    for(int col=0; col<3; col++) {
      if(checkLine(col, col+3, col+6)) {
        _winMessage(board[col]);
        return;
      }
    }

    //Diagonal
    if(checkLine(0, 4, 8) || checkLine(2, 4, 6)) {
      _winMessage(board[4]);
      return;
    }

    //Draw
    if(isDraw()) {
      _winMessage(3);
    }

    return;
  }

  void _winMessage(winner) {
    gameOver = true;
    setState(() {
      //Draw
      if(winner == 3) {
        turnMessage = 'Draw!';
        if(widget.mode == '2 Player') {_xoDraw++;}
        else if(widget.mode == 'Computer') {_draw++;}
      }
      //2 Player mode
      else if(widget.mode == '2 Player') {
        turnMessage = 'Player $winner Wins!';
        if(winner == 'X') { _xWin++;}
        else if(winner == 'O') {_oWin++;}
      }
      else if(widget.mode == 'Computer') {
        //Human First, X = Human, O = Computer
        if(widget.first) {
          if(winner == 'X') {
            turnMessage = 'You Win!';
            _win++;
          }
          else if(winner == 'O') {
            turnMessage = 'Computer Wins!';
            _lose++;
          }
        }
        //Computer First, X = Computer, O = Human
        else {
          if(winner == 'X') {
            turnMessage = 'Computer Wins!';
            _lose++;
          }
          else if(winner == 'O') {
            turnMessage = 'You Win!';
            _win++;
          }
        }
      }
      _setRecord();
    });
  }

  void _resetGame() {
    setState(() {
      turn = true; //X goes first
      board = ['', '', '', '', '', '', '', '', ''];
      gameOver = false;

      if(widget.mode == '2 Player') {
        turnMessage = 'Player X Turn';
        computerIsMoving = false;
      }
      else if(widget.mode == 'Computer' && widget.first) {
        turnMessage = 'Your Turn';
        computerIsMoving = false;
      }
      else if(widget.mode == 'Computer' && !widget.first) {
        turnMessage = "Computer's Turn";
        computerIsMoving = true;
        Timer(const Duration(milliseconds: 1500), _computerMove);
      }
    });
  }

  void _clearScore() {
    setState(() {
      if(widget.mode == '2 Player') {
        _xWin = 0;
        _oWin = 0;
        _xoDraw = 0;
      }
      else if(widget.mode == 'Computer') {
        _win = 0;
        _lose = 0;
        _draw = 0;
      }

      _setRecord();
      _updateRecord();
    });
  }
}