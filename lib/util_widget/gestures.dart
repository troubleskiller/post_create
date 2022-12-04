import 'package:flutter/material.dart';

class DismissKeyboardGesture extends StatelessWidget {
  const DismissKeyboardGesture({
    required this.bodyContent,
    this.overrideHitTest,
  });

  final Widget bodyContent;
  final HitTestBehavior? overrideHitTest;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: overrideHitTest ?? HitTestBehavior.deferToChild,
      onTap: () => dismissKeyboard(context),
      child: bodyContent,
    );
  }
}

void dismissKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}
