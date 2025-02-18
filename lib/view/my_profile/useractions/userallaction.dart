import 'package:flutter/material.dart';
import 'package:poll_chat/view/my_profile/useractions/postsuser.dart';

class TrendingViewUser extends StatefulWidget {
  const TrendingViewUser({super.key});

  @override
  State<StatefulWidget> createState() => _TrendingViewUserState();
}

class _TrendingViewUserState extends State<TrendingViewUser>
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
            return PostsUser();
          },
        ));
  }
}
