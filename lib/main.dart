
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/splash_screen.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Res.firebaseToken = await FirebaseMessaging.instance.getToken(
      vapidKey:
      'BL1t9O30WLWG_8R1j-nIkajcnoJZIx52PP8ymekkz-tEMcPHWoIjtOv6a6-yimdFN5ev54oN_r_vin0oLvQkh3k');
  await Hive.initFlutter();
  await Hive.openBox('user');
  await Hive.openBox('settings');
  Get.put(HomeController(), permanent: true);
  runApp(RouteObserverProvider(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      title: 'Speedoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const SplashScreen(),
    );
  }
}
