import 'package:qatar_speed/models/comment.dart';
import 'package:qatar_speed/models/market.dart';
import 'package:qatar_speed/models/product.dart';
import 'package:qatar_speed/tools/services/base.dart';

class MarketWsebService extends BaseWebService {
  Future<List<ProductModel>> getProducts(
      {int page = 0, MarketModel? market, String? keyword}) async {
    Map<String, dynamic> data = {'page': page, 'search': keyword ?? ''};
    if (market != null) {
      data['category_id'] = market.id;
    }
    final response = (await dio.post('ads-list', queryParameters: data)).data;
    return List.of(response['ads'])
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  Future<List<MarketModel>> getMarkets() async {
    final response = (await dio.get('categories')).data;
    return List.of(response['categories'])
        .map((e) => MarketModel.fromJson(e))
        .toList();
  }

  Future<void> addProduct(ProductModel product) async {
    (await dio.post('ads', data: await product.toRequest()));
  }

  Future<CommentModel> commentProduct(
      {required int productId, required String comment}) async {
    final response = (await dio
            .post('ad-comment', data: {'ad_id': productId, 'text': comment}))
        .data;
    return CommentModel.fromJson(response['comment']);
  }
}
