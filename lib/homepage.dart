import 'package:flutter/material.dart';
import 'package:peersglobleeventapp/home_page.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>HomePage()),
            );
          },
          child: const Text("Go to Home Page"),
        ),
      ),
    );
  }
}
