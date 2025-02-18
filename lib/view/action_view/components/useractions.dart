import 'package:flutter/material.dart';
import 'package:poll_chat/view/my_profile/useractions/userallaction.dart';

class UserActions extends StatefulWidget {
  const UserActions({super.key});

  @override
  State<UserActions> createState() => _UserActionsState();
}

class _UserActionsState extends State<UserActions>
    with TickerProviderStateMixin {
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
            return TrendingViewUser();
          },
        ));
  }
}
