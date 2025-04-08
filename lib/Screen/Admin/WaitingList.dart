import 'package:flutter/material.dart';

class WaitingList extends StatefulWidget {
  const WaitingList({super.key});

  @override
  State<WaitingList> createState() => _WaitingListState();
}

class _WaitingListState extends State<WaitingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("waiting List page"),),
    );
  }
}
