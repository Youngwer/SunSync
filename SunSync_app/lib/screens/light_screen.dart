import 'package:flutter/material.dart';

class LightScreen extends StatelessWidget {
  const LightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Light Adjustment'), elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lightbulb_outline, size: 100, color: Colors.amber),
            SizedBox(height: 20),
            Text('Light Adjustment Screen', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(
              'Coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
