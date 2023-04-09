import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/auth.dart';
import 'package:qatar_speed/ui/auth/signup_screen.dart';
import 'package:qatar_speed/ui/main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email;
  late String _passwd;
  final _formKey = GlobalKey<FormState>();
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    Res.baseContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              SizedBox(
                height: Get.size.height * .2,
              ),
              Center(
                  child: Image.asset(
                    'assets/logo2.png',
                width: Get.width * .2,
              )),
              SizedBox(
                height: Get.size.height * 0.02,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: const Color(0xffCFCFCF),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                margin: const EdgeInsets.only(bottom: 20.0),
                child: TextFormField(

                  validator: (txt) {
                    return (txt?.length ?? 0) > 2 ? null : 'Required email';
                  },
                  //initialValue: 'ali123',
                  onSaved: (txt) => _email = txt!,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white),
                    focusedErrorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: const Color(0xffCFCFCF),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextFormField(
                  validator: (txt) {
                    (txt ?? '').isEmpty ? 'Password required' : null;
                    return null;
                  },
                  onSaved: (txt) {
                    _passwd = txt!;
                  },
                  autofillHints: const [AutofillHints.password],
                  //initialValue: '12345678',
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white),
                    focusedErrorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => _resetPasswdDialog(),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Forgot Password ?',
                          style: TextStyle(fontFamily: 'arial'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              MaterialButton(
                onPressed: _isRequesting ? null : _login,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999)),
                color: Colors.black,
                disabledTextColor: Colors.black38,
                disabledColor: Colors.grey,
                textColor: Colors.white,
                minWidth: double.infinity,
                child: const Text('Login'),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You don\'t have an account?',
                    style: TextStyle(fontFamily: 'arial'),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const SignupScreen())),
                    child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child: Text('Signup',
                            style: TextStyle(fontFamily: 'arial'))),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isRequesting = true;
      });
      _formKey.currentState?.save();
      try {
        final user = await AuthWebService().login(_email, _passwd);
        await Get.find<UserController>()
            .setUser(user);
        _gotoMain();
      } on DioError catch (e) {
        debugPrint('dio errorrrrr:     ${e.response?.data}');
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(e.response?.data['message'] ??
                      'Something went wrong.\nplease try again'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ok')),
                  ],
                ));
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

  _resetPasswdDialog() {
    RxInt state = 0.obs;
    String message = '';
    String email = '';
    final formKey = GlobalKey<FormState>();
    showDialog(context: context, builder: (context) => Obx(() => AlertDialog(
      title: const Text('Forgot Password'),
      content: state.value < 2 ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please enter your email id.'),
          const SizedBox(height: 20.0,),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: const Color(0xffCFCFCF),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Form(
              key: formKey,
              child: TextFormField(
                onSaved: (txt) => email = txt!,
                validator: (txt) => (txt?.isEmail ?? false) ? null : 'Required',
                enabled: state.value != 1,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white),
                  focusedErrorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          )
        ],
      ) : Text(message),
      actions: [
        TextButton(onPressed: state.value == 1 ? null : () {
          if (state.value == 0) {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              AuthWebService().forgotPassword(email).then((value) {
                message = value;
                state.value = 2;
              }).catchError((e) {
              });
              state.value = 1;
            }
          } else {
            Navigator.pop(context);
          }
        }, child: const Text('Ok'))
      ],
    )));
  }
}
