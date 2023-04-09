class MessageStoriesSettingsModel {
  String messages;
  String stories;

  MessageStoriesSettingsModel({this.messages = 'Everyone', this.stories = 'Everyone'});

  factory MessageStoriesSettingsModel.fromJson(Map<String, dynamic> json) {
    return MessageStoriesSettingsModel(
      messages: json["message_privacy"],
      stories: json["story_privacy"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_privacy": messages,
      "story_privacy": stories,
    };
  }

}