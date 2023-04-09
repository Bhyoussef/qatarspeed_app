import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/profile/settings/screens/forget_passwd_setting_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class PasswdSettingsScrenn extends StatefulWidget {
  const PasswdSettingsScrenn({Key? key}) : super(key: key);

  @override
  createState() => _PasswdScreenState();
}

class _PasswdScreenState extends State<PasswdSettingsScrenn>
    with RouteAware, RouteObserverMixin {
  String? _oldPasswd;
  String? _newPasswd;

  bool _isRequesting = false;

  final _passwdController = TextEditingController();

  final _passwdFocus = FocusNode();
  final _rPasswdFocus = FocusNode();

  late UserController _controller;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<UserController>();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: Res.isPhone ? 50.0 : 60.0,
                ),
                Text(
                  'Password and security',
                  style: TextStyle(
                      fontFamily: 'arial', fontSize: Res.isPhone ? 16.0 : 19.0),
                ),
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            TextFormField(
              onSaved: (txt) => _oldPasswd = txt,
              validator: (txt) => txt?.isEmpty ?? true ? 'Required' : null,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _passwdFocus.requestFocus(),
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('Current password'),
              ),
            ),
            AutofillGroup(
              child: TextFormField(
                onSaved: (txt) => _newPasswd = txt,
                validator: (txt) => txt?.isEmpty ?? true ? 'Required' : null,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _rPasswdFocus.requestFocus(),
                autofillHints: const [AutofillHints.newPassword],
                focusNode: _passwdFocus,
                obscureText: true,
                controller: _passwdController,
                decoration: InputDecoration(
                  prefixIcon: _prefixWidget('New password'),
                ),
              ),
            ),
            TextFormField(
              validator: (txt) => (txt ?? '') != _passwdController.text
                  ? 'Password doesn\'t match'
                  : null,
              obscureText: true,
              focusNode: _rPasswdFocus,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('Confirm password'),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
                onPressed: () =>
                    Get.to(() => const ForgetPasswdSettingScreen())?.then((value) {
                      if (value != null && value == true) Get.back();
                    }),
                child: const Text('Forgot password?')),
          ],
        ),
      ),
    );
  }

  Widget _doneBtn() {
    return TextButton(
        onPressed: _isRequesting
            ? null
            : _updatePasswd,
        child: const Text('Done'));
  }

  _updatePasswd() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _isRequesting = true;
      _initAppbar();
      _formKey.currentState!.save();
      final error = await _controller.updatePasswd(old: _oldPasswd!, passwd: _newPasswd!);
      if (error == null) {
        Get.back();
        return;
      }
      _isRequesting = false;
      _initAppbar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)));
      }
    }
  }

  Widget _prefixWidget(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\u2022   $text :\t',
          style: const TextStyle(fontFamily: 'arial', fontSize: 17.0),
        ),
      ],
    );
  }
}
