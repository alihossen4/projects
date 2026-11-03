import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              label: Text(
                "Search",
                style: TextStyle(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ),
      body: Container(),
    );
  }
}
