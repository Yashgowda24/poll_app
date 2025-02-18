import 'package:flutter/material.dart';
import 'package:poll_chat/view/action_view/components/Posts.dart';

class TrendingView extends StatefulWidget {
  const TrendingView({super.key});

  @override
  State<StatefulWidget> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<TrendingView>
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
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Posts(
              type: "trending",
            );
          },
        ));
  }
}
