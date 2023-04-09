import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/profile_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/group.dart';
import 'package:qatar_speed/models/post.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/common/shimmer_bocx.dart';
import 'package:qatar_speed/ui/edit_post/edit_post.dart';

showPostBottomSheet(PostModel post,
    {required VoidCallback onDeletePost,
    required VoidCallback onBlockUser,
    Function(PostModel)? onPostEdited,
    required Function(GroupModel) onMovePost}) {
  final isMine = post.user?.id == Get.find<UserController>().user.id;
  final isModerator =
      Get.find<UserController>().user.type == UserType.Moderator;
  int? nextStep;
  showModalBottomSheet(
      isScrollControlled: true,
      context: Res.baseContext,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      )),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine) ...[
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Save this post'),
                  onTap: () {
                    nextStep = 2;
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  leading: const Icon(Icons.report),
                  onTap: () {
                    nextStep = 0;
                    Navigator.pop(Res.baseContext);
                  },
                  title: const Text('Report this post'),
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
              ],
              if (isMine || isModerator) ...[
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete this post'),
                  onTap: () {
                    nextStep = 5;
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit this post'),
                  onTap: () {
                    nextStep = 3;
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  leading: const Icon(Icons.compare_arrows),
                  title: const Text('Move this post'),
                  onTap: () {
                    nextStep = 4;
                    Navigator.pop(Res.baseContext);
                  },
                ),
              ],
              if (!isMine) ...[
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  leading: const Icon(Icons.person_off),
                  title: const Text('Block this user'),
                  onTap: () {
                    nextStep = 1;
                    Navigator.pop(Res.baseContext);
                  },
                ),
              ],
              const SizedBox(
                height: 13.0,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(Res.baseContext);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 17.0,
                        fontFamily: 'arial',
                        fontWeight: FontWeight.w900),
                  )),
            ],
          ),
        );
      }).whenComplete(() {
    switch (nextStep) {
      case 0:
        _showReportBottomSheet(post);
        break;
      case 1:
        _showBlockUserDialog(post, onBlockUser);
        break;
      case 2:
        Get.find<ProfileController>().togglePostSave(post);
        Get.snackbar('Success', 'Post saved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black,
            colorText: Colors.white);
        break;
      case 3:
        Get.to(() => EditPostScreen(
              post: post,
          onPost: (post) {
            if (onPostEdited != null) {
              onPostEdited(post);
            }
          },
            ));
        break;
      case 4:
        _movePost(post, onMovePost);
        break;
      case 5:
        _delete(post, onDeletePost);
    }
  });
}

_showReportBottomSheet(PostModel post) {
  String? raison;
  showModalBottomSheet(
      isScrollControlled: true,
      context: Res.baseContext,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      )),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 15.0,
                ),
                const Center(
                  child: Text(
                    'Report',
                    style: TextStyle(
                      fontFamily: 'arial',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1.0,
                  height: 15.0,
                ),
                SizedBox(
                  width: Get.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Please select a problem',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontFamily: 'arial',
                              fontWeight: FontWeight.w900,
                              fontSize: 16.0),
                        ),
                        Text(
                          'If someone is immediate danger, get help before reporting to Speedoo. Don\'t wait.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontFamily: 'arial',
                              color: Colors.grey,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Nudity'),
                  onTap: () {
                    raison = 'Nudity';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Violence'),
                  onTap: () {
                    raison = 'Violence';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Harassment'),
                  onTap: () {
                    raison = 'Harassment';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Suicide or self-injury'),
                  onTap: () {
                    raison = 'Suicide or self-injury';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('False information'),
                  onTap: () {
                    raison = 'False information';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Spam'),
                  onTap: () {
                    raison = 'Spam';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Unauthorized sales'),
                  onTap: () {
                    raison = 'Unauthorized sales';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Hate speech'),
                  onTap: () {
                    raison = 'Hate speech';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Terrorism'),
                  onTap: () {
                    raison = 'Terrorism';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: const Text('Something else'),
                  onTap: () {
                    raison = 'Something else';
                    Navigator.pop(Res.baseContext);
                  },
                ),
                const SizedBox(
                  height: 13.0,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(Res.baseContext);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontFamily: 'arial',
                          fontWeight: FontWeight.w900),
                    )),
              ],
            ),
          ),
        );
      }).whenComplete(() async {
    if (raison != null) {
      final response =
          await Get.find<HomeController>().reportPost(post, raison!);
      Get.dialog(AlertDialog(
        title: const Text('Report'),
        content: Text(response),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(Res.baseContext),
              child: const Text('Ok'))
        ],
      ));
    }
  });
}

void _showBlockUserDialog(PostModel post, VoidCallback action) {
  showDialog(
      context: Res.baseContext,
      builder: (context) => AlertDialog(
            title: Text('Block ${post.user?.name}'),
            content: RichText(
                text: TextSpan(children: [
              const TextSpan(
                  text: 'Do you really want to block ',
                  style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: '${post.user?.name}? ',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.black)),
              const TextSpan(
                  text: 'You can undo it from settings.',
                  style: TextStyle(color: Colors.black))
            ])),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(Res.baseContext),
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(Res.baseContext);
                    action();
                  },
                  child: const Text('Yes')),
            ],
          ));
}

void _movePost(PostModel post, Function(GroupModel) action) {
  final groups = Get.find<HomeController>().groups;
  showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
            title: const Text('Move post to'),
            content: SizedBox(
              height: Get.height * .6,
              width: Get.width * .8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: group.image ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, _) => const ShimmerBox(
                          height: 60,
                          width: 60,
                        ),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                        height: 60,
                        width: 60,
                      ),
                      title: Text(group.name ?? 'N/A'),
                      onTap: () {
                        Navigator.pop(context);
                        action(group);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'))
            ],
          ));
}

void _delete(PostModel post, VoidCallback action) {
  showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
            title: const Text('delete'),
            content: const Text('Do you want to delete this post?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('No')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    action();
                  },
                  child: const Text('Yes')),
            ],
          ));
}
