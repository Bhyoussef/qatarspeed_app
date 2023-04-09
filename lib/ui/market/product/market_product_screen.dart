import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/market_controller.dart';
import 'package:qatar_speed/models/product.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/comment_box.dart';
import 'package:qatar_speed/ui/common/comment_widget.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/profile/profile_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../chat/chat_list_screen.dart';

class MarketProductScreen extends StatefulWidget {
  const MarketProductScreen({Key? key, required this.product})
      : super(key: key);
  final ProductModel product;

  @override
  createState() => _MarketProductScreenState();
}

class _MarketProductScreenState extends State<MarketProductScreen>
    with RouteAware, RouteObserverMixin {
  final _carouselController = CarouselController();
  final _scrollController = ScrollController();
  final _bottomCommentKey = GlobalKey();
  final _marginBottom = .0.obs;
  bool err = false;
  String msgErr = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _marginBottom.value = (_bottomCommentKey.currentContext
                  ?.findRenderObject()
                  ?.paintBounds
                  .height ??
              .0) +
          1.0;
    });
  }

  @override
  void didPush() {
    _initAppbar();
    super.didPush();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _initAppbar();
  }

  _initAppbar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.scrollController.value = _scrollController;
      Res.titleWidget.value = null;
      Res.appBarActions.clear();
      Res.showAppBar.value = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SizedBox(
        height: Get.height,
        child: Stack(
          children: [
            Obx(() {
              return Padding(
                padding: EdgeInsets.only(bottom: _marginBottom.value),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: GetBuilder<MarketController>(
                    id: 'product',
                    builder: (controller) => _MarketProductContent(
                        controller: controller,
                        product: widget.product,
                        carouselController: _carouselController),
                  ),
                ),
              );
            }),
            // Positioned(
            //   bottom: .0,
            //   left: .0,
            //   right: .0,
            //   child: _commentWidget(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _commentWidget() {
    return Container(
      key: _bottomCommentKey,
      child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CommentBox(
              suffixWidget: const Icon(Icons.send),
              onSend: (txt) => Get.find<MarketController>()
                  .commentProduct(widget.product, txt),
              hint: 'add comment',
            ),
          )),
    );
  }
}

class _MarketProductContent extends StatelessWidget {
  final MarketController controller;
  final ProductModel product;
  final CarouselController carouselController;

  const _MarketProductContent(
      {required this.controller,
      required this.product,
      required this.carouselController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _carousel(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              _underCarouselWidget(),
              _infoWidget(),
              _adActions(),
              _comments(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _carousel() {
    final current = 0.obs;
    return Stack(
      children: [
        CarouselSlider.builder(
            itemCount: product.photos.length,
            carouselController: carouselController,
            itemBuilder: (context, index, _) {
              return Hero(
                tag: 'ad_img',
                child: CachedNetworkImage(
                  imageUrl: product.photos[index],
                  fit: BoxFit.cover,
                  placeholder: (context, _) => const ShimmerBox(
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                  height: double.infinity,
                  width: double.infinity,
                ),
              );
            },
            options: CarouselOptions(
                aspectRatio: 1.0,
                viewportFraction: 1.0,
                height: 250.0,
                autoPlay: true,
                onPageChanged: (index, _) {
                  current.value = index;
                })),
        Positioned(
          bottom: .0,
          left: .0,
          right: .0,
          child: Container(
            color: Colors.black38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: product.photos.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => carouselController.animateToPage(entry.key),
                  child: Obx(() {
                    return Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                              current.value == entry.key ? 0.9 : 0.4)),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget _underCarouselWidget() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            /*const Icon(
              Icons.more_horiz,
              color: Colors.black,
              size: 30.0,
            ),*/
            // TextButton(
            //     onPressed: () {},
            //     style: TextButton.styleFrom(
            //       primary: Colors.black,
            //     ),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: const [
            //         Icon(Icons.outgoing_mail),
            //         Text('Message'),
            //       ],
            //     ))
            InkWell(
              onTap: () => Get.to(() => ProfileScreen(user: product.user,)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.user?.name ?? "User",
                          style: TextStyle(
                              fontFamily: 'arial',
                              height: .9,
                              fontWeight: FontWeight.w900,
                              fontSize: Res.isPhone ? 17 : 19.0),
                        ),
                        Text(
                          (formatDate(product.createdAt ?? DateTime.now(),
                              [dd, '/', m, '/', yyyy])).toString().split('.').last,
                          style: TextStyle(
                              fontFamily: 'arial',
                              color: Colors.grey,
                              fontSize: Res.isPhone ? 14.0 : 17.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      foregroundDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.transparent, width: 1.0)),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: product.user?.photo ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, _) => ShimmerBox(
                            height: Res.isPhone ? 70.0 : 70.0,
                            width: Res.isPhone ? 70.0 : 70.0,
                          ),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                          height: Res.isPhone ? 70.0 : 70.0,
                          width: Res.isPhone ? 70.0 : 70.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _infoWidget() {
    return SizedBox(
      width: Get.mediaQuery.size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title ?? "",
            style: TextStyle(
                fontFamily: 'arial',
                fontWeight: FontWeight.w900,
                fontSize: Res.isPhone ? 17.0 : 21.0),
          ),
          const Divider(
            thickness: 1.5,
            color: Color(0xff404040),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR ${product.price?.toStringAsFixed(3)}',
                    style: TextStyle(
                        fontFamily: 'arial',
                        color: const Color(0xffB90000),
                        fontWeight: FontWeight.w900,
                        fontSize: Res.isPhone ? 17.0 : 21.0),
                  ),
                  Text(
                    product.location ?? 'Unknown location',
                    style: TextStyle(
                        fontFamily: 'arabic',
                        color: product.location == null
                            ? Colors.grey
                            : Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: Res.isPhone ? 16.0 : 19.0),
                  ),
                  InkWell(
                    onTap: () {
                      launchUrl(Uri.parse(
                          'tel:${product.phone ?? product.user?.phone ?? ''}'));
                    },
                    child: Text(
                      product.phone ?? product.user?.phone ?? '',
                      style: TextStyle(
                          fontFamily: 'arial',
                          fontWeight: FontWeight.w900,
                          fontSize: Res.isPhone ? 16.0 : 19.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            product.description ?? '',
            style: TextStyle(
                fontFamily: 'arial',
                fontWeight: FontWeight.w900,
                fontSize: Res.isPhone ? 16.0 : 19.0),
          ),
          const Divider(
            thickness: 1.5,
            color: Color(0xff404040),
          ),
        ],
      ),
    );
  }

  Widget _adActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              MaterialButton(
                height: 50,
                minWidth: 20,
                color: Colors.grey.shade100,
                shape:  const CircleBorder(),
                  onPressed: () => Get.to(() => ChatListScreen(
                    user: product.user,
                  )
                  ),
                child:  SvgPicture.asset('assets/email.svg',height: 20,)
                ),


              const SizedBox(
                width: 2.0,
              ),
              const Text('Message',style: TextStyle(fontSize: 15),),
            ],
          ),

          InkWell(
            onTap: () {
              launchUrl(Uri.parse(
                  'tel:${product.phone ?? product.user?.phone ?? ''}'));
            },
            child: Column(
              children: [
                MaterialButton(
                    height: 50,
                    minWidth: 20,
                    color: Colors.grey.shade100,
                    shape:  const CircleBorder(),
                    onPressed: () {
                      launchUrl(Uri.parse(
                          'tel:${product.phone ?? product.user?.phone ?? ''}'));
                    },
                    child:  SvgPicture.asset('assets/Icon awesome-phone-alt.svg',height: 20)
                ),

                const SizedBox(
                  width: 2.0,
                ),
                const Text('Call',style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
         /* const SizedBox(
            width: 5.0,
          ),
          Column(
            children: [
              MaterialButton(
                  height: 50,
                  minWidth: 20,
                  color: Colors.grey.shade100,
                  shape:  const CircleBorder(),
                  onPressed: () {

                  },
                  child:  SvgPicture.asset('assets/share-outline.svg',height: 20,color: Colors.black,)
              ),

              const SizedBox(
                width: 2.0,
              ),
              const Text('Share',style: TextStyle(fontSize: 15)),
            ],
          ),
          const SizedBox(
            width: 5.0,
          ),
          Column(
            children: [
              MaterialButton(
                  height: 50,
                minWidth: 20,
                  color: Colors.grey.shade100,
                  shape:  const CircleBorder(),
                  onPressed: () {
                    whatsAppOpen(product.phone ?? product.user?.phone ?? '');
                  },
                  child:  SvgPicture.asset('assets/whatsapp.svg',height: 20),
              ),

              const SizedBox(
                width: 5.0,
              ),
              const Text('Whatsapp',style: TextStyle(fontSize: 15),),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _comments() {
    return ListView.builder(
      itemCount: product.comments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Column(
          children: [
            const Divider(
              thickness: .5,
              color: Color(0xff404040),
            ),
            CommentWidget(comment: product.comments[index]),
          ],
        );
      },
    );
  }

  void whatsAppOpen(String phone) async {
    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
    if (whatsapp) {
      await FlutterLaunch.launchWhatsapp(
          phone: phone,
          message:
          "Hello");
    }
  }

}
