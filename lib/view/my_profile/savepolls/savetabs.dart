import 'package:flutter/material.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view/my_profile/likedvideos/liked.dart';
import 'package:poll_chat/view/my_profile/savepolls/savepoll.dart';

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with TickerProviderStateMixin {
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            labelColor: AppColor.purpleColor,
            indicatorColor: AppColor.purpleColor,
            tabs: const [
              Tab(text: 'Saved Polls'),
              Tab(text: 'Save Actions'),
            ],
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              PollSaveCard(),
              VideoListScreen(),
            ],
          )),
        ],
      ),
    );
  }
}
