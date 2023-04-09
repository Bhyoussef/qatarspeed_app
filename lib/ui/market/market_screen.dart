import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/market_controller.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/market/add_product/create_product_details_screen.dart';
import 'package:qatar_speed/ui/market/market_item.dart';
import 'package:qatar_speed/ui/market/product/market_product_screen.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with RouteAware, RouteObserverMixin {
  final _scrollController = ScrollController();
  final _visibleFab = true.obs;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MarketController>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 50) {
        controller.loadMore();
      }
    });
  }

  @override
  void didPopNext() {
    _initAppBar();
    super.didPopNext();
  }

  @override
  void didPop() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.titleWidget.value = null;
      Res.showAppBar.value = true;
    });
    super.didPop();
  }

  @override
  void didPush() {
    _initAppBar();
    super.didPush();
  }

  _initAppBar() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.titleWidget.value = _addItemWidget();
      Res.showAppBar.value = true;
      Res.appBarActions.clear();
      Res.scrollController.value = _scrollController;
    });
  }

  @override
  void didPushNext() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Res.titleWidget.value = null;
      Res.showAppBar.value = true;
    });
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(() => AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _visibleFab.value ? 1.0 : .0,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                final controller = Get.find<MarketController>();
                if (controller.markets!.isNotEmpty) {
                  Get.to(() =>
                      CreateProductDetailsScreen(markets: controller.markets!));
                }
              },
              backgroundColor: Colors.black,
              child: Image.asset('assets/ios-add.png'),
            ),
          )),
      body: WillPopScope(
        onWillPop: () async {
          final controller = Get.find<MarketController>();
          if (controller.selectedMarket != null ||
              controller.keyword != null ||
              (controller.keyword?.isNotEmpty ?? false)) {
            controller.keyword = null;
            controller.page = 0;
            controller.selectMarket(null);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Res.titleWidget.value = _addItemWidget();
            });
            return false;
          }
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notif) {
              if (notif.direction == ScrollDirection.forward) {
                _visibleFab.value = true;
              } else if (notif.direction == ScrollDirection.reverse) {
                _visibleFab.value = false;
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [_marketsList(), _itemsGrid()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addItemWidget() {
    final controller = Get.find<MarketController>();
    return Row(
      children: [
        if (controller.selectedMarket != null)
          InkWell(
            onTap: () {
              controller.page = 0;
              controller.selectMarket(null);
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Res.titleWidget.value = _addItemWidget();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        SizedBox(
          width: controller.selectedMarket != null ? .0 : 15.0,
        ),
      ],
    );
  }

  Widget _itemsGrid() {
    return GetBuilder<MarketController>(
        id: 'items',
        builder: (controller) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: controller.showSearch
                        ? _searchWidget(controller)
                        : Text(
                            'Latest from ${controller.selectedMarket == null ? 'market' : controller.selectedMarket!.name ?? ''}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 9,
                            style: const TextStyle(
                              fontFamily: 'arial',
                              fontSize: 17.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  InkWell(
                    onTap: controller.toggleSearch,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.search,
                        size: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
              controller.isLoading
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: Get.height * .25),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ))
                  : controller.products.isEmpty
                      ? Center(
                          child: Padding(
                          padding: EdgeInsets.only(top: Get.height * .2),
                          child: const Text(
                            'No posts yet,\nbe the first seller',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black54, fontSize: 20.0),
                          ),
                        ))
                      : Column(
                          children: [
                            GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8.0,
                                        mainAxisSpacing: 8.0),
                                itemCount: controller.products.length,
                                itemBuilder: (context, index) {
                                  return MarketItem(
                                    product: controller.products[index],
                                    index: index,
                                    onTap: (product) {
                                      Get.to(() => MarketProductScreen(
                                            product: product,
                                          ));
                                    },
                                  );
                                }),
                            if (controller.canLoadMore)
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(),
                              )
                          ],
                        ),
            ],
          );
        });
  }

  Widget _marketsList() {
    return GetBuilder<MarketController>(
        id: 'markets',
        builder: (controller) {
          if (controller.selectedMarket != null) {
            return Container();
          }
          return SizedBox(
            height: 160.0,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount:
                  controller.markets == null ? 4 : controller.markets!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: controller.markets == null
                        ? null
                        : () {
                      controller.page = 0;
                            controller.selectMarket(controller.markets?[index]);
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              Res.titleWidget.value = _addItemWidget();
                            });
                          },
                    child: SizedBox(
                      width: 103.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                width: 1.0,
                                color: const Color(0xFF707070),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: controller.markets == null
                                  ? const ShimmerBox(
                                      height: 120.0,
                                      width: 145.0,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          controller.markets![index].photo ??
                                              '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, _) =>
                                          const ShimmerBox(
                                        height: 120.0,
                                        width: 145.0,
                                      ),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                      height: 120.0,
                                      width: 145.0,
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          if (controller.markets != null)
                            Text(
                              controller.markets?[index].name ?? 'Market',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'arial',
                                fontSize: 12.0,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _searchWidget(MarketController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffB1B1B1).withOpacity(.05),
        borderRadius: BorderRadius.circular(900),
        border: Border.all(color: const Color(0xff2D3F7B).withOpacity(.1)),
      ),
      child: TextField(
        onChanged: (txt) {
          controller.page = 0;
          controller.search(txt);
        },
        decoration: const InputDecoration(
          hintText: 'search market',
          //isDense: true,
          hintStyle: TextStyle(fontWeight: FontWeight.bold),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black26,
          ),
          border: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
