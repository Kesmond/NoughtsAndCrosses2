import 'package:flutter/material.dart';
import 'GameMenu.dart';

class GoesFirst extends StatelessWidget {
  const GoesFirst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose a side',
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 15),
            const Text(
              '(X goes first)',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('X'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameMenu(mode: 'Computer', first: true),)
                    );
                  }
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  child: const Text('O'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameMenu(mode: 'Computer', first: false),)
                    );
                  }
                ),
              ],
            ),
          ]
        ),
      ),
    );
  }
}