import 'package:get/get.dart';
import 'package:qatar_speed/models/search.dart';
import 'package:qatar_speed/tools/services/misc.dart';

class SearchController extends GetxController {
  SearchModel? result;

  search(String keyword) async {
    result = await MiscWsebService().search(keyword);
    update();
  }

  removeSearch() {
    result = null;
  }
}