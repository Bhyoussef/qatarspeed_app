import 'package:qatar_speed/tools/extensions.dart';

class PollModel {
  int id;
  String text;
  List<dynamic>? votes;
  double? rate;
  bool? votedPoll;

  PollModel({int? id, String? text, this.votes, this.votedPoll})
  : text = text ?? '',
  id = id ?? -1;

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: int.parse(json["id"].toString()),
      text: json["text"],
      votes: List.of(json["pollvotes"]),
      votedPoll: json.get('user_voted_poll').toString() == '1'
    );
  }
//

}