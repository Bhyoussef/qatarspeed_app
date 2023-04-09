// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/tools/services/base.dart';
import 'package:qatar_speed/tools/services/misc.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with RouteAware, RouteObserverMixin {
  @override
  void didPush() {
    super.didPush();
    _initAppbar();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = ScrollController();
      Res.appBarActions.clear();
      Res.titleWidget.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Image.asset(
              'assets/newlogo.png',
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .4,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Material(
              textStyle: const TextStyle(
                  fontFamily: 'arial',
                  color: Color(0xff2D3F7B),
                  fontWeight: FontWeight.bold,
                  fontSize: 19.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: () => Get.to(() => _HtmlViewerScreen(
                            pageToShow: 'About Us',
                          )),
                      child: const Text('About us...')),
                  InkWell(
                      onTap: () => Get.to(() => _ContactPage()),
                      child: const Text('Contact us...')),

                ],
              ),
            ),
            const SizedBox(height: 80,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/newlogo.png',
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * .4,
                  fit: BoxFit.cover,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _HtmlViewerScreen extends StatelessWidget {
  _HtmlViewerScreen({required this.pageToShow});

  final String pageToShow;
  final html = ''.obs;

  @override
  Widget build(BuildContext context) {
    MiscWsebService().getPages().then((value) {
      html.value = value.firstWhere((element) =>
          element['title'].toString() == pageToShow)['description'];
    });
    return Scaffold(
      body: Obx(() {
        if (html.isEmpty) {
          return SizedBox.expand(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: const [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Html(
            data: html.value,
          ),
        );
      }),
    );
  }
}

class _ContactPage extends StatelessWidget {
  Map<String, dynamic> data = {};
  final _isLoading = true.obs;

  @override
  Widget build(BuildContext context) {
    BaseWebService().dio.get('settings').then((value) {
      final response = value.data['settings'];
      for (Map<String, dynamic> item in response) {
        switch (item['name']){
          case 'phone': data['phone'] = item['value'];
          break;
          case 'contact_us_email': data['contact_us_email'] = item['value'];
          break;
          case 'address': data['address'] = item['value'];
          break;
          case 'latitude': data['latitude'] = item['value'];
          break;
          case 'longitude': data['longitude'] = item['value'];
          break;
        }
      }
      _isLoading.value = false;
    });
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/newlogo.png',
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * .4,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(
                  child: Obx(() {
                    return _isLoading.value
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(data['phone']),
                                iconColor: Colors.black,
                                textColor: Colors.black,
                                onTap: () {
                                  launchUrl(Uri.parse('tel:${data['phone']}'));
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: ListTile(
                                  leading: const Icon(Icons.mail),
                                  title: Text(data['contact_us_email']),
                                  iconColor: Colors.black,
                                  textColor: Colors.black,
                                  onTap: () {
                                    launchUrl(Uri.parse('mailto:${data['contact_us_email']}'));
                                  },
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.location_on_rounded),
                                title: Text(data['address']),
                                iconColor: Colors.black,
                                textColor: Colors.black,
                                onTap: () {
                                  launchUrl(Uri.parse('geo:${data['latitude']},${data['longitude']}'));
                                },
                              ),
                            ],
                          );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
