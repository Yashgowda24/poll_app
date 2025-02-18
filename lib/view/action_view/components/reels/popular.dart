import 'package:flutter/material.dart';
import 'package:poll_chat/view/action_view/components/Posts.dart';
class PopulerActions extends StatefulWidget {
  const PopulerActions({super.key});

  @override
  State<PopulerActions> createState() => _PopulerActionsState();
}

class _PopulerActionsState extends State<PopulerActions> with TickerProviderStateMixin {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemBuilder: (context, index) {
            return Posts(type: "popular",);
          },
        ));
  }}
