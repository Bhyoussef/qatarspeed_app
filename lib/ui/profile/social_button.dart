// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
enum SocialType {
  Twitter,
  Facebook,
  Instagram,
  Tiktok,
  Snapchat,
  Whatsapp
}

class SocialButton extends StatelessWidget {
  const SocialButton({Key? key, required this.type, required this.onTap}) : super(key: key);
  final SocialType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case SocialType.Twitter: icon = FontAwesome.twitter; break;
      case SocialType.Facebook: icon = FontAwesome.facebook_official; break;
      case SocialType.Instagram: icon = FontAwesome.instagram; break;
      case SocialType.Tiktok: icon = Icons.tiktok; break;
      case SocialType.Snapchat: icon = FontAwesome.snapchat_square; break;
      default: icon = FontAwesome.whatsapp;

    }
    return Wrap(
      children: [
        Center(
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(10.0)
              ),
              padding: const EdgeInsets.all(15.0),
              child: Icon(icon),
            ),
          ),
        ),
      ],
    );
  }
}
