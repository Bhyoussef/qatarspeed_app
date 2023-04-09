import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/controllers/user_controller.dart';
import 'package:qatar_speed/models/user.dart';
import 'package:qatar_speed/tools/res.dart';

import '../common/shimmer_bocx.dart';

class StoryListItem extends StatelessWidget {
  const StoryListItem(
      {Key? key,
      this.isMine = false, this.story, this.onTap})
      : super(key: key);
  final UserModel? story;
  final bool isMine;
  final Function(UserModel)? onTap;

  @override
  Widget build(BuildContext context) {
    final size = Res.isPhone ? 50.0 : 50.0;
    final userSize = Res.isPhone ? 20.0 : 20.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          if (story != null && onTap != null) {
            onTap!(story!);
          }
        },
        child: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF1919), width: 2.0),
                  //color: Colors.yellow
                ),
                padding: const EdgeInsets.all(3.0),
                child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: story?.id == -1 ? (Get.find<UserController>().user.photo ?? '') : story?.storyThumb ?? story?.photo ?? '',
                      placeholder: (context, _) => ShimmerBox(
                        height: size,
                        width: size,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: size,
                        height: size,
                        color: Colors.blue,
                        child: const Icon(Icons.person, color: Colors.white, size: 40.0,),
                      ),
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ))),
            Positioned(
              bottom: .0,
              right: 14.0,
              child: isMine
                  ? DottedBorder(
                      borderType: BorderType.Oval,
                      color: Colors.black,
                      strokeWidth: Res.isPhone ? 1.0 : 2.0,
                      dashPattern: const [4],
                      child: Padding(
                        padding: EdgeInsets.all(Res.isPhone ? .0 : 2.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xffB90000),
                            shape: BoxShape.circle,
                          ),
                          padding:  EdgeInsets.all(Res.isPhone ? 2.0 : 4.0),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: Res.isPhone ? 18.0 : 13.0,
                          ),
                        ),
                      ),
                    )
                  : Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xff444444), width: Res.isPhone ? 1.0 : 3.0),
                            ),
                            padding: EdgeInsets.all(Res.isPhone ? 1.0 : 2.0),
                            child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: story?.photo ?? '',
                                  placeholder: (context, _) => ShimmerBox(
                                    height: userSize,
                                    width: userSize,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: userSize,
                                    height: userSize,
                                    color: Colors.black,
                                  ),
                                  width: userSize,
                                  height: userSize,
                                  fit: BoxFit.cover,
                                ))),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
