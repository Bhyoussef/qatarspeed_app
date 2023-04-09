import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mime_type/mime_type.dart';
import 'package:qatar_speed/controllers/home_controller.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';
import 'package:qatar_speed/ui/home/story_view/story_view.dart';
import 'package:wakelock/wakelock.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key, required this.index, required this.stories})
      : super(key: key);
  final int index;
  final List<UserModel> stories;

  @override
  State<StatefulWidget> createState() {
    return _StoryState();
  }
}

class _StoryState extends State<StoryScreen> {
  late int index;
  late final List<UserModel> users;
  final _stories = <List<StoryItem>>[].obs;
  final StoryController _storyController = StoryController();
  late final PageController _pageController;
  final isMine = false.obs;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    users = widget.stories;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.enable();

    _pageController = PageController(initialPage: index, keepPage: true);

    _buildStoryItems();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values)
        .then((value) => Res.initSystemOverlays());
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          itemCount: users.length,
          controller: _pageController,
          onPageChanged: (index) {
            if (index == 0) Navigator.pop(context);
            this.index = index;
            if (widget.stories[index].id == Get.find<UserController>().user.id) {
              isMine.value = true;
            }
          },
          itemBuilder: (context, index) {
            return Obx(() {
              if ((_stories[index - 1].length <
                      (users[index].stories?.length ?? 0)) ||
                  index == 0) {
                return Container(
                    color: Colors.black,
                    child: index > 0
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Container());
              }
              return StoryView(
                storyItems: _stories[index - 1],
                user: users[index],
                controller: _storyController,
                onStoryShow: (s) {},
                onDeleteStory: _deleteStory,
                onChanged: (index) {
                  if (index == -1) {
                    if (this.index >
                        1 /* Because of the initial empty current user story*/) {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                onComplete: () {
                  if (index + 1 < users.length) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  } else {
                    Navigator.pop(context);
                  }
                },
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.pop(context);
                  }
                }, // To disable vertical swipe gestures, ignore this parameter.
              );
            });
          }),
    );
  }

  _buildStoryItems() {
    for (int index = 1; index < users.length; index++) {
      _stories.add([]);
      for (int j = 0; j < (users[index].stories?.length ?? 0); j++) {
        final story = users[index].stories![j];
        final mme = mime(story.link?.split('/').last ?? '');
        if (mme == null) {
          _stories[index - 1].add(StoryItem.text(
              id: story.id,
              backgroundColor: Colors.black, title: 'Unable to get stoty'));
        } else if (mme.contains('video')) {
          try {
            //final duration = await _getVideoDuration(story.link!);
            _stories[index - 1].add(StoryItem.pageVideo(story.link ?? '',
                id: story.id,
                controller: _storyController, duration: Duration(seconds: story.duration!)));
          } catch (e) {
            debugPrint('error loading story  ${story.link}');
            _stories[index - 1].add(StoryItem.text(
                id: story.id,
                title: 'Can\'t load story', backgroundColor: Colors.black));
          }
        } else {
          _stories[index - 1].add(StoryItem.pageImage(
            id: story.id,
              url: story.link ?? '',
              controller: _storyController,));
        }
      }
    }
  }

  void _deleteStory(StoryItem story) {
    _storyController.pause();
    Get.dialog(AlertDialog(
      title: const Text('Delete'),
      content: const Text('Do you want to delete this story?\nThis process can\'t be undone'),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context);
          _storyController.play();
        }, child: const Text('No')),
        TextButton(onPressed: () {
          Navigator.pop(context);
          _storyController.play();
          final controller = Get.find<HomeController>();
          unawaited(controller.deleteStory(story, index));
          _stories[index - 1].removeWhere((element) => element.id == story.id);
          if (_stories[index - 1].isEmpty) {
            _stories.removeAt(index - 1);
          }
        }, child: const Text('Yes')),
      ],
    ));
  }
}
