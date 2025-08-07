import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({super.key});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Profile"),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon:  Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
