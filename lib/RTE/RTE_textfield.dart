import 'dart:async';
import 'dart:convert';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:post_create/controller/rte_controller.dart';
import 'package:post_create/helper/rte_helper.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class RTETextField extends StatefulWidget {
  final String placeholder;

  // 20220407 - Comment out all onTextChange, cuz it is not being utilized
  // final Function? onTextChange;
  final RTEController controller;
  final bool isCreatingPost;
  final bool isComment;
  final String? existingDeltaContent;
  final bool initFocusKeyboard;

  const RTETextField({
    required this.placeholder,
    // 20220407 - Comment out all onTextChange, cuz it is not being utilized
    // this.onTextChange,
    required this.controller,
    this.isCreatingPost = false,
    this.isComment = false,
    this.existingDeltaContent,
    this.initFocusKeyboard = true,
  });

  @override
  _RTETextFieldState createState() => _RTETextFieldState(
        // 20220407 - Comment out all onTextChange, cuz it is not being utilized
        // onTextChange: onTextChange,
        controller: controller,
      );
}

class _RTETextFieldState extends State<RTETextField> {
  final debouncer =
      Debouncer<String>(const Duration(milliseconds: 400), initialValue: '');
  RTEController? controller;
  FocusNode focusNode = FocusNode();

  // 20220519 - Comment out all onTextChange, cuz it is not being utilized
  // Function? onTextChange;

  bool suggestedTagsLoading = true;
  String? deltaContent;

  /// [_existingDeltaContent] - delta content of the post before edit
  String? _existingDeltaContent;

  _RTETextFieldState({
    // 20220519 - Comment out all onTextChange, cuz it is not being utilized
    // this.onTextChange,
    required this.controller,
  });

  void myOnTextChange() {
    String lastEntered = controller!.getLastEntered();
    String? newSearchTerm;
    int currentOffset = controller!.getCurrentOffset();

    // recolor text to overwrite color from old text
    if (controller!.controller.toggledStyle.isEmpty) {
      controller!.controller.formatSelection(ColorAttribute(null));
    }
    newSearchTerm = null;

    if (newSearchTerm != controller!.searchTerm) {
      controller!.setSearchTerm(newSearchTerm);
    }

    // 20220407 - Comment out all onTextChange, cuz it is not being utilized
    // if (onTextChange != null) {
    //   onTextChange!(lastEntered, controller!.toHTML());
    // }
  }

  /// Focus on RTE after uploading image(s)/file
  /// Re-add listener myOnTextChange for every reattach rte update action
  void rteActions() {
    if (controller!.action == RTEControllerAction.FOCUS) {
      FocusScope.of(context).unfocus();
      Timer(const Duration(milliseconds: 1), () {
        FocusScope.of(context).requestFocus(focusNode);
      });
      controller!.setAction(null);
    } else if (controller!.action == RTEControllerAction.REATTACHRTE) {
      controller!.controller.addListener(myOnTextChange);
    }
  }

  @override
  void dispose() {
    controller!.controller.removeListener(myOnTextChange);
    controller!.controller.removeListener(rteActions);
    controller!.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (controller != null) {
      controller!.controller.ignoreFocusOnTextChange = false;
      checkExistingContentIfAny(widget.existingDeltaContent);
    }

    controller!.controller.addListener(myOnTextChange);

    controller!.addListener(rteActions);
  }

  void checkExistingContentIfAny(String? content) {
    if (content != null) {
      _existingDeltaContent = content;
      // validate delta content
      controller!
          .checkValidDeltaContent(_existingDeltaContent!)
          .then((deltaContent) {
        // set validated delta content
        controller!.controller = QuillController(
          document: Document.fromJson(deltaContent),
          selection: const TextSelection.collapsed(offset: 0),
        );
        controller!.controller.addListener(myOnTextChange);
      });
    }
  }

  Widget buildQuilEditor(QuillController controller) {
    DefaultStyles myStyle = DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        Theme.of(context).textTheme.bodyText2!,
        const Tuple2(0, 0),
        const Tuple2(0, 0),
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        TextStyle(
          color: Colors.grey,
        ),
        const Tuple2(0, 0),
        const Tuple2(0, 0),
        null,
      ),
      link: TextStyle(
        color: Colors.greenAccent,
      ),
    );
    var quillEditor = QuillEditor(
        controller: controller,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: focusNode,
        // [autoFocus: true by default] - show keyboard for all scenarios except when user clicking from likeCommentStatistics
        autoFocus: widget.initFocusKeyboard,
        readOnly: widget.isCreatingPost ? true : false,
        placeholder: widget.placeholder,
        customStyles: myStyle,
        expands: false,
        showCursor: true,
        padding: const EdgeInsets.symmetric(vertical: 12),
        scrollPhysics: const ClampingScrollPhysics(),
        maxHeight: !widget.isComment
            ? (MediaQuery.of(context).size.height / 4)
            // : RTEConstants.COMMENT_MAX_HEIGHT,
            : 200);
    if (kIsWeb) {
      quillEditor = QuillEditor(
        controller: controller,
        scrollController: ScrollController(),
        scrollable: false,
        focusNode: focusNode,
        autoFocus: false,
        readOnly: widget.isCreatingPost ? true : false,
        placeholder: widget.placeholder,
        expands: false,
        showCursor: true,
        padding: EdgeInsets.zero,
        embedBuilders: defaultEmbedBuildersWeb,
      );
    }

    return quillEditor;
  }

  @override
  Widget build(BuildContext context) {
    // when user clicked on Edit Comment, widget.existingDeltaContent will be updated (not null)
    // and RTETextField will get rebuild, then this will be trigger,
    // to update the RTE textfield initial content

    Future.delayed(Duration.zero, () async {
      if ((widget.existingDeltaContent != null && widget.isComment) &&
          (widget.existingDeltaContent != _existingDeltaContent)) {
        _existingDeltaContent = widget.existingDeltaContent;
        // Considered that user clicked 'Edit Comment' for the first time (save incommingDeltaContent)
        // and clicked 'Edit Comment' again for other comment (need to replace new incommingDeltaContent to the previous content)
        if ((_existingDeltaContent != deltaContent) ||
            !controller!.updatedInitialContent) {
          await controller!
              .checkValidDeltaContent(_existingDeltaContent!)
              .then((value) {
            String data = jsonEncode(value);
            deltaContent = data;
            controller!.setInitialContent(data);
            controller!.setAction(RTEControllerAction.FOCUS);
          });
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: QuillToolbar.basic(
            controller: controller!.controller,
            showDividers: false,
            showBackgroundColorButton: false,
            showColorButton: false,
            showSearchButton: false,
            showHeaderStyle: false,
            showFontFamily: false,
            showListNumbers: false,
            showListBullets: false,
            showListCheck: false,
            showCodeBlock: false,
            showQuote: false,
            showIndent: false,
            showLink: false,
            showClearFormat: false,
            multiRowsDisplay: false,
            showUndo: false,
            showRedo: false,
            showInlineCode: false,
          ),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: buildQuilEditor(controller!.controller),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class WithRTE {
  static Widget build(Widget child) {
    return ChangeNotifierProvider(
        create: (context) => RTEController(), child: child);
  }
}
