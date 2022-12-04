import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:post_create/model/image_model.dart';
import 'package:post_create/util_widget/gestures.dart';

import '../RTE/RTE_textfield.dart';
import '../RTE/RTE_textfield_consumer.dart';
import '../RTE/keyboard_toolbar.dart';
import '../controller/create_post_provider_controller.dart';
import 'create_post_attached_files.dart';
import 'create_post_attached_images.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({
    Key? key,
    this.decoration,
    this.placeholder,
    this.existingDeltaContent,
    this.existingImages,
    this.existingfiles,
    this.canUploadImage = true,
    this.canUploadFile = true,
    this.titleWidget,
    required this.postAs,
  }) : super(key: key);

  final BoxDecoration? decoration;

  //AppBar
  final Widget? titleWidget;

  //占位
  final String? placeholder;

  //已经有的内容，可用于编辑功能。
  final String? existingDeltaContent;

  //已经存在的上传图片
  final List<BubblePostAttachedImageFileModel>? existingImages;

  //已经存在的上传文件
  final List<BubblePostAttachedImageFileModel>? existingfiles;

  //是否包含上传图片
  final bool canUploadImage;

  //是否包含上传文件
  final bool canUploadFile;

  //upload[发布帖子的回调]
  final Function postAs;

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
        builder: (keyboardVisibilityContext, isKeyboardVisible) {
      return WithRTE.build(
        WithCreatePostProvider.build(
            child: DismissKeyboardGesture(
                bodyContent: Column(
          children: [
            Expanded(
                flex: 1,
                child: CustomScrollView(
                  slivers: [
                    widget.titleWidget ??
                        AppBar(
                          title: Text('Create Post'),
                          actions: [
                            GestureDetector(
                              child: Text('Create'),
                              onTap: () {
                                widget.postAs();
                              },
                            )
                          ],
                        ),
                    SliverList(
                        delegate: SliverChildListDelegate([
                      RTETextFieldConsumer(
                        placeholder: widget.placeholder ?? 'post here',
                        existingDeltaContent: widget.existingDeltaContent,
                      ),
                      Offstage(
                        offstage: !widget.canUploadFile,
                        child: CreatePostAttachedFileConsumer(
                          buildContext: context,
                          isCreatingPost: false,
                          existingFiles: widget.existingfiles ?? [],
                        ),
                      ),
                      Offstage(
                        offstage: !widget.canUploadImage,
                        child: CreatePostAttachedImageConsumer(
                          buildContext: context,
                          isCreatingPost: false,
                          existingImages: widget.existingImages ?? [],
                        ),
                      ),
                    ]))
                  ],
                )),
            KeyboardToolbarConsumer(
              buildContext: context,
              isCreatingPost: true,
            ),
          ],
        ))),
      );
    });
  }
}
