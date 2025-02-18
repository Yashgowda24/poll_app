import 'package:flutter/material.dart';

class AddView extends StatefulWidget {

  const AddView({super.key});

  @override
  State<StatefulWidget> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Messages"),
      ),
      body: const SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [Center(child: Text("Add content"),)],
        ),
      )),
    );
  }
}
