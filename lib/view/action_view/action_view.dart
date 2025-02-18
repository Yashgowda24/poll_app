import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/action_view/components/reels/popular.dart';
import 'package:poll_chat/view/action_view/components/trending_view.dart';
import '../../view_models/controller/music_view_model.dart';

class ActionsView extends StatefulWidget {
  const ActionsView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ActionsViewState();
}

class _ActionsViewState extends State<ActionsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final musicModelController = Get.put(MusicViewModel());

  @override
  void initState() {
    super.initState();
    musicModelController.getallMusic();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text(
                "Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.toNamed(RouteName.camera);
                  },
                  icon: const Icon(Icons.camera_alt_rounded,
                      color: AppColor.purpleColor),
                )
              ],
              pinned: true,
              floating: true,
              expandedHeight: 100.0,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColor.purpleColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColor.purpleColor,
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                unselectedLabelColor: AppColor.greyColor,
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 16),
                tabs: const [
                  Tab(
                    text: "Trending",
                  ),
                  Tab(
                    text: "Popular",
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              TrendingView(),

              PopulerActions(), // Replace with your actual content
            ],
          ),
        ),
      ),
    );
  }
}
