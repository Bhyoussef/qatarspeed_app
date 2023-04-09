import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/models/market.dart';
import 'package:qatar_speed/models/product.dart';
import 'package:qatar_speed/tools/services/market.dart';

class MarketController extends GetxController {
  RxList<ProductModel> products = RxList();
  RxList<MarketModel>? markets = RxList();
  MarketModel? selectedMarket;
  Timer? _debounce;
  String? keyword;
  bool showSearch = false;
  int page = 0;
  bool canLoadMore = true;
  bool isLoading = true;
  bool isLoadingMore = false;

  ProductModel? product;

  Future<void> getProducts() async {
    if (!isLoadingMore) {
      isLoadingMore = true;
      final list = await MarketWsebService().getProducts(page: page);
      products.addAll(list);
      isLoading = false;
      canLoadMore = list.length == 10;
      isLoadingMore = false;
      update(['items']);
    }
  }

  void toggleSearch() {
    showSearch = !showSearch;
    update(['items']);
  }

  Future<void> getMarkets() async {
    markets!.value = await MarketWsebService().getMarkets();
    update(['markets']);
  }

  selectMarket(MarketModel? market) async {
    if (!isLoadingMore) {
      isLoadingMore = true;
      selectedMarket = market;
      update(['markets']);
      products.clear();
      isLoading = true;
      canLoadMore = true;
      update(['items']);
      final list =
      await MarketWsebService().getProducts(market: market, keyword: keyword);
      products.addAll(list);
      isLoading = false;
      canLoadMore = list.length == 10;
      update(['items']);
      isLoadingMore = false;
    }
  }

  void search(String? keyword) async {
    this.keyword = keyword;
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 600), () => _search());
  }

  Future<void> _search() async {
    products.clear();
    isLoading = true;
    canLoadMore = true;
    update(['items']);
    final list = await MarketWsebService()
        .getProducts(keyword: keyword, market: selectedMarket, page: page);
    products.addAll(list);
    isLoading = false;
    canLoadMore = list.length == 10;
    update(['items']);
  }

  void loadMore() {
    page++;
    if (keyword != null) {
      search(keyword);
    } else if (selectedMarket != null) {
      selectMarket(selectedMarket);
    } else {
      getProducts();
    }
  }

  void addProductPhoto(List<Media> paths) {
    product!.photos.addAll(paths.map((e) => e.path!));
    update(['photos']);
  }

  void removeProductPhoto(String path) {
    product!.photos.remove(path);
    update(['photos']);
  }

  Future<void> commentProduct(ProductModel product, String cmt) async {
    final comment = CommentModel(
      user: Get.find<UserController>().user,
      comment: cmt,
      createdAt: DateTime.now(),
    );

    product.comments.add(comment);
    update(['product']);

    final response =
        await MarketWsebService().commentProduct(productId: product.id, comment: cmt);

    comment.id = response.id;
    comment.media = response.media;
    update(['product']);
  }

  @override
  void onInit() {
    super.onInit();
    page = 0;
    getProducts();
    getMarkets();
  }

  Future<void> saveProduct() async {
    try {
      await MarketWsebService().addProduct(product!);
    } on DioError catch (e) {
      debugPrint(e.response?.data);
    }
    Get.back();
    Get.back();
    Get.back();
  }
}
