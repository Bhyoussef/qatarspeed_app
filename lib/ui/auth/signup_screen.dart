import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/auth.dart';
import 'package:qatar_speed/ui/auth/login_screen.dart';
import 'package:qatar_speed/ui/main/main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String _email;
  late String _passwd;
  late String _username;

  final _usernameFocus = FocusNode();
  final _passwdFocus = FocusNode();
  final _rPasswdFocus = FocusNode();

  late final _passwdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isRequesting = false;
  String? _selectedGender;
  bool _showGenderError = false;

  @override
  void initState() {
    super.initState();
    Get.find<UserController>();
    Res.baseContext = context;
  }

  @override
  Widget build(BuildContext context) {
    //_isRequesting = false;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * .15,
                ),
                Center(
                    child: Image.asset(
                  'assets/logo2.png',
                  width: Get.width * .2,
                )),
                SizedBox(
                  height: Get.height * .02,
                ),
                _input(
                    focus: _usernameFocus,
                    nextFocus: _passwdFocus,
                    hint: 'Username',
                    autofill: [AutofillHints.newUsername],
                    onSaved: (txt) => _username = txt!,
                    validator: (txt) {
                      return (txt?.replaceAll(' ', '').isEmpty ?? false)
                          ? '     Required'
                          : null;
                    },
                    iconPref: const Icon(Icons.person)),
                const SizedBox(
                  height: 10.0,
                ),
                _input(
                    hint: 'Email address',
                    nextFocus: _usernameFocus,
                    autofill: [AutofillHints.email],
                    onSaved: (txt) => _email = txt!,
                    validator: (txt) =>
                        GetUtils.isEmail(txt!) ? null : '     Required',
                    iconPref: const Icon(Icons.email)),
                const SizedBox(
                  height: 10.0,
                ),
                _input(
                    focus: _passwdFocus,
                    controller: _passwdController,
                    nextFocus: _rPasswdFocus,
                    hint: 'Password',
                    visible: false,
                    autofill: [AutofillHints.newPassword],
                    onSaved: (txt) => _passwd = txt!,
                    validator: (txt) {
                      return (txt?.length ?? 0) < 6
                          ? '     Must be at least 6 characters'
                          : null;
                    },
                    iconPref: const Icon(Icons.lock)),
                const SizedBox(
                  height: 10.0,
                ),
                _input(
                    focus: _rPasswdFocus,
                    hint: 'Confirm password',
                    visible: false,
                    validator: (txt) {
                      return txt != _passwdController.text
                          ? '     Password doesn\'t match'
                          : null;
                    },
                    iconPref: const Icon(Icons.lock),
                    onSaved: (String? newValue) {}),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Gender'),
                          if (_showGenderError)
                            const Text(
                              'Required',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 11.0),
                            )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGender = 'Male';
                          });
                        },
                        child: Row(
                          children: [
                            IgnorePointer(
                              child: Radio<String>(
                                  value: 'Male',
                                  groupValue: _selectedGender,
                                  activeColor: Colors.black,
                                  onChanged: (gender) => setState(() {
                                        _selectedGender = gender;
                                      })),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            const Text('Male'),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGender = 'Female';
                          });
                        },
                        child: Row(
                          children: [
                            IgnorePointer(
                              child: Radio<String>(
                                  value: 'Female',
                                  groupValue: _selectedGender,
                                  activeColor: Colors.black,
                                  onChanged: (gender) => setState(() {
                                        _selectedGender = gender;
                                      })),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            const Text('Female'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: _isRequesting ? null : _signup,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999)),
                  color: Colors.black,
                  disabledTextColor: Colors.black38,
                  disabledColor: Colors.grey,
                  textColor: Colors.white,
                  minWidth: double.infinity,
                  child: const Text('Signup'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontFamily: 'arial'),
                    ),
                    InkWell(
                      onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false),
                      child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text('Login',
                              style: TextStyle(fontFamily: 'arial'))),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
      {TextEditingController? controller,
      required FormFieldSetter<String> onSaved,
      required String hint,
      required FormFieldValidator<String> validator,
      bool visible = true,
      List<String>? autofill,
      FocusNode? focus,
      FocusNode? nextFocus,
      required Icon iconPref}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        color: const Color(0xffCFCFCF),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        validator: validator,
        onSaved: onSaved,
        autofillHints: autofill,
        obscureText: !visible,
        focusNode: focus,
        controller: controller,
        style: const TextStyle(color: Colors.black87),
        keyboardType: hint.toLowerCase().contains('email')
            ? TextInputType.emailAddress
            : hint.toLowerCase() == 'password'
                ? TextInputType.visiblePassword
                : TextInputType.text,
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            nextFocus.requestFocus();
          }
        },
        decoration: InputDecoration(
          prefixIcon: iconPref,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          focusedErrorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _signup() async {
    setState(() {
      _showGenderError = false;
    });
    if (_selectedGender == null) {
      setState(() {
        _showGenderError = true;
      });
    }
    if ((_formKey.currentState?.validate() ?? false) &&
        _selectedGender != null) {
      _formKey.currentState!.save();
      setState(() {
        _isRequesting = true;
      });

      try {
        UserModel user = UserModel(
            id: -1,
            username: _username,
            email: _email,
            passwd: _passwd,
            gender: _selectedGender);
        user = await AuthWebService().signup(user);
        await Get.find<UserController>().setUser(user);
        _gotoMain();
      } on DioError catch (_) {
      } finally {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _gotoMain() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false);
  }
}
