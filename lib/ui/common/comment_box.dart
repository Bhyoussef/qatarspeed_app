import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qatar_speed/tools/res.dart';

class CommentBox extends StatelessWidget {
  CommentBox(
      {Key? key,
      this.onSend,
      this.onChanged,
      TextEditingController? textController,
      this.focus,
      required this.hint,
      required this.suffixWidget,
      this.autoFocus = false,
      this.sendOnEnter = false})
      : textController = textController ?? TextEditingController(),
        super(key: key);

  final Function(String)? onSend;
  final Function(String)? onChanged;
  final TextEditingController textController;
  final FocusNode? focus;
  final bool sendOnEnter;
  final String hint;
  final Widget suffixWidget;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/car.jpg',
            height: Res.isPhone ? 25.0 : 35.0,
            width: Res.isPhone ? 25.0 : 35.0,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Flexible(
          child: TextField(
            onChanged: onChanged,
            controller: textController,
            focusNode: focus,
            maxLines: 3,
            minLines: 1,
            autofocus: autoFocus,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: Res.isPhone ? 13.0 : 17.0),
            textInputAction: sendOnEnter ? TextInputAction.send : TextInputAction.done,
            onSubmitted: (txt) {
              if (txt.removeAllWhitespace.isNotEmpty) {
                if (onSend != null && sendOnEnter) {
                  onSend!(txt);textController.clear();
                }
                FocusScope.of(context).unfocus();
              }
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(fontSize: Res.isPhone ? 13.0 : 17.0),
              suffixIcon: InkWell(onTap: () {
                if (onSend != null) {
                  onSend!(textController.text);
                }
                textController.clear();
                FocusScope.of(context).unfocus();
              }, child: suffixWidget),
              border: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
