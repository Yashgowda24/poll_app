import 'package:flutter/material.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationSetting();
}

class _NotificationSetting extends State<NotificationSetting> {
  bool enablePushNotifications = false;
  bool enableEmailNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enablePushNotifications = prefs.getBool('enablePushNotifications') ?? false;
      enableEmailNotifications = prefs.getBool('enableEmailNotifications') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('enablePushNotifications', enablePushNotifications);
    prefs.setBool('enableEmailNotifications', enableEmailNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Push Notifications',
                      style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    CustomSwitch(
                      value: enablePushNotifications,
                      activeColor: AppColor.purpleColor,
                      onChanged: (value) {
                        setState(() {
                          enablePushNotifications = value;
                          _savePreferences();
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 1,
                  color: AppColor.greyLight5Color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Email Notifications',
                      style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    CustomSwitch(
                      value: enableEmailNotifications,
                      activeColor: AppColor.purpleColor,
                      onChanged: (value) {
                        setState(() {
                          enableEmailNotifications = value;
                          _savePreferences();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      activeColor: activeColor,
      inactiveThumbColor: Colors.grey,
      activeTrackColor: activeColor.withOpacity(0.5),
      onChanged: onChanged,
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColor.whiteColor;
        }
        return AppColor.lightpurpleColor;
      }),
    );
  }
}
