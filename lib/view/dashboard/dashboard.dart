import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/action_view/action_view.dart';
import 'package:poll_chat/view/chat_view/chat_view.dart';
import 'package:poll_chat/view/find_view/find_view.dart';
import 'package:poll_chat/view/home/home.dart';
import '../../view_models/controller/home_model.dart';
import '../../view_models/controller/user_preference_view_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardView();
}

class _DashboardView extends State<DashboardView> {
  final homeModel = Get.put(HomeViewModelController());
  UserPreference userPreference = UserPreference();

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const HomeView(),
    const ChatView(),
    const FindView(),
    const ActionsView(),
  ];

  final List<Color> _activeColors = [
    AppColor.lightpurpleColor,
    Colors.grey,
    AppColor.purplethintColor,
    AppColor.lightpurpleColor,
    AppColor.purpleColor,
  ];

  @override
  void initState() {
    homeModel.getUser();
    homeModel.getallUser();
    homeModel.refresh();
    fatchuser();
    super.initState();
  }

  fatchuser() async {
    String? id = await userPreference.getUserID();
    homeModel.getSingleUser(id!);
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      showHomeModal().then((value) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  BottomNavigationBarItem buildNavBarItem(
    String iconAsset,
    String label,
    int index,
    BuildContext context,
  ) {
    final bool isActive = _selectedIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = isActive ? screenWidth * 0.07 : screenWidth * 0.06;
    final paddingSize = screenWidth * 0.03;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: paddingSize, vertical: paddingSize / 2),
        decoration: BoxDecoration(
          color: isActive ? _activeColors[index] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              isActive ? iconAsset.replaceFirst('Inactive', '') : iconAsset,
              width: iconSize,
              height: iconSize,
              color: isActive ? Colors.white : null,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isActive
                    ? Padding(
                        padding: EdgeInsets.only(left: paddingSize / 2),
                        child: Text(
                          label,
                          key: ValueKey<String>(label),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('shrink')),
              ),
            ),
          ],
        ),
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    log("token ======> ${UserPreference().getAuthToken()}");
    final List<BottomNavigationBarItem> bottomNavBarItems = [
      buildNavBarItem(IconAssets.homeInactiveIcon, 'Home', 0, context),
      buildNavBarItem(IconAssets.addInactiveIcon, 'Add', 1, context),
      buildNavBarItem(IconAssets.chatInactiveIcon, 'Chat', 2, context),
      buildNavBarItem(IconAssets.findInactiveIcon, 'Find', 3, context),
      buildNavBarItem(IconAssets.actionsInactiveIcon, 'Actions', 4, context),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: bottomNavBarItems,
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.shifting,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Future<void> showHomeModal() async {
    return Get.bottomSheet(
      Container(
        width: double.infinity,
        height: 300,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColor.blackColor,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.close),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Shared Content",
                      style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Get.toNamed(RouteName.createstory);
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/moments.png',
                      height: 44,
                      width: 44,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "Create a Moment",
                      style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Get.toNamed(RouteName.createPollScreen);
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/pollcreate.png',
                      height: 44,
                      width: 44,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "Create a Poll",
                      style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Get.toNamed(RouteName.camera);
                  //Get.toNamed(RouteName.musicScreen);
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/media.png',
                      height: 44,
                      width: 44,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "Create Action",
                      style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isDismissible: false,
      barrierColor: AppColor.modalBackdropColor,
      enableDrag: false,
    );
  }
}
