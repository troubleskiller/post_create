import 'package:flutter/material.dart';
import 'package:post_create/post_attach_image/bubble_post_attach.dart';
import 'package:provider/provider.dart';

import '../controller/create_post_provider_controller.dart';
import '../model/image_model.dart';

class CreatePostAttachedImageConsumer extends StatelessWidget {
  final BuildContext? buildContext;
  final bool? isCreatingPost;
  final List<BubblePostAttachedImageFileModel> existingImages;
  const CreatePostAttachedImageConsumer({
    this.buildContext,
    this.isCreatingPost,
    this.existingImages = const [],
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProviderController>(builder:
        (createPostProviderControllerContext, createPostController, child) {
      return CreatePostAttachedImage(
        buildContext: createPostProviderControllerContext,
        createPostController: createPostController,
        hideCrossButton: isCreatingPost,
        existingImages: existingImages,
      );
    });
  }
}

class CreatePostAttachedImage extends StatefulWidget {
  final BuildContext? buildContext;
  final CreatePostProviderController? createPostController;
  final bool? hideCrossButton;
  final List<BubblePostAttachedImageFileModel> existingImages;
  const CreatePostAttachedImage({
    this.buildContext,
    this.createPostController,
    this.hideCrossButton = false,
    this.existingImages = const [],
  });
  @override
  _CreatePostAttachedImageState createState() => _CreatePostAttachedImageState(
      buildContext: buildContext, createPostController: createPostController);
}

class _CreatePostAttachedImageState extends State<CreatePostAttachedImage> {
  BuildContext? buildContext;
  CreatePostProviderController? createPostController;
  _CreatePostAttachedImageState({this.buildContext, this.createPostController});

  @override
  void initState() {
    super.initState();

    if (widget.existingImages.isNotEmpty) {
      Future(() {
        createPostController!.addImages(widget.existingImages);
      });
    }

    createPostController!.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: createPostController!.getImages().isEmpty,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: BubblePostAttachedImages(
          attachedImages: createPostController!.getImages(),
          onDelete: (BubblePostAttachedImageFileModel image) {
            createPostController!.removeImage(image);
          },
          hideCrossButton: widget.hideCrossButton,
        ),
      ),
    );
  }
}
