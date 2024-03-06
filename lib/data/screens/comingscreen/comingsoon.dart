import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Coming Soon', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            const Text('Stay tuned for updates'),
            Image.asset("assets/images/maintenance_screen.png"),
          ],
        ),
      ),
    );
  }
}
