import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/auth.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class UserInfoSettingsScrenn extends StatefulWidget {
  const UserInfoSettingsScrenn({Key? key}) : super(key: key);

  @override
  createState() => _UserInfoSettingsScreenState();
}

class _UserInfoSettingsScreenState extends State<UserInfoSettingsScrenn>
    with RouteAware, RouteObserverMixin {

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();
  final _twitterController = TextEditingController();
  final _facebookController = TextEditingController();
  final _snapchatController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final UserModel tempUser;
  final user = Get.find<UserController>().user;
  final _nameFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _aboutFocus = FocusNode();
  final _twitterFocus = FocusNode();
  final _fbFocus = FocusNode();
  final _snapFocus = FocusNode();
  final _instagramFocus = FocusNode();
  final _tiktokFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _youtubeFocus = FocusNode();



  @override
  void initState() {
    super.initState();
    tempUser = user.clone();
    _firstNameController.text = user.firstName??'';
    _lastNameController.text = user.lastName??'';
    _emailController.text = user.email??'';
    _locationController.text = user.city??'';
    _aboutController.text = user.about??'';
    _twitterController.text = user.twitter??'';
    _facebookController.text = user.facebook??'';
    _snapchatController.text = user.snapchat??'';
    _instagramController.text = user.instagram??'';
    _tiktokController.text = user.tiktok??'';
    _whatsappController.text = user.phone??'';
    _youtubeController.text = user.youtube??'';
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
                  Icons.person,
                  size: Res.isPhone ? 50.0 : 60.0,
                ),
                Text(
                  'Personal and account information',
                  style: TextStyle(
                      fontFamily: 'arial', fontSize: Res.isPhone ? 16.0 : 19.0),
                ),
              ],
            ),

             const SizedBox(height: 40.0,),

            TextFormField(
              controller: _firstNameController,
                onSaved: (txt) {
                  tempUser.firstName = txt;
                },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nameFocus.requestFocus(),
                validator: (txt) => (txt??'').isNotEmpty ? null : 'Required',
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('First name'),
              ),
            ),
            TextFormField(
              validator: (txt) => (txt??'').isNotEmpty ? null : 'Required',
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _locationFocus.requestFocus(),
              focusNode: _nameFocus,
              onSaved: (txt) {
                tempUser.lastName = txt;
              },
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('Last name'),
              ),
            ),
            TextFormField(
              controller: _emailController,
              onFieldSubmitted: (_) => _locationFocus.requestFocus(),
              enabled: false,
              textInputAction: TextInputAction.next,
              focusNode: _locationFocus,
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('Email address'),
              ),
            ),
            TextFormField(
              controller: _locationController,
              onFieldSubmitted: (_) => _aboutFocus.requestFocus(),
              textInputAction: TextInputAction.next,
              onSaved: (txt) {
                tempUser.city = txt;
              },
              validator: (txt) => (txt??'').isNotEmpty ? null : 'Required',
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('Location'),
              ),
            ),
            TextFormField(
              controller: _aboutController,
              focusNode: _aboutFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _twitterFocus.requestFocus(),
              onSaved: (txt) {
                tempUser.about = txt;
              },
    validator: (txt) => (txt??'').isNotEmpty ? null : 'Required',
              decoration: InputDecoration(
                prefixIcon: _prefixWidget('About me'),
              ),
            ),

            const SizedBox(height: 20.0,),
            const Divider(),

            TextFormField(
              controller: _twitterController,
              focusNode: _twitterFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _fbFocus.requestFocus(),
              validator: (txt) {
                return (txt?.isEmpty??true) || GetUtils.isURL(txt??'') ? null : 'Please provide a valid url';
              },
              onSaved: (txt) {
                tempUser.twitter = txt;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesome.twitter, color: Colors.black,),
              ),
            ),
            TextFormField(
              controller: _facebookController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.url,
              validator: (txt) {
                return (txt?.isEmpty??true) || GetUtils.isURL(txt??'') ? null : 'Please provide a valid url';
              },
              onFieldSubmitted: (_) => _snapFocus.requestFocus(),
              focusNode: _fbFocus,
              onSaved: (txt) {
                tempUser.facebook = txt;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesome.facebook_square, color: Colors.black,),
              ),
            ),
            TextFormField(
              controller: _snapchatController,
              focusNode: _snapFocus,
              keyboardType: TextInputType.url,
              validator: (txt) {
                return (txt?.isEmpty??true) || GetUtils.isURL(txt??'') ? null : 'Please provide a valid url';
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _instagramFocus.requestFocus(),
              onSaved: (txt) {
                tempUser.snapchat = txt;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesome.snapchat_square, color: Colors.black,),
              ),
            ),
            TextFormField(
              controller: _instagramController,
              focusNode: _instagramFocus,
              keyboardType: TextInputType.url,
              validator: (txt) {
                return (txt?.isEmpty??true) || GetUtils.isURL(txt??'') ? null : 'Please provide a valid url';
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _tiktokFocus.requestFocus(),
              onSaved: (txt) {
                tempUser.instagram = txt;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesome.instagram, color: Colors.black,),
              ),
            ),
            TextFormField(
              controller: _tiktokController,
              validator: (txt) {
                return (txt?.isEmpty??true) || GetUtils.isURL(txt??'') ? null : 'Please provide a valid url';
              },
              keyboardType: TextInputType.url,
              focusNode: _tiktokFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
              onSaved: (txt) {
                tempUser.tiktok = txt;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.tiktok, color: Colors.black,),
              ),
            ),

            TextFormField(
              controller: _whatsappController,
              validator: (txt) {
                const error = 'Please provide a valid phone number';
                return (txt ?? '').isEmpty ? error : null;
                /*if (txt == null || txt.isEmpty) {
                  return null;
                }
                final phone = txt;
                phone.replaceAll('+', '00');
                if (phone.startsWith('00974')) {
                  phone.replaceFirst('00974', '');
                }
                if (txt.length != 8) return error;
                return GetUtils.hasMatch(txt, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$') ? null : error*/
              },
              focusNode: _phoneFocus,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _youtubeFocus.requestFocus(),
              keyboardType: TextInputType.phone,
              onSaved: (txt) {
                tempUser.phone = txt;
              },
              decoration:  const InputDecoration(
                prefixIcon: Icon(Icons.phone, color: Colors.black,),
              ),
            ),

            TextFormField(
              controller: _youtubeController,
              focusNode: _youtubeFocus,
              keyboardType: TextInputType.url,
              validator: (txt) {
                return (txt?.isEmpty??true) || GetUtils.isURL(txt??'') ? null : 'Please provide a valid url';
              },
              textInputAction: TextInputAction.done,
              onSaved: (txt) {
                tempUser.youtube = txt;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesome.youtube_play, color: Colors.black,),
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void didPopNext() {
    super.didPopNext();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.appBarActions.value = [
        _doneBtn(),
      ];
    });
  }

  Widget _doneBtn() {
    return TextButton(onPressed: updateProfile, child: const Text('Done'));
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

  Future<void> updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
      });
      _formKey.currentState?.save();
      try {
        await AuthWebService().updateProfile(tempUser);
        tempUser.name = '${tempUser.firstName} ${tempUser.lastName}';
        Get.find<UserController>().setUser(tempUser);
        Get.back();
      } on DioError catch(e) {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.response?.data.toString()??'Something went wrong.\nPlease try again later'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok')),
          ],
        ));
      } finally {
        setState(() {
        });
      }
    }
  }
}
