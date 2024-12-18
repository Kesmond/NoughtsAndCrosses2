import 'package:flutter/material.dart';
import 'GoesFirst.dart';
import 'GameMenu.dart';

class MenuScreen extends StatelessWidget{
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20
          ),
        ),
        backgroundColor: Colors.blue
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Tic Tac Toe',
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 30),
            const Text(
              'Choose a Mode',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('2 Player Mode'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameMenu(mode: '2 Player', first: true),),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Hard Mode'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoesFirst(),),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}