import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:poll_chat/appbinding.dart';
import 'package:poll_chat/res/routes/routes.dart';
import 'package:poll_chat/view/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

String? getGlobleToken;

// bhanu branch
void main() async {
  tz.initializeTimeZones();
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // if (WebRTC.platformIsDesktop) {
  //   debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  // } else if (WebRTC.platformIsAndroid) {}
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      title: 'Poll Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: AppRoutes.appRoutes(),
      home: const SplashScreen(),
    );
  }
}
