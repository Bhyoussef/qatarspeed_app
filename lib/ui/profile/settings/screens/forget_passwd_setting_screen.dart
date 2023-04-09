import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/tools/res.dart';

class ForgetPasswdSettingScreen extends StatefulWidget {
  const ForgetPasswdSettingScreen({Key? key}) : super(key: key);

  @override
  createState() =>
      _ForgetPasswdSettingScreenState();
}

class _ForgetPasswdSettingScreenState extends State<ForgetPasswdSettingScreen> {

  @override
  void initState() {
    
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        children: [
          Text(
            'Forgot password ..',
            style: TextStyle(
              color: Colors.grey,
                fontFamily: 'arial', fontSize: Res.isPhone ? 16.0 : 19.0, fontWeight: FontWeight.w900),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Text(
              'You want to send your password to your phone number or email ?',
              style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'arial', fontSize: Res.isPhone ? 16.0 : 19.0,),
            ),
          ),

          const SizedBox(height: 20.0,),

          TextFormField(
            decoration: InputDecoration(
              prefixIcon: _prefixWidget('Phone number'),
            ),
          ),

          TextFormField(
            decoration: InputDecoration(
              prefixIcon: _prefixWidget('Email address'),
            ),
          ),


        ],
      ),
    );
  }

  Widget _doneBtn() {
    return TextButton(onPressed: () {
      Get.back(result: true);
    }, child: const Text('Done'));
  }

  Widget _prefixWidget(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('\u2022   $text :\t', style: const TextStyle(fontFamily: 'arial', fontSize: 17.0),),
      ],
    );
  }
}
