class NotificationSettingsModel {
  late bool groupPost;
  late bool commentPost;
  late bool likePost;
  late bool replyComment;
  late bool likeComment;

  NotificationSettingsModel(
      {this.groupPost = false,
        this.commentPost = false,
        this.likePost = false,
        this.replyComment = false,
        this.likeComment = false});

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      groupPost: json["post_joinedgroup_notification"].toLowerCase() == 'on',
      commentPost: json["post_comment_notification"].toLowerCase() == 'on',
      likePost: json["post_like_notification"].toLowerCase() == 'on',
      replyComment: json["reply_comment_notification"].toLowerCase() == 'on',
      likeComment: json["like_comment_notification"].toLowerCase() == 'on',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "post_joinedgroup_notification": groupPost ? 'On' : 'Off',
      "post_comment_notification": commentPost ? 'On' : 'Off',
      "post_like_notification": likePost ? 'On' : 'Off',
      "reply_comment_notification": replyComment ? 'On' : 'Off',
      "like_comment_notification": likeComment ? 'On' : 'Off',
    };
  }
}