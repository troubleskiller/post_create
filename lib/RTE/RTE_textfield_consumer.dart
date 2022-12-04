import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/rte_controller.dart';
import 'RTE_textfield.dart';

class RTETextFieldConsumer extends StatelessWidget {
  final String placeholder;
  // 20220407 - Comment out all onTextChange, cuz it is not being utilized
  // final Function? onTextChange;
  final bool isCreatingPost;
  final bool isComment;
  final String? existingDeltaContent;
  final bool initFocusKeyboard;

  const RTETextFieldConsumer({
    required this.placeholder,
    // this.onTextChange,
    this.isCreatingPost = false,
    this.isComment = false,
    this.existingDeltaContent,
    this.initFocusKeyboard = true,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<RTEController>(builder: (ctx, controller, child) {
      return RTETextField(
        placeholder: placeholder,
        // onTextChange: onTextChange,
        controller: controller,
        isCreatingPost: isCreatingPost,
        isComment: isComment,
        existingDeltaContent: existingDeltaContent,
        initFocusKeyboard: initFocusKeyboard,
      );
    });
  }
}
