import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/ui/auth/login_screen.dart';
import 'package:qatar_speed/ui/main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //_initFirebaseNotif();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }

  _checkLoginStatus() async {
    Get.lazyPut(() => UserController());
    final controller = Get.find<UserController>();
    controller.getLoggedUser().then((user) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => user != null
                ? const MainScreen()
                : const LoginScreen())));
  }

  /*Future<void> _initFirebaseNotif() async {

    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );


    //debugPrint('notification auth   ${settings.authorizationStatus}');
  }

  _showNotificationPermissionAlert() async {
    await showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Alert'),
      content: const Text('You will not be able even to receive realtime messages.\nThis can be undone only in system settings.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok')),
      ],
    ));
  }*/
}
