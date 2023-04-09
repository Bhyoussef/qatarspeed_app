import 'dart:ui';

import 'package:qatar_speed/models/story.dart';
import 'package:qatar_speed/tools/res.dart';

// ignore: constant_identifier_names
enum UserType { Moderator, VIP, User }

class UserModel {
  late int id;
  String? username;
  String? name;

  String? firstName;
  String? lastName;
  UserType? type;
  String? email;
  String? phone;
  String? emailVerifiedAt;
  String? photo;
  String? cover;
  String? address;
  String? about;
  String? gender;
  String? birthday;
  String? country;
  String? facebook;
  String? snapchat;
  String? twitter;
  String? linkedin;
  String? youtube;
  String? instagram;
  String? tiktok;
  String? language;
  String? ip;
  String? followPrivacy;
  String? postPrivacy;
  String? messagePrivacy;
  String? confirmFollowers;
  String? showActivitiesPrivacy;
  String? birthPrivacy;
  String? lastseen;
  String? showlastseen;
  String? eLiked;
  String? eWondered;
  String? eShared;
  String? eFollowed;
  String? eCommented;
  String? eVisited;
  String? eLikedPage;
  String? eMentioned;
  String? eJoinedGroup;
  String? eAccepted;
  String? eProfileWallPost;
  String? eSentmeMsg;
  String? eLastNotif;
  String? notificationSettings;
  String? status;
  String? active;
  String? startUp;
  String? startUpInfo;
  String? startupFollow;
  String? startupImage;
  String? lastEmailSent;
  String? phoneNumber;
  String? smsCode;
  String? isPro;
  String? proTime;
  String? proType;
  String? timezone;
  String? referrer;
  String? refUserId;
  String? balance;
  String? socialLogin;
  String? androidMDeviceId;
  String? iosMDeviceId;
  String? androidNDeviceId;
  String? iosNDeviceId;
  String? webDeviceId;
  double? wallet;
  String? lat;
  String? lng;
  String? lastLocationUpdate;
  String? shareMyLocation;
  String? lastDataUpdate;
  String? city;
  String? state;
  String? zip;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? postsCount;
  int? followingCount;
  int? followersCount;
  List<StoryModel>? stories;
  String? storyThumb;
  String? passwd;
  Color? color;
  late bool following;

  UserModel(
      {required this.id,
      this.username,
      this.firstName,
      this.lastName,
      this.type,
      this.email,
      this.phone,
      this.emailVerifiedAt,
      this.photo,
      this.cover,
      this.address,
      this.about,
      this.gender,
      this.birthday,
      this.country,
      this.facebook,
      this.snapchat,
      this.twitter,
      this.linkedin,
      this.youtube,
      this.instagram,
      this.tiktok,
      this.language,
      this.ip,
      this.followPrivacy,
      this.postPrivacy,
      this.messagePrivacy,
      this.confirmFollowers,
      this.showActivitiesPrivacy,
      this.birthPrivacy,
      this.lastseen,
      this.showlastseen,
      this.eLiked,
      this.eWondered,
      this.eShared,
      this.eFollowed,
      this.eCommented,
      this.eVisited,
      this.eLikedPage,
      this.eMentioned,
      this.eJoinedGroup,
      this.eAccepted,
      this.eProfileWallPost,
      this.eSentmeMsg,
      this.eLastNotif,
      this.notificationSettings,
      this.status,
      this.active,
      this.startUp,
      this.startUpInfo,
      this.startupFollow,
      this.startupImage,
      this.lastEmailSent,
      this.phoneNumber,
      this.smsCode,
      this.isPro,
      this.proTime,
      this.proType,
      this.timezone,
      this.referrer,
      this.refUserId,
      this.balance,
      this.socialLogin,
      this.androidMDeviceId,
      this.iosMDeviceId,
      this.androidNDeviceId,
      this.iosNDeviceId,
      this.webDeviceId,
      this.wallet,
      this.lat,
      this.lng,
      this.lastLocationUpdate,
      this.shareMyLocation,
      this.lastDataUpdate,
      this.city,
      this.state,
      this.zip,
      this.createdAt,
      this.updatedAt,
      this.name,
      this.followersCount,
      this.followingCount,
      this.postsCount,
      this.stories,
      this.storyThumb,
      this.color,
      this.following = false,
      this.passwd});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('token')) {
      Res.token = json['token'];
    }
    return UserModel(
      id: int.parse(json['id'].toString()),
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json.containsKey('name') ? json['name'] : '${json['first_name'] ?? 'User'} ${json['last_name'] ?? ''}',
      type: json['type'].toString().toLowerCase() == "moderator"
          ? UserType.Moderator
          : json['type'].toString().toLowerCase() == 'vip'
              ? UserType.VIP
              : UserType.User,
      email: json['email'],
      phone: json['phone'],
      emailVerifiedAt: json['email_verified_at'],
      photo: json['image'].toString().startsWith('http')
          ? json['image']
          : '${Res.baseUrl}${json['image']}',
      cover: json['cover'].toString().startsWith('http')
          ? json['cover']
          : '${Res.baseUrl}${json['cover']}',
      address: json['address'],
      about: json['about'],
      gender: json['gender'],
      birthday: json['birthday'],
      country: json['country'],
      facebook: json['facebook'],
      snapchat: json['snapchat'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],
      youtube: json['youtube'],
      instagram: json['instagram'],
      tiktok: json['tiktok'],
      language: json['language'],
      ip: json['ip'],
      followPrivacy: json['follow_privacy'],
      postPrivacy: json['post_privacy'],
      messagePrivacy: json['message_privacy'],
      confirmFollowers: json['confirm_followers'],
      showActivitiesPrivacy: json['show_activities_privacy'],
      birthPrivacy: json['birth_privacy'],
      lastseen: json['lastseen'],
      showlastseen: json['showlastseen'],
      eLiked: json['e_liked'],
      eWondered: json['e_wondered'],
      eShared: json['e_shared'],
      eFollowed: json['e_followed'],
      eCommented: json['e_commented'],
      eVisited: json['e_visited'],
      eLikedPage: json['e_liked_page'],
      eMentioned: json['e_mentioned'],
      eJoinedGroup: json['e_joined_group'],
      eAccepted: json['e_accepted'],
      eProfileWallPost: json['e_profile_wall_post'],
      eSentmeMsg: json['e_sentme_msg'],
      eLastNotif: json['e_last_notif'],
      notificationSettings: json['notification_settings'],
      status: json['status'],
      active: json['active'],
      startUp: json['start_up'],
      startUpInfo: json['start_up_info'],
      startupFollow: json['startup_follow'],
      startupImage: json['startup_image'],
      lastEmailSent: json['last_email_sent'],
      phoneNumber: json['phone_number'],
      smsCode: json['sms_code'],
      isPro: json['is_pro'],
      proTime: json['pro_time'],
      proType: json['pro_type'],
      timezone: json['timezone'],
      referrer: json['referrer'],
      refUserId: json['ref_user_id'],
      balance: json['balance'],
      socialLogin: json['social_login'],
      androidMDeviceId: json['android_m_device_id'],
      iosMDeviceId: json['ios_m_device_id'],
      androidNDeviceId: json['android_n_device_id'],
      iosNDeviceId: json['ios_n_device_id'],
      webDeviceId: json['web_device_id'],
      wallet: double.tryParse(json['wallet']?.toString() ?? '0'),
      lat: json['lat'],
      lng: json['lng'],
      lastLocationUpdate: json['last_location_update'],
      shareMyLocation: json['share_my_location'],
      lastDataUpdate: json['last_data_update'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      followersCount: int.tryParse(json['followers_count']?.toString() ?? '0'),
      followingCount: int.tryParse(json['following_count']?.toString() ?? '0'),
      following: json.containsKey('is_following') ? int.parse(json['is_following'].toString()) == 1 : false,
      postsCount: int.tryParse(json['posts_count']?.toString() ?? '0'),
      stories: json.containsKey('stories')
          ? List.of(json['stories']).map((e) => StoryModel.fromJson(e)).toList()
          : null,
      storyThumb: json.containsKey('thumbnail') && json['thumbnail'] != null
          ? (json['thumbnail'].toString().startsWith('http')
              ? json['thumbnail']
              : Res.baseUrl + json['thumbnail'])
          : null,
      color: json.containsKey('color') && json['color'] != null
          ? Color(int.tryParse(json['color'].toString()) ?? 0xFF000000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "type": type.toString().split('.').last,
      "email": email,
      "phone": phone,
      "email_verified_at": emailVerifiedAt,
      "image": photo,
      "cover": cover,
      "address": address,
      "about": about,
      "gender": gender,
      "birthday": birthday,
      "country": country,
      "facebook": facebook,
      "snapchat": snapchat,
      "twitter": twitter,
      "linkedin": linkedin,
      "youtube": youtube,
      "instagram": instagram,
      "tiktok": tiktok,
      "language": language,
      "ip": ip,
      "follow_privacy": followPrivacy,
      "post_privacy": postPrivacy,
      "message_privacy": messagePrivacy,
      "confirm_followers": confirmFollowers,
      "show_activities_privacy": showActivitiesPrivacy,
      "birth_privacy": birthPrivacy,
      "lastseen": lastseen,
      "showlastseen": showlastseen,
      "e_liked": eLiked,
      "e_wondered": eWondered,
      "e_shared": eShared,
      "e_followed": eFollowed,
      "e_commented": eCommented,
      "e_visited": eVisited,
      "e_liked_page": eLikedPage,
      "e_mentioned": eMentioned,
      "e_joined_group": eJoinedGroup,
      "e_accepted": eAccepted,
      "e_profile_wall_post": eProfileWallPost,
      "e_sentme_msg": eSentmeMsg,
      "e_last_notif": eLastNotif,
      "notification_settings": notificationSettings,
      "status": status,
      "active": active,
      "start_up": startUp,
      "start_up_info": startUpInfo,
      "startup_follow": startupFollow,
      "startup_image": startupImage,
      "last_email_sent": lastEmailSent,
      "phone_number": phoneNumber,
      "sms_code": smsCode,
      "is_pro": isPro,
      "pro_time": proTime,
      "pro_type": proType,
      "timezone": timezone,
      "referrer": referrer,
      "ref_user_id": refUserId,
      "balance": balance,
      "social_login": socialLogin,
      "android_m_device_id": androidMDeviceId,
      "ios_m_device_id": iosMDeviceId,
      "android_n_device_id": androidNDeviceId,
      "ios_n_device_id": iosNDeviceId,
      "web_device_id": webDeviceId,
      "wallet": wallet,
      "lat": lat,
      "lng": lng,
      "last_location_update": lastLocationUpdate,
      "share_my_location": shareMyLocation,
      "last_data_update": lastDataUpdate,
      "city": city,
      "state": state,
      "zip": zip,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      'stories': stories?.map((e) => e.toJson()).toList() ?? [],
      'posts_count': postsCount,
      'followers_count': followersCount,
      'following_count': followingCount,
      'token': Res.token,
      'color': color?.value,
    };
  }

  Map<String, dynamic> toRequest() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "type": type.toString().split('.').last,
      "city": city,
      "facebook": facebook,
      "snapchat": snapchat,
      "twitter": twitter,
      "linkedin": linkedin,
      "youtube": youtube,
      'phone': phone,
      "instagram": instagram,
      "tiktok": tiktok,
    };
  }

  Map<String, dynamic> toSignup() {
    return {
      'username': username,
      'email': email,
      'password': passwd,
      'password_confirmation': passwd,
      'gender': gender,
      'firebase_token': Res.firebaseToken,
    };
  }

  UserModel clone() {
    return UserModel.fromJson(toJson());
  }

}
