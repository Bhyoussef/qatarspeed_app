import 'package:qatar_speed/models/friends.dart';
import 'package:qatar_speed/tools/services/base.dart';

class FriendsWebService extends BaseWebService {

  Future<FriendsModel> getFriends({String? keyword = '', int page = 0}) async {
    final response = (await dio.post('friends', data: {'search': keyword, 'page': page})).data;
    return FriendsModel.fromJson(response);
  }
  
  Future<bool> toggleFollow(int id) async {
    final response = (await dio.post('follow-user/$id')).data;
    return !response['message'].toString().toLowerCase().contains('unfollow');
  }
}